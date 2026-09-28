"""Exercise first/repeat setup with disposable homes and stubbed installers."""

import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]


class BootstrapTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix="dotfiles-setup-")
        self.addCleanup(self.temporary.cleanup)
        self.directory = Path(self.temporary.name).resolve()
        self.account = self.directory / "account"
        self.account.mkdir()
        self.repository = self.directory / "repo with spaces"
        self.repository.mkdir()
        for name in ("bootstrap.sh", "rebuild.sh"):
            shutil.copy2(ROOT / name, self.repository / name)
        (self.repository / "flake.nix").write_text('let\n  user = "temelgunaydin";\nin {}\n')
        self.bin = self.directory / "bin"
        self.bin.mkdir()
        self.log = self.directory / "commands.jsonl"
        # These variables belong only to the disposable child account.
        self.environment = {
            "HOME": str(self.account),
            "PATH": f"{self.bin}:/usr/bin:/bin:/usr/sbin:/sbin",
            "DOTFILES_TEST_LOG": str(self.log),
            "LANG": "C",
        }
        for name in ("nix", "sudo", "git", "id", "uname"):
            self.stub(name)

    def stub(self, name):
        path = self.bin / name
        path.write_text(
            f"#!{sys.executable}\n"
            "import json, os, pathlib, sys\n"
            "name = pathlib.Path(sys.argv[0]).name\n"
            "with open(os.environ['DOTFILES_TEST_LOG'], 'a') as log:\n"
            "    log.write(json.dumps([name, *sys.argv[1:]]) + '\\n')\n"
            "if name == 'uname': print('Darwin')\n"
            "elif name == 'id':\n"
            "    print(os.environ.get('DOTFILES_TEST_UID', '501') if sys.argv[1] == '-u' "
            "else os.environ.get('DOTFILES_TEST_USER', 'temelgunaydin'))\n"
            "elif name == 'git' and sys.argv[1] == 'clone':\n"
            "    pathlib.Path(sys.argv[-1]).mkdir(parents=True)\n"
        )
        path.chmod(0o755)

    def run_script(self, name="bootstrap.sh", answer=""):
        return subprocess.run(
            ["/bin/bash", str(self.repository / name)],
            cwd=self.repository,
            env=self.environment,
            input=answer,
            text=True,
            capture_output=True,
            timeout=20,
        )

    def commands(self, name):
        if not self.log.exists():
            return []
        return [row for line in self.log.read_text().splitlines()
                if (row := json.loads(line))[0] == name]

    def test_first_setup_restores_plugins_and_uses_nix_for_first_switch(self):
        result = self.run_script()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(len(self.commands("git")), 4)
        self.assertEqual((self.account / ".dotfiles").resolve(), self.repository)
        self.assertEqual(self.commands("sudo"), [[
            "sudo", str(self.bin / "nix"), "run",
            "github:nix-darwin/nix-darwin/nix-darwin-26.05#darwin-rebuild",
            "--", "switch", "--flake", f"{self.repository}#mac",
        ]])

    def test_repeat_setup_keeps_existing_plugin_files(self):
        first = self.run_script()
        self.assertEqual(first.returncode, 0, first.stderr)
        plugin = self.account / ".oh-my-zsh/custom/plugins/zsh-bat/personal.txt"
        plugin.write_text("keep my changes")
        second = self.run_script()
        self.assertEqual(second.returncode, 0, second.stderr)
        self.assertEqual(len(self.commands("git")), 4)
        self.assertEqual(plugin.read_text(), "keep my changes")

    def test_installed_rebuild_is_invoked_by_absolute_path(self):
        self.stub("darwin-rebuild")
        result = self.run_script("rebuild.sh")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.commands("sudo"), [[
            "sudo", str(self.bin / "darwin-rebuild"),
            "switch", "--flake", f"{self.repository}#mac",
        ]])

    def test_clone_directly_at_dotfiles_remains_a_directory(self):
        destination = self.account / ".dotfiles"
        self.repository.rename(destination)
        self.repository = destination
        result = self.run_script()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(destination.is_symlink())
        self.assertFalse((destination / ".dotfiles").exists())

    def test_conflicting_dotfiles_directory_is_preserved(self):
        destination = self.account / ".dotfiles"
        destination.mkdir()
        original = destination / "personal.txt"
        original.write_text("keep me")
        result = self.run_script("rebuild.sh")
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(original.read_text(), "keep me")
        self.assertFalse(self.commands("sudo"))

    def test_declining_username_change_does_not_apply(self):
        self.environment["DOTFILES_TEST_USER"] = "anotheruser"
        result = self.run_script(answer="n\n")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('user = "temelgunaydin";', (self.repository / "flake.nix").read_text())
        self.assertFalse(self.commands("git"))
        self.assertFalse(self.commands("sudo"))

    @unittest.skipUnless(sys.platform == "darwin", "bootstrap uses macOS sed")
    def test_accepting_username_change_applies_to_current_account(self):
        self.environment["DOTFILES_TEST_USER"] = "anotheruser"
        result = self.run_script(answer="y\n")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('user = "anotheruser";', (self.repository / "flake.nix").read_text())
        self.assertEqual(len(self.commands("sudo")), 1)

    def test_root_invocation_stops_before_installing(self):
        self.environment["DOTFILES_TEST_UID"] = "0"
        result = self.run_script()
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(self.commands("git"))
        self.assertFalse(self.commands("sudo"))


if __name__ == "__main__":
    unittest.main()

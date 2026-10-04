"""Check editor defaults exported by the linked Zsh startup file."""

import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
ZSH = shutil.which("zsh")


@unittest.skipUnless(ZSH, "zsh is required to check shell startup")
class ShellConfigTests(unittest.TestCase):
    def test_new_shells_export_neovim_to_child_processes(self):
        with tempfile.TemporaryDirectory(prefix="dotfiles-shell-") as directory:
            shutil.copy2(ROOT / "home/.zshenv", Path(directory) / ".zshenv")
            for editor in ("nano", ""):
                with self.subTest(inherited_editor=editor):
                    environment = {
                        "HOME": directory,
                        "ZDOTDIR": directory,
                        "PATH": os.environ["PATH"],
                        "EDITOR": editor,
                        "VISUAL": editor,
                    }
                    result = subprocess.run(
                        [ZSH, "-c", '/bin/sh -c \'printf "%s\\n" "$EDITOR" "$VISUAL"\''],
                        env=environment,
                        text=True,
                        capture_output=True,
                        timeout=10,
                    )
                    self.assertEqual(result.returncode, 0, result.stderr)
                    self.assertEqual(result.stdout.splitlines(), ["nvim", "nvim"])

    def test_optional_local_aliases_load_last(self):
        for has_local_file in (False, True):
            with self.subTest(has_local_file=has_local_file):
                with tempfile.TemporaryDirectory(prefix="dotfiles-local-aliases-") as directory:
                    home = Path(directory)
                    shutil.copy2(ROOT / "home/.zshrc", home / ".zshrc")
                    oh_my_zsh = home / ".oh-my-zsh"
                    oh_my_zsh.mkdir()
                    (oh_my_zsh / "oh-my-zsh.sh").write_text("")
                    if has_local_file:
                        (home / ".zshrc.local").write_text(
                            "alias local_test='printf private'\n"
                            "alias ls='printf local'\n"
                        )
                    result = subprocess.run(
                        [
                            ZSH, "-f", "-c",
                            'source "$HOME/.zshrc" || exit; '
                            'print -rl -- "loaded" "$aliases[local_test]" "$aliases[ls]"',
                        ],
                        env={
                            "HOME": directory,
                            "ZDOTDIR": directory,
                            "PATH": "/usr/bin:/bin",
                            "TERM": "dumb",
                        },
                        text=True,
                        capture_output=True,
                        timeout=10,
                    )
                    self.assertEqual(result.returncode, 0, result.stderr)
                    lines = result.stdout.splitlines()
                    self.assertEqual(lines[0], "loaded")
                    if has_local_file:
                        self.assertEqual(lines[1:], ["printf private", "printf local"])
                    else:
                        self.assertEqual(lines[1], "")
                        self.assertNotEqual(lines[2], "printf local")

    def test_local_shell_settings_are_git_ignored(self):
        result = subprocess.run(
            ["git", "check-ignore", "--quiet", "home/.zshrc.local"],
            cwd=ROOT,
            capture_output=True,
            timeout=10,
        )
        self.assertEqual(result.returncode, 0, "Local shell settings must be ignored")


if __name__ == "__main__":
    unittest.main()

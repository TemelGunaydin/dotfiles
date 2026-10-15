"""Keep the requested application installs pinned and wired into normal setup."""

import json
from pathlib import Path
import re
import unittest


ROOT = Path(__file__).resolve().parents[1]


class PackageConfigTests(unittest.TestCase):
    def test_terminal_todos_uses_the_cache_fix_release(self):
        settings = json.loads((ROOT / "home/.pi/agent/settings.json").read_text())
        packages = [package for package in settings["packages"]
                    if isinstance(package, str) and "terminal-todos" in package]
        self.assertEqual(packages, [
            "git:github.com/TemelGunaydin/terminal-todos@v1.5.1",
        ])

    def test_pushtrack_is_installed_by_home_manager(self):
        home = (ROOT / "home.nix").read_text()
        self.assertRegex(home, r"home\.packages\s*=\s*\[\s*\(pkgs\.callPackage\s+"
                         r"\./packages/pushtrack\.nix\s+\{\s*\}\)\s*\];")
        self.assertIn("home-manager.users.${user} = import ./home.nix;",
                      (ROOT / "flake.nix").read_text())

    def test_pushtrack_source_and_dependencies_have_real_hashes(self):
        package = (ROOT / "packages/pushtrack.nix").read_text()
        self.assertIn('repo = "PushTrack";', package)
        self.assertRegex(package, r'rev = "[a-f0-9]{40}";')
        for attribute in ("hash", "cargoHash"):
            match = re.search(rf'{attribute} = "(sha256-[A-Za-z0-9+/]{{43}}=)";', package)
            self.assertIsNotNone(match, f"{attribute} must contain a verified SRI hash")
            self.assertNotEqual(match[1], "sha256-" + "A" * 43 + "=")
        self.assertNotIn("lib.fakeHash", package)
        self.assertIn("nativeCheckInputs = [ git ];", package)


if __name__ == "__main__":
    unittest.main()

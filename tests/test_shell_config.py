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


if __name__ == "__main__":
    unittest.main()

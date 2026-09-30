"""Check pane shortcuts in the shipped Herdr configuration."""

from pathlib import Path
import tomllib
import unittest


ROOT = Path(__file__).resolve().parents[1]


class HerdrConfigTests(unittest.TestCase):
    def setUp(self):
        with (ROOT / "home/.config/herdr/config.toml").open("rb") as config:
            self.keys = tomllib.load(config)["keys"]

    def test_prefix_navigation_uses_vim_keys(self):
        self.assertEqual(self.keys["prefix"], "ctrl+a")
        for direction, key in (("left", "h"), ("down", "j"), ("up", "k"), ("right", "l")):
            with self.subTest(direction=direction):
                self.assertEqual(self.keys[f"focus_pane_{direction}"], f"prefix+{key}")

    def test_prefix_arrows_resize_panes(self):
        for direction in ("left", "down", "up", "right"):
            with self.subTest(direction=direction):
                self.assertEqual(self.keys[f"resize_pane_{direction}"], f"prefix+{direction}")
        self.assertEqual(self.keys["resize_mode"], "prefix+shift+r")
        self.assertEqual(self.keys["reload_config"], "prefix+r")

    def test_configured_action_shortcuts_do_not_conflict(self):
        shortcuts = [value for name, value in self.keys.items() if name != "prefix"]
        self.assertEqual(len(shortcuts), len(set(shortcuts)))


if __name__ == "__main__":
    unittest.main()

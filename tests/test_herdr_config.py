"""Check pane shortcuts in the shipped Herdr configuration."""

from pathlib import Path
import tomllib
import unittest


ROOT = Path(__file__).resolve().parents[1]


class HerdrConfigTests(unittest.TestCase):
    def setUp(self):
        with (ROOT / "home/.config/herdr/config.toml").open("rb") as config:
            self.config = tomllib.load(config)
        self.keys = self.config["keys"]

    def test_prefix_navigation_uses_vim_keys(self):
        self.assertEqual(self.keys["prefix"], "ctrl+a")
        for direction, key in (("left", "h"), ("down", "j"), ("up", "k"), ("right", "l")):
            with self.subTest(direction=direction):
                self.assertEqual(self.keys[f"focus_pane_{direction}"], f"prefix+{key}")

    def test_sidebar_navigation_uses_vim_keys_and_keeps_arrows(self):
        self.assertEqual(self.keys["navigate_workspace_up"], ["up", "k"])
        self.assertEqual(self.keys["navigate_workspace_down"], ["down", "j"])

    def test_prefix_arrows_resize_panes(self):
        for direction in ("left", "down", "up", "right"):
            with self.subTest(direction=direction):
                self.assertEqual(self.keys[f"resize_pane_{direction}"], f"prefix+{direction}")
        self.assertEqual(self.keys["resize_mode"], "prefix+shift+r")
        self.assertEqual(self.keys["reload_config"], "prefix+r")

    def test_prefix_backslash_toggles_and_fully_hides_sidebar(self):
        self.assertEqual(self.keys["toggle_sidebar"], "prefix+\\")
        self.assertEqual(self.config["ui"]["sidebar_collapsed_mode"], "hidden")

    def test_prefix_x_closes_pane(self):
        self.assertEqual(self.keys["close_pane"], "prefix+x")

    def test_configured_action_shortcuts_do_not_conflict(self):
        shortcuts = [
            shortcut
            for name, value in self.keys.items()
            if name != "prefix"
            for shortcut in (value if isinstance(value, list) else [value])
        ]
        self.assertEqual(len(shortcuts), len(set(shortcuts)))


if __name__ == "__main__":
    unittest.main()

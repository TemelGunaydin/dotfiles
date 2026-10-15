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

    def test_history_viewer_replaces_terminal_only_shortcut(self):
        self.assertEqual(self.keys["edit_scrollback"], [])
        viewer, = self.keys["command"]
        self.assertEqual(viewer["key"], "prefix+e")
        self.assertEqual(viewer["type"], "pane")
        self.assertEqual(
            viewer["command"],
            'node "$HOME/.pi/agent/extensions/session-history/viewer.cjs"',
        )
        self.assertTrue((ROOT / "home/.pi/agent/extensions/session-history/viewer.cjs").is_file())

    def test_configured_action_shortcuts_do_not_conflict(self):
        shortcuts = [
            shortcut
            for name, value in self.keys.items()
            if name not in ("prefix", "command")
            for shortcut in (value if isinstance(value, list) else [value])
        ]
        shortcuts.extend(command["key"] for command in self.keys.get("command", []))
        self.assertEqual(len(shortcuts), len(set(shortcuts)))


if __name__ == "__main__":
    unittest.main()

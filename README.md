# macOS dotfiles

A personal Mac setup that keeps terminal settings, developer tools, and macOS
preferences in one place. Use it to set up a new Mac or keep your existing setup
under version control.

**What are dotfiles?** They are settings files used by your apps. Many names start
with a dot, such as `.zshrc`, so macOS hides them by default. This repository stores
those files alongside scripts that install tools and connect the settings to your
home folder.

This is **not an app or a full Mac backup**. It applies the author's personal
preferences to your Mac, so review them before installing. It is for macOS, not
Windows or Linux.

## What you get

- **Shell:** Zsh with Oh My Zsh plugins, command suggestions, syntax highlighting,
  personal aliases (shortcuts for commands), and a Starship prompt.
- **Terminal:** WezTerm with the Rosé Pine Moon theme, Hack Nerd Font, transparency,
  and background blur. Unfocused windows are dimmed.
- **Editor:** A personal Neovim configuration and its plugin list.
- **Terminal panes:** Herdr, which lets you work in several terminal panes and tabs.
- **Command-line tools:** Utilities such as `fzf`, `ripgrep`, `lazygit`, `bat`, `eza`,
  and `zoxide`, plus Codex, Claude Code, OpenCode, CodeGraph, and RTK.
- **AI settings:** Shared agent instructions, Claude settings, and Pi settings,
  themes, and extensions. **Pi itself must be installed separately.**
- **macOS preferences:** Dark mode, an auto-hiding Dock and menu bar, hidden desktop
  icons, Finder list view, faster key repeat, and tap-to-click.

The full package list and macOS preferences are in [`configuration.nix`](configuration.nix).
Desktop icons are hidden, not deleted.

## Before you install

You need a Mac, an internet connection, and an account that can approve administrator
requests. The default configuration targets **Apple Silicon** (M-series chips).
To check your chip, open **Apple menu → About This Mac**.

> **Back up your current settings first**, for example with Time Machine. This
> setup replaces the settings files it manages, including your shell and Neovim
> configuration. Home Manager backs up conflicting files with a
> `.before-home-manager` suffix, but this is not a substitute for your own backup.
> If that backup name already exists, installation stops instead of overwriting it.

You do not need to install Nix or Homebrew first. The setup handles them. If you
already use Nix with a different installer, review `nix.enable = false` in
`configuration.nix` before continuing: this setup expects the Nix service to be
managed outside nix-darwin, as it is with Determinate Nix.

## Installation, step by step

### 1. Open Terminal and install Apple's command-line tools

Open **Terminal** from **Applications → Utilities**, or search for it with Spotlight
(`Cmd+Space`). Paste this command and press Enter:

```sh
xcode-select --install
```

Follow the installer and wait for it to finish. If macOS says the tools are already
installed, continue. These tools include Git, which downloads the repository.

### 2. Download this repository

Run these commands in Terminal:

```sh
git clone https://github.com/TemelGunaydin/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

The first command downloads the files into a `dotfiles` folder inside your home
folder. The second moves Terminal into that folder. If you use your own fork
(a personal GitHub copy), replace the URL with yours. If you already cloned this
repository, just open its folder in Terminal instead.

### 3. Review the settings

Open `configuration.nix` in a text editor. Review the `homebrew` package list and
`system.defaults` macOS preferences before applying them.

**On an Intel Mac**, change this line in `configuration.nix`:

```nix
nixpkgs.hostPlatform = "x86_64-darwin";
```

Apple Silicon users should keep `"aarch64-darwin"`. Also review machine-specific
paths in `home/` if you are adapting this setup; for example, the current `fzf`
shell integration uses the Apple Silicon Homebrew path `/opt/homebrew`.

Your macOS account name is configured in `flake.nix`. You do not need to edit it
manually: the next step asks permission to update it if your account name differs.

### 4. Run the installer

From the repository folder, run:

```sh
./bootstrap.sh
```

**Do not put `sudo` before this command.** The script asks for administrator access
when needed. When Terminal asks for your Mac password, no characters appear as you
type; that is normal. Type the password and press Enter.

The script:

1. Installs Determinate Nix if Nix is missing.
2. Checks your account name. Enter `y` if it asks to update `flake.nix` for your account.
3. Downloads Oh My Zsh and three shell plugins if they are missing. Existing folders
   are kept as they are.
4. Runs `rebuild.sh` to install the configured packages, apply macOS preferences,
   and link the settings files to this repository.

The first run can take a while because it downloads tools. Wait until the command
finishes without an error.

### 5. Open a new terminal

Close and reopen Terminal, or open **WezTerm** from Applications. New shell sessions
will use the configured prompt and shortcuts.

You can check that the tools are available:

```sh
nvim --version
starship --version
herdr --version
```

Run `herdr` to open the terminal workspace manager, or `nvim` to open Neovim.
AI tools may need their own sign-in or API keys; this repository does not include
credentials.

## Everyday changes

Keep the repository where you cloned it. The installer creates `~/.dotfiles` as a
link to that folder, and the app settings point to files inside it. Here, `~` means
your home folder and a **link** means an app reads the repository's file rather than
a separate copy.

| What you want to change | File to edit | How to apply it |
| --- | --- | --- |
| Packages or macOS preferences | `configuration.nix` | Run `./rebuild.sh` |
| Managed file links | `home.nix` | Run `./rebuild.sh` |
| Shell aliases or plugins | `home/.zshrc` | Open a new terminal |
| Neovim settings | `home/.config/nvim/` | Restart Neovim |
| WezTerm appearance | `home/.config/wezterm/wezterm.lua` | Usually reloads automatically; use `Ctrl+Shift+R` if needed |
| Herdr shortcuts | `home/.config/herdr/config.toml` | Use `Ctrl+A`, then `r` |
| Pi settings or extensions | `home/.pi/agent/` | Run `/reload` inside Pi |
| Shared AI instructions | `home/AGENTS.md` | Start a new agent session |

Run rebuild commands **from the repository folder**, for example:

```sh
cd ~/dotfiles
./rebuild.sh
```

A rebuild installs missing listed packages and applies the configuration. It does
not automatically upgrade Homebrew packages or remove unlisted apps. Editing an
already linked app settings file does not require a rebuild.

If you want your edits on another Mac, commit and push them to your own repository,
then download that repository there. Do not commit passwords, API keys, or sessions.

## Herdr pane shortcuts

The **prefix** is `Ctrl+A`: press it once, release it, then press the action key.
For example, `Ctrl+A`, then `h` moves to the pane on the left. You do not hold all
keys together.

| After `Ctrl+A`, press… | Action |
| --- | --- |
| `h` / `j` / `k` / `l` | Move to the left / down / up / right pane, like Neovim |
| Left / Down / Up / Right arrow | Resize a pane in that direction |
| `\|` | Split into side-by-side panes |
| `-` | Split into stacked panes |
| `m` | Enlarge the current pane, or restore its size |
| `Ctrl+K` | Close the current pane |
| `Shift+R` | Enter resize mode |
| `r` | Reload the configuration |
| `c` | Create a tab |
| `[` | Enter copy mode; `v` selects, `y` copies, `q` or Esc exits |

Mouse selections are copied automatically. Herdr uses its own resize increments;
they are not the same as tmux's five-cell resize or repeatable bindings.

## Troubleshooting

- **“Nix is not available” or a request to open a new terminal:** Open a new Terminal
  window, return to the repository folder, and run `./bootstrap.sh` again.
- **A username update was declined:** Change `user` in `flake.nix` to the name shown
  by `whoami`, then rerun `./bootstrap.sh`.
- **“~/.dotfiles already exists”:** The script keeps unrelated files and folders
  safe. Back up and move the conflicting item, or run the setup from that folder
  if it is already this repository. Do not delete it without checking its contents.
- **A `.before-home-manager` backup already exists:** Move the old backup somewhere
  safe before retrying; it will not be overwritten automatically.
- **You cannot see `.config` or other dotfiles in Finder:** Press `Cmd+Shift+.` to
  show hidden files. The configs in this repository are under `home/.config/`.
- **Pi or `ai-cli` is missing:** Pi is installed separately. Zellij is disabled by
  default, so the existing `ai-cli` alias is not ready to use; see the notes below.

## How the setup works

You do not need to learn these tools to follow the installation steps:

- **Nix** provides the configuration tooling and its dependencies.
- **nix-darwin** uses that configuration to manage macOS settings and run the setup.
- **Homebrew** installs the apps and command-line tools.
- **Home Manager** connects the settings files to their expected locations in your
  home folder and backs up conflicting files.

| File | Purpose |
| --- | --- |
| `bootstrap.sh` | First-time setup: Nix, account name, shell plugins, and first rebuild |
| `rebuild.sh` | Points `~/.dotfiles` at this checkout and applies the configuration |
| `flake.nix` / `flake.lock` | Connect the Nix components, set the account name, and record dependency versions |
| `configuration.nix` | Lists packages and macOS preferences |
| `home.nix` | Defines the app settings links |
| `home/` | Contains the actual settings you edit |
| `tests/` | Checks the setup scripts, Herdr shortcuts, and Pi Calm extension |

## Optional and advanced notes

<details>
<summary>AI tools, local data, and disabled features</summary>

- Pi is not installed by these scripts. Follow its [official installation steps](https://pi.dev)
  if you want to use it. The repository includes a Rosé Pine Moon theme, Calm,
  terminal-title, RTK, and model-status extensions, plus the packages listed in
  `home/.pi/agent/settings.json`.
- Pi's configured theme is `dark`. Change `theme` to `rose-pine-moon` in that file
  to use the included theme. Review the default provider, model, and thinking level
  for your own account.
- Inside Pi, `/calm` toggles Calm, `/resume-session` imports Claude Code or Codex
  sessions, and `/reload` reloads settings and extensions. Calm's toggle state stays
  local. Start `pi --verbose` to see loaded extensions when `quietStartup` is enabled.
- Web search uses `pi-web-search`. Do not enable `pi-web-access` alongside it:
  both define a `web_search` tool. The Codex fast-mode package is pinned to `0.2.6`.
- `home/.pi/agent/models.json` contains a personal LM Studio provider. Its
  `lm-studio` API key value is a placeholder for a server that does not require a
  key. Update the server address for your own setup.
- Real API keys, sign-ins, sessions, Pi MCP connections, and app runtime data are
  not included. Codex's `config.toml` and OpenCode's personal MCP/plugin settings
  are managed separately. Configure and authenticate these tools yourself.
- `home/AGENTS.md` contains shared instructions for Claude, Codex, and OpenCode,
  including personal CodeGraph and RTK rules. Review them before use.
- Zellij settings are stored in `home/.config/zellij/`, but its package and Home
  Manager link are disabled. To use the `ai-cli` alias, enable both and install the
  Cursor/Bun tools used by its layout.
- Apps are managed through Homebrew, with Codex, Claude Code, and CodeGraph declared
  as npm packages and OpenCode supplied by `anomalyco/tap`. `home.packages` is empty
  to avoid installing duplicate Nix copies.
- Both `~/.wezterm.lua` and `~/.config/wezterm` point to the same WezTerm config.
  Home Manager does not generate a new `.zshrc` because `programs.zsh.enable` is
  `false`; Zsh still works through the linked file.
- A rebuild also repairs Homebrew's `_brew` Zsh completion link.
- Nix dependencies are pinned in `flake.lock`, and Neovim plugin versions in
  `lazy-lock.json`. Homebrew packages and Oh My Zsh Git downloads are not pinned;
  Pi package versions depend on the entries in `settings.json`.

</details>

## Checks for contributors

These checks do not apply the configuration to your Mac. Use Python 3.11 or newer
for the Python tests:

```sh
python3 -B -m unittest discover -s tests -p 'test_*.py'
bash -n bootstrap.sh rebuild.sh
```

The bootstrap tests use temporary home folders and fake installation commands.
They do not install real packages. With Nix available, you can also evaluate the
configuration without applying it:

```sh
nix eval --raw .#darwinConfigurations.mac.system.drvPath
```

For the Pi Calm extension:

```sh
bash tests/pi-calm.test.sh
```

The Calm suite requires Node.js. If Pi is installed outside npm's global directory,
set `PI_CALM_TEST_PACKAGE_DIR` to the installed `@earendil-works/pi-coding-agent`
package directory. Additional checks need the installed Pi package, TypeScript,
or tmux; unavailable optional checks are skipped.

## Credits

Adapted from [kunchenguid/dotfiles](https://github.com/kunchenguid/dotfiles/tree/9a4a6387d0dd6f4bf9b8a5a732b406916bbbf95d).
The shell aliases and Neovim configuration are personal; the WezTerm appearance
and several supporting configurations come from that repository. See [`LICENSE`](LICENSE).

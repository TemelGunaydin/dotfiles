{ config, user, ... }:

let
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
in
{
  home.username = user;
  home.homeDirectory = "/Users/${user}";
  home.stateVersion = "24.11";
  # Applications are declared under homebrew in configuration.nix.
  # Keep one installation source for each application.
  home.packages = [ ];

  # Preserve the existing zsh files and aliases instead of generating a .zshrc.
  # Oh My Zsh provides the existing plugins; .zshrc initializes Starship.
  programs.zsh.enable = false;

  # rebuild.sh points ~/.dotfiles at this checkout. Files remain editable here.
  home.file.".zshrc".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.zshrc";
  home.file.".zprofile".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.zprofile";
  home.file.".zshenv".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.zshenv";
  home.file.".wezterm.lua".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/wezterm/wezterm.lua";
  home.file.".config/wezterm".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/wezterm";
  home.file.".config/starship.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/starship.toml";

  home.file.".config/nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/nvim";
  # Link only the authored Herdr config; logs and sessions stay local.
  home.file.".config/herdr/config.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/herdr/config.toml";
  home.file.".claude/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.claude/settings.json";

  # Pi's credentials, MCP connections and session state remain local.
  home.file.".pi/agent/themes".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/themes";
  home.file.".pi/agent/extensions".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/extensions";
  # Only Sol, DeepSeek, and MiMo agent definitions are shared between Macs.
  home.file.".pi/agent/agents".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/agents";
  home.file.".pi/agent/models.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/models.json";
  home.file.".pi/agent/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/settings.json";

  home.file.".claude/CLAUDE.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
  home.file.".codex/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
  home.file.".config/opencode/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
}

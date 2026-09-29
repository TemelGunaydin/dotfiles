{ config, lib, user, ... }:

{
  # Determinate already manages the Nix daemon, so nix-darwin shouldn't.
  nix.enable = false;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "aarch64-darwin"; # use x86_64-darwin for Intel CPU

  system.primaryUser = user;
  users.users.${user} = {
    home = "/Users/${user}";
  };
  system.stateVersion = 6;
  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      KeyRepeat = 2;          # fast key repeat
      InitialKeyRepeat = 15;  # short delay before repeat
      _HIHideMenuBar = true;  # auto-hide the menu bar
      AppleShowAllExtensions = true;
    };
    dock.autohide = true;
    finder.FXPreferredViewStyle = "Nlsv";  # list view by default
    finder.CreateDesktop = false;          # clean desktop
    trackpad.Clicking = true;              # tap to click
  };
  nix-homebrew = {
    enable = true;
    inherit user;
    autoMigrate = true;
  };

  # Link brew completion from the pinned source, including after migration.
  system.activationScripts.postActivation.text = lib.mkAfter ''
    /bin/mkdir -p "${config.homebrew.prefix}/share/zsh/site-functions"
    /bin/ln -sfn "${config.nix-homebrew.package}/completions/zsh/_brew" \
      "${config.homebrew.prefix}/share/zsh/site-functions/_brew"
  '';

  homebrew = {
    enable = true;
    # Keep other installed applications and avoid upgrading during a rebuild.
    onActivation.cleanup = "none";
    onActivation.autoUpdate = false;
    onActivation.upgrade = false;

    taps = [ "anomalyco/tap" ];
    brews = [
      "bat"       # file previews and the existing zsh-bat plugin
      "eza"       # the existing ls alias
      "fd"        # fzf file discovery
      "fzf"
      "herdr"
      "jq"
      "lazygit"
      "neovim"
      "ripgrep"
      "rtk"       # used by the existing Pi extension
      "starship"
      # "zellij"    # the existing ai-cli alias
      "zoxide"    # the existing cd alias
      "anomalyco/tap/opencode"
    ];

    casks = [
      "wezterm"
      "font-hack-nerd-font" # requested by home/.config/wezterm/wezterm.lua
      "font-jetbrains-mono"
    ];

    # These CLIs are already installed with npm on this Mac.
    # Homebrew Bundle also restores npm packages on a fresh installation.
    extraConfig = ''
      npm "@openai/codex"
      npm "@anthropic-ai/claude-code"
      npm "@colbymchenry/codegraph"
    '';
  };
}

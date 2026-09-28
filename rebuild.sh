#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
DOTFILES_LINK="$HOME/.dotfiles"

if [[ "$(id -u)" == "0" ]]; then
  echo "Run ./rebuild.sh as your normal user; it invokes sudo when needed." >&2
  exit 1
fi

# Support a clone directly at ~/.dotfiles and preserve unrelated directories.
if [[ -e "$DOTFILES_LINK" && ! -L "$DOTFILES_LINK" ]]; then
  if [[ ! -d "$DOTFILES_LINK" || "$(cd "$DOTFILES_LINK" && pwd -P)" != "$DIR" ]]; then
    echo "$DOTFILES_LINK already exists and is not this checkout; it was preserved." >&2
    exit 1
  fi
else
  ln -sfn "$DIR" "$DOTFILES_LINK"
fi

if DARWIN_REBUILD_BIN="$(command -v darwin-rebuild)"; then
  exec sudo "$DARWIN_REBUILD_BIN" switch --flake "$DIR#mac"
elif NIX_BIN="$(command -v nix)"; then
  # First switch: use the release CLI to apply this repository's locked config.
  exec sudo "$NIX_BIN" run github:nix-darwin/nix-darwin/nix-darwin-26.05#darwin-rebuild -- \
    switch --flake "$DIR#mac"
else
  echo "Nix is not available. Run ./bootstrap.sh first." >&2
  exit 1
fi

#!/usr/bin/env bash
# Adapted from kunchenguid/dotfiles for this Mac's existing shell setup.
# Run once after cloning; use rebuild.sh for later changes.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This setup requires macOS." >&2
  exit 1
fi
if [[ "$(id -u)" == "0" ]]; then
  echo "Run ./bootstrap.sh as your normal user; it invokes sudo when needed." >&2
  exit 1
fi

echo "==> Step 1: Determinate Nix"
if ! command -v nix >/dev/null 2>&1; then
  if [[ ! -r /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
      | sh -s -- install --no-confirm
  fi
  # shellcheck disable=SC1091
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi
command -v nix >/dev/null 2>&1 || { echo "Open a new terminal and rerun ./bootstrap.sh." >&2; exit 1; }

echo "==> Step 2: macOS username"
REAL_USER="$(id -un)"
FLAKE_USER="$(sed -nE 's/^[[:space:]]*user = "([^"]+)";.*/\1/p' "$DIR/flake.nix" | head -n1)"
if [[ -z "$FLAKE_USER" ]]; then
  echo "Could not find the user setting in flake.nix." >&2
  exit 1
fi
if [[ "$FLAKE_USER" != "$REAL_USER" ]]; then
  echo "flake.nix targets '$FLAKE_USER'; the current account is '$REAL_USER'."
  read -r -p "Update flake.nix to use '$REAL_USER'? [y/N] " ANSWER
  if [[ "$ANSWER" != "y" && "$ANSWER" != "Y" ]]; then
    echo "Update the user setting in flake.nix before continuing." >&2
    exit 1
  fi
  sed -i '' -E "s/^([[:space:]]*user = \")[^\"]+(\";.*)/\1${REAL_USER}\2/" "$DIR/flake.nix"
fi

echo "==> Step 3: Oh My Zsh and existing plugins"
ensure_repo() {
  local url="$1" destination="$2"
  if [[ -d "$destination" ]]; then
    echo "    Keeping $destination"
  elif [[ -e "$destination" || -L "$destination" ]]; then
    echo "Expected a directory at $destination; existing file was preserved." >&2
    exit 1
  else
    git clone --depth 1 "$url" "$destination"
  fi
}
ensure_repo https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
ensure_repo https://github.com/zsh-users/zsh-autosuggestions.git "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
ensure_repo https://github.com/zsh-users/zsh-syntax-highlighting.git "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
ensure_repo https://github.com/fdellwing/zsh-bat.git "$HOME/.oh-my-zsh/custom/plugins/zsh-bat"

echo "==> Step 4: apply this repository"
exec "$DIR/rebuild.sh"

[[ -r "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"

# Default editor for terminal tools, including Herdr's scrollback viewer.
export EDITOR="nvim"
export VISUAL="nvim"

path=("$HOME/.local/bin" $path)
export PATH

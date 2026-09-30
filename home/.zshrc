# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"
export CODEX_HOME="$HOME/.codex"
# export COLORTERM=truecolor
# export TERM="xterm-256color"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="" # Starship renders the prompt; Oh My Zsh still loads the plugins.

ZSH_DISABLE_COMPFIX=true
zstyle ':omz:update' mode disabled

plugins=(git zsh-autosuggestions zsh-bat zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

 alias ohmyzsh="mate ~/.oh-my-zsh"


 #acik olan port goruntuleme ve PID ogrenme
 alias port="lsof -nP -iTCP:3000 -sTCP:LISTEN"

#
# convert below for fish config
alias ls="eza --color=always --long --git --no-filesize --icons=always --no-time --no-user --no-permissions"
if [[ -t 0 && -t 1 ]] && command -v zoxide >/dev/null; then
  eval "$(zoxide init zsh)"
  alias cd="z"
fi

# ---- FZF -----

# Set up fzf key bindings and fuzzy completion
if [[ -t 0 && -t 1 ]]; then
  [[ -r /opt/homebrew/opt/fzf/shell/completion.zsh ]] && source /opt/homebrew/opt/fzf/shell/completion.zsh
  [[ -r /opt/homebrew/opt/fzf/shell/key-bindings.zsh ]] && source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
fi


# -- Use fd instead of fzf --

export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

# Use fd (https://github.com/sharkdp/fd) for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git . "$1"
}

# --- setup fzf theme ---
fg="#CBE0F0"
bg="#011628"
bg_highlight="#143652"
purple="#B388FF"
blue="#06BCE4"
cyan="#2CF9ED"

export FZF_DEFAULT_OPTS="--color=fg:${fg},bg:${bg},hl:${purple},fg+:${fg},bg+:${bg_highlight},hl+:${purple},info:${blue},prompt:${cyan},pointer:${cyan},marker:${cyan},spinner:${cyan},header:${cyan}"


show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"

export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments to fzf.
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo ${}'"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    *)            fzf --preview "$show_file_or_dir_preview" "$@" ;;
  esac
}

# Zellij AI CLI alias
alias ai-cli='zellij --layout ai-coding'

export NVM_DIR="$HOME/.nvm"
if [[ -s "$NVM_DIR/nvm.sh" ]]; then
  nvm() {
    unset -f nvm
    . "$NVM_DIR/nvm.sh"
    nvm "$@"
  }
fi

path=("$HOME/.pixi/bin" $path)

# bun completions
[ -s "$HOME/.oh-my-zsh/completions/_bun" ] && source "$HOME/.oh-my-zsh/completions/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
path=("$BUN_INSTALL/bin" $path)
typeset -U path
export PATH

export PATH="$HOME/.local/bin:$PATH"

# opencode
export PATH="$HOME/.opencode/bin:$PATH"

# Added by LM Studio CLI (lms)
export PATH="$PATH:$HOME/.lmstudio/bin"
# End of LM Studio CLI section

export PATH=$PATH:$HOME/.maestro/bin

# kimi-code
export PATH="$HOME/.kimi-code/bin:$PATH"

# Prompt only; aliases and plugins above remain the existing configuration.
if [[ $TERM != "dumb" ]] && command -v starship >/dev/null; then
  eval "$(starship init zsh)"
fi

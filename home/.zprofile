
if [[ -d /opt/homebrew ]]; then
  export HOMEBREW_PREFIX="/opt/homebrew"
  export HOMEBREW_CELLAR="/opt/homebrew/Cellar"
  export HOMEBREW_REPOSITORY="/opt/homebrew"
  path=("/opt/homebrew/bin" "/opt/homebrew/sbin" $path)
  [[ -n "${MANPATH-}" ]] && export MANPATH="/opt/homebrew/share/man:$MANPATH"
  export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}"
fi


# Added by Toolbox App
path+=("$HOME/Library/Application Support/JetBrains/Toolbox/scripts")


# Setting PATH for Python 3.13
# The original version is saved in .zprofile.pysave
path=("/Library/Frameworks/Python.framework/Versions/3.13/bin" $path)

# Added by swiftly
[[ -r "$HOME/.swiftly/env.sh" ]] && . "$HOME/.swiftly/env.sh"

# >>> Codex installer >>>
path=("$HOME/.local/bin" $path)
# <<< Codex installer <<<

typeset -U path
export PATH

# ~/.zshrc — WSL-only interactive settings.
# OS-independent tool setup (fzf, zoxide, starship, conda, thefuck, ...)
# lives in shell/common and is sourced at the end.

# ---- History ----
HISTFILE=~/.zsh_history
HISTSIZE=2000
SAVEHIST=2000
setopt APPEND_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE

# ---- Completion ----
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select

# Terminal window title: user@host: dir
precmd() { print -Pn "\e]0;%n@%m: %~\a" }

# ---- Colors & aliases ----
if [ -x /usr/bin/dircolors ]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
  alias ls='ls --color=auto'
  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
  zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
fi
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# ---- WSL interop ----
# Open a file/URL with the Windows default app.
# Usage: winopen report.pdf  |  winopen img.png https://example.com
winopen() {
  if [ $# -eq 0 ]; then
    echo "usage: winopen <file-or-url>..." >&2
    return 1
  fi
  local f win
  for f in "$@"; do
    # wslpath converts Linux paths; URLs/Windows paths pass through unchanged
    win="$(wslpath -w "$f" 2>/dev/null || printf '%s' "$f")"
    cmd.exe /c start "" "$win" >/dev/null 2>&1
  done
}

# Windows host details, e.g. the $WIN shortcut to the Windows user profile
[ -f "$HOME/.config/secrets/windows.sh" ] && source "$HOME/.config/secrets/windows.sh"

# ---- Node ----
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # loads nvm
# nvm's bash_completion is bash-only and intentionally not loaded.

# OS-independent setup
source "$HOME/.config/zsh/common.zsh"

# ~/.zshrc — macOS-only interactive settings.
# OS-independent tool setup (fzf, zoxide, starship, conda, thefuck, ...)
# lives in shell/common and is sourced at the end.

# system
alias ls='ls -G'
alias ll='ls -lh'

# Create and edit prompt.txt in the current directory
pt() {
    touch prompt.txt && nvim prompt.txt
}

# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv zsh)"

# Roundtable UI shortcut
rtui() {
    conda activate roundtable && roundtable-ui
}

# OS-independent setup
source "$HOME/.config/zsh/common.zsh"

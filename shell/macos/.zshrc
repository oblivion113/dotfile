# fzf
export FZF_DEFAULT_OPTS_FILE="$HOME/.config/fzf/fzfrc"
export FZF_DEFAULT_COMMAND="fd --type file --hidden --color never --ignore-file '$HOME/.config/search/ignore'"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type directory --hidden --color never --ignore-file '$HOME/.config/search/ignore'"
source <(fzf --zsh)

# ripgrep
alias rgp='rg --hidden'

# zoxide
eval "$(zoxide init zsh)"
alias j=z

# starship
eval "$(starship init zsh)"

# neovim
alias v=nvim
alias vi=nvim
alias vim=nvim

# Create and edit prompt.txt in the current directory
pt() {
    touch prompt.txt && nvim prompt.txt
}

# system
alias ls='ls -G'
alias ll='ls -lh'

# conda: source the static shell script instead of the `conda init` hook —
# much faster at startup, and it does not activate the base environment
# (auto_activate_base is set to false as well). `conda` stays available
# for explicit use, e.g. rtui() below.
source "$HOME/miniconda3/etc/profile.d/conda.sh"

export PATH="$HOME/.local/bin:$PATH"

# Personal shell scripts
export PATH="$HOME/code/shutils:$PATH"

# Roundtable UI shortcut
rtui() {
    conda activate roundtable && roundtable-ui
}

#the fuck
eval $(thefuck --alias)

export PATH="/Library/TeX/texbin:$PATH"

# API keys live outside the repo in a stable XDG location; the repo's
# git-ignored secret/ folder only holds a backup copy.
[ -f "$HOME/.config/secrets/keys.sh" ] && source "$HOME/.config/secrets/keys.sh"

# shared agents venv python as default (takes precedence over conda base)
export PATH="$HOME/.agents/venv/bin:$PATH"

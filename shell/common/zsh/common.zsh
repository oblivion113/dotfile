# common.zsh — OS-independent interactive zsh setup, sourced from ~/.zshrc on
# macOS and WSL. Keep per-machine paths and functions out of this file.

# fzf (config and ignore list live at the same paths on every machine)
export FZF_DEFAULT_OPTS_FILE="$HOME/.config/fzf/fzfrc"
export FZF_DEFAULT_COMMAND="fd --type file --hidden --color never --ignore-file '$HOME/.config/search/ignore'"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type directory --hidden --color never --ignore-file '$HOME/.config/search/ignore'"
source <(fzf --zsh)

# ripgrep: include hidden files by default (still respects .gitignore)
alias rgp='rg --hidden'

# zoxide
eval "$(zoxide init zsh)"
alias j=z

# starship
eval "$(starship init zsh)"

# neovim is the only editor
alias v=nvim
alias vi=nvim
alias vim=nvim

# conda: source the static shell script instead of the `conda init` hook —
# faster at startup and does not activate base (auto_activate is false).
source "$HOME/miniconda3/etc/profile.d/conda.sh"

# thefuck
eval "$(thefuck --alias)"

# API keys live outside the repo in a stable XDG location; the repo's
# git-ignored secret/ folder only holds a backup copy.
[ -f "$HOME/.config/secrets/keys.sh" ] && source "$HOME/.config/secrets/keys.sh"

# Shared uv-managed venv, Agents' default python (must follow conda so it
# wins over the base environment).
export PATH="$HOME/.agents/venv/bin:$PATH"

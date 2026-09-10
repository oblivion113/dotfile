
eval "$(/opt/homebrew/bin/brew shellenv zsh)"

# User-installed binaries (agent CLIs, editor shims, uv tool links)
[ -d "$HOME/.local/bin" ] && PATH="$HOME/.local/bin:$PATH"

export PATH="/Library/TeX/texbin:$PATH"

# ~/.zprofile — login-shell PATH setup (ssh logins, `wsl.exe` launches).

if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# uv and cargo shims
. "$HOME/.local/bin/env"
. "$HOME/.cargo/env"

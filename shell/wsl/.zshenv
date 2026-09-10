# User-installed TeX Live 2026 (official installer; managed with tlmgr, never
# apt). In .zshenv so every shell — including non-interactive ssh shells —
# sees xelatex; mirrors the macOS TeX PATH in .zshenv.
if [ -d "$HOME/texlive/2026/bin/x86_64-linux" ] ; then
    PATH="$HOME/texlive/2026/bin/x86_64-linux:$PATH"
fi

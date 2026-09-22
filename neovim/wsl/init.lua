-- WSL-specific Neovim init. Platform differences only — everything that
-- holds across both machines lives in shared/init.lua.
--
-- This file is the entire contents of ~/.config/nvim/init.lua on WSL.

-- VimTeX: skim is unavailable, so we route viewing through the
-- ~/bin/vimtex-sumatra bridge into SumatraPDF on the Windows host.
-- Reverse search (PDF -> nvim) is impossible across the WSL/Windows boundary
-- and is intentionally not configured.
vim.g.vimtex_compiler_method = "latexmk"
vim.g.vimtex_quickfix_mode = 0
-- latexmk, continuous + callback. XeLaTeX is the default engine because CJK
-- documents are first-class here; the engine lives in the *_engines table,
-- NOT in options — VimTeX otherwise appends its own '-pdf' and overrides it.
-- Per-file override still works with a % !TEX program = ... magic comment.
vim.g.vimtex_compiler_latexmk_engines = {
  _ = "-xelatex",
  pdflatex = "-pdf",
  lualatex = "-lualatex",
  xelatex = "-xelatex",
}
vim.g.vimtex_compiler_latexmk = {
  callback = 1,
  continuous = 1,
  options = {
    "-verbose",
    "-file-line-error",
    "-synctex=1",
    "-interaction=nonstopmode",
  },
}
vim.g.vimtex_view_method = "general"
vim.g.vimtex_view_automatic = 1
vim.g.vimtex_view_general_viewer = vim.fn.expand("~/bin/vimtex-sumatra")
vim.g.vimtex_view_general_options = "@tex @line @pdf"
vim.g.vimtex_lv_desc = "LaTeX: forward search in PDF"

-- ripgrep: WSL does not yet provision ~/.config/search/ignore, so the few
-- noise-heavy paths get inlined as globs. Exported as a global so the
-- shared layer (loaded via dofile) can read it.
_G.rg_excludes = table.concat({
  '--glob "!**/.git/**"',
  '--glob "!miniconda3/**"',
  '--glob "!**/node_modules/**"',
}, " ")

-- Pull in every platform-agnostic plugin, setup, and keymap.
dofile(vim.fn.stdpath("config") .. "/shared/init.lua")

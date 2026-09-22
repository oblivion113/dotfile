-- macOS-specific Neovim init. Platform differences only — everything that
-- holds across both machines lives in shared/init.lua.
--
-- This file is the entire contents of ~/.config/nvim/init.lua on macOS.

-- VimTeX: use Skim for forward search; reverse search works in-process.
vim.g.vimtex_view_method = "skim"
vim.g.vimtex_view_automatic = 1
vim.g.vimtex_compiler_method = "latexmk"
vim.g.vimtex_quickfix_mode = 0
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
vim.g.vimtex_lv_desc = "LaTeX: view PDF at cursor"

-- texlab: Skim handles forward search on macOS; build/lint chktex settings
-- stay on every machine and live in shared/init.lua.

-- ripgrep follows the shared ~/.config/search/ignore policy; macOS
-- provisions this file via the zsh sync. Exported as a global so the
-- shared layer (loaded via dofile) can read it.
local search_ignore = vim.fn.shellescape(vim.fn.expand("~/.config/search/ignore"))
_G.rg_excludes = "--ignore-file " .. search_ignore

-- Pull in every platform-agnostic plugin, setup, and keymap.
dofile(vim.fn.stdpath("config") .. "/shared/init.lua")

-- Add the macOS-specific texlab forward search on top of the base config
-- set up by shared/init.lua. vim.lsp.config deep-merges, so this only adds
-- forwardSearch without disturbing the shared build/chktex settings.
vim.lsp.config("texlab", {
  settings = {
    texlab = {
      forwardSearch = {
        executable = "/Applications/Skim.app/Contents/SharedSupport/displayline",
        args = { "%l", "%p", "%f" },
      },
    },
  },
})

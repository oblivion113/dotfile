-- Shared Neovim configuration: every line that is byte-identical on macOS
-- and WSL lives here. Genuinely platform-specific behaviour (VimTeX viewer,
-- latexmk engines) is set BEFORE this file is loaded by the platform
-- init.lua, so the setup()s below see the correct context.

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- nvim-tree replaces netrw as the active file explorer.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.cursorline = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.smartindent = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.clipboard = "unnamedplus"
vim.opt.completeopt = "menuone,noselect,popup"
vim.opt.autocomplete = true
vim.opt.winborder = "rounded"
vim.opt.showcmd = true

-- Plugin set is identical on both machines, so versions are pinned once in
-- the shared nvim-pack-lock.json next to this file.
vim.pack.add({
"https://github.com/catppuccin/nvim",
"https://github.com/nvim-lualine/lualine.nvim",
"https://github.com/nvim-tree/nvim-web-devicons",
"https://github.com/nvim-tree/nvim-tree.lua",
"https://github.com/stevearc/aerial.nvim",
"https://github.com/ibhagwan/fzf-lua",
"https://github.com/lewis6991/gitsigns.nvim",
"https://github.com/nvim-treesitter/nvim-treesitter",
"https://github.com/neovim/nvim-lspconfig",
"https://github.com/stevearc/conform.nvim",
"https://github.com/folke/which-key.nvim",
"https://github.com/MeanderingProgrammer/render-markdown.nvim",
"https://github.com/iamcco/markdown-preview.nvim",
"https://github.com/lervag/vimtex",
})

require("catppuccin").setup({ flavour = "mocha" })
vim.cmd.colorscheme("catppuccin")

require("lualine").setup({
options = {
    theme = "catppuccin-mocha",
    globalstatus = true,
},
})

-- ripgrep follows the shared ~/.config/search/ignore policy on both
-- machines (provisioned everywhere by the shell sync), so nvim's file
-- finder and grep agree with the terminal fzf/fd setup.
local rg_excludes = "--ignore-file "
  .. vim.fn.shellescape(vim.fn.expand("~/.config/search/ignore"))

require("fzf-lua").setup({
  files = {
    cmd = "rg --files --hidden --color=never " .. rg_excludes,
  },
  grep = {
    rg_opts = "--hidden --column --line-number --no-heading --color=always --smart-case --max-columns=4096 "
      .. rg_excludes .. " -e",
  },
})
vim.keymap.set("n", "<leader>ff", function() require("fzf-lua").files() end, { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", function() require("fzf-lua").live_grep() end, { desc = "Grep files" })
vim.keymap.set("n", "<leader>fb", function() require("fzf-lua").buffers() end, { desc = "Find buffers" })
vim.keymap.set("n", "<leader>fh", function() require("fzf-lua").help_tags() end, { desc = "Find help tags" })

require("nvim-tree").setup({
  sync_root_with_cwd = true,
  update_focused_file = {
    enable = true,
  },
  filters = {
    dotfiles = false,
  },
})
vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", { desc = "Toggle file explorer" })

-- IDE-style symbol outline. For Markdown, headings become a collapsible tree.
require("aerial").setup({
  layout = {
    default_direction = "prefer_right",
    placement = "edge",
  },
})
vim.keymap.set("n", "<leader>o", "<cmd>AerialToggle<cr>", { desc = "Toggle document outline" })
vim.keymap.set("n", "]h", "<cmd>AerialNext<cr>", { desc = "Next heading or symbol" })
vim.keymap.set("n", "[h", "<cmd>AerialPrev<cr>", { desc = "Previous heading or symbol" })

require("gitsigns").setup()
require("which-key").setup()

pcall(function()
  require("render-markdown").setup({
    file_types = { "markdown" },
    completions = {
      lsp = { enabled = true },
    },
  })
end)

vim.keymap.set("n", "<leader>mr", "<cmd>RenderMarkdown toggle<cr>", { desc = "Toggle Markdown rendering" })

-- Full Markdown preview in the default web browser.
vim.g.mkdp_auto_start = 0
vim.g.mkdp_auto_close = 1
vim.g.mkdp_filetypes = { "markdown" }
vim.keymap.set("n", "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", { desc = "Preview Markdown in browser" })

local ts = require("nvim-treesitter")
ts.setup()

local ts_parsers = {
  "python", "c", "cpp", "rust", "javascript", "typescript",
  "tsx", "html", "css", "json", "lua", "bash", "markdown",
  "markdown_inline", "yaml", "latex", "bibtex",
}

vim.api.nvim_create_user_command("TSInstallMine", function()
  ts.install(ts_parsers)
end, {})

vim.api.nvim_create_autocmd("FileType", {
  pattern = {
    "python", "c", "cpp", "rust", "javascript", "typescript",
    "typescriptreact", "html", "css", "json", "lua", "sh", "bash", "markdown",
    "tex", "plaintex", "bib",
  },
  callback = function()
    pcall(vim.treesitter.start)
    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "tex", "plaintex" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.spell = true
    vim.opt_local.conceallevel = 2
    vim.opt_local.textwidth = 100
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "tex", "plaintex" },
  callback = function(event)
    local map = function(keys, command, description)
      vim.keymap.set("n", keys, command, { buffer = event.buf, desc = description })
    end

    map("<leader>lc", "<cmd>VimtexCompile<cr>", "LaTeX: toggle continuous build")
    map("<leader>lb", "<cmd>VimtexCompileSS<cr>", "LaTeX: build once")
    -- <leader>lv description text is set per-platform (mac: "view at cursor",
    -- wsl: "forward search in PDF"), so the physical viewer command stays one
    -- key but the which-key hint reflects what the viewer actually does.
    map("<leader>lv", "<cmd>VimtexView<cr>", vim.g.vimtex_lv_desc or "LaTeX: view in PDF")
    map("<leader>le", "<cmd>VimtexErrors<cr>", "LaTeX: show errors")
    map("<leader>ls", "<cmd>VimtexStatus<cr>", "LaTeX: compiler status")
    map("<leader>lk", "<cmd>VimtexStop<cr>", "LaTeX: stop compiler")
    map("<leader>lx", "<cmd>VimtexClean<cr>", "LaTeX: clean output")
  end,
})

require("conform").setup({
formatters_by_ft = {
    python = { "ruff_format" },
    c = { "clang_format" },
    cpp = { "clang_format" },
    rust = { "rustfmt" },
    javascript = { "prettier" },
    typescript = { "prettier" },
    typescriptreact = { "prettier" },
    html = { "prettier" },
    css = { "prettier" },
    tex = { "latexindent" },
    plaintex = { "latexindent" },
    bib = { "latexindent" },
},
})

vim.keymap.set("n", "<leader>cf", function()
require("conform").format({ async = true })
end, { desc = "Format buffer" })

vim.lsp.config("texlab", {
  settings = {
    texlab = {
      build = {
        onSave = false,
      },
      chktex = {
        onOpenAndSave = true,
        onEdit = true,
      },
    },
  },
})

local servers = {
"texlab",
"pyright",
"clangd",
"rust_analyzer",
"ts_ls",
"html",
"cssls",
}

for _, server in ipairs(servers) do
vim.lsp.enable(server)
end

vim.api.nvim_create_autocmd("LspAttach", {
callback = function(event)
    local map = function(keys, func)
    vim.keymap.set("n", keys, func, { buffer = event.buf })
    end

    map("gd", vim.lsp.buf.definition)
    map("gr", vim.lsp.buf.references)
    map("K", vim.lsp.buf.hover)
    map("<leader>rn", vim.lsp.buf.rename)
    map("<leader>ca", vim.lsp.buf.code_action)
    map("<leader>d", vim.diagnostic.open_float)

    vim.lsp.completion.enable(true, event.data.client_id, event.buf, {
    autotrigger = true,
    })
end,
})

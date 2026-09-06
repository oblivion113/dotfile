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

vim.pack.add({
"https://github.com/catppuccin/nvim",
"https://github.com/nvim-lualine/lualine.nvim",
"https://github.com/nvim-tree/nvim-web-devicons",
"https://github.com/nvim-tree/nvim-tree.lua",
"https://github.com/ibhagwan/fzf-lua",
"https://github.com/lewis6991/gitsigns.nvim",
"https://github.com/nvim-treesitter/nvim-treesitter",
"https://github.com/neovim/nvim-lspconfig",
"https://github.com/stevearc/conform.nvim",
"https://github.com/folke/which-key.nvim",
"https://github.com/MeanderingProgrammer/render-markdown.nvim",
"https://github.com/iamcco/markdown-preview.nvim",
})

require("catppuccin").setup({ flavour = "mocha" })
vim.cmd.colorscheme("catppuccin")

require("lualine").setup({
options = {
    theme = "catppuccin-mocha",
    globalstatus = true,
},
})

local rg_excludes = table.concat({
  '--glob "!**/.git/**"',
  '--glob "!miniconda3/**"',
  '--glob "!**/node_modules/**"',
}, " ")

require("fzf-lua").setup({
  files = {
    -- --hidden includes dot-directories; the glob rules still exclude selected ones.
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
  "markdown_inline", "yaml",
}

vim.api.nvim_create_user_command("TSInstallMine", function()
  ts.install(ts_parsers)
end, {})

vim.api.nvim_create_autocmd("FileType", {
  pattern = {
    "python", "c", "cpp", "rust", "javascript", "typescript",
    "typescriptreact", "html", "css", "json", "lua", "sh", "bash", "markdown",
  },
  callback = function()
    pcall(vim.treesitter.start)
    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.spell = true
    vim.opt_local.conceallevel = 2
    vim.opt_local.textwidth = 100
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
},
})

vim.keymap.set("n", "<leader>cf", function()
require("conform").format({ async = true })
end, { desc = "Format buffer" })

local servers = {
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

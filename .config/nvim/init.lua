vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("config.lazy")
require("config.lsp")
require("config.lualine")
require("config.none_ls")
require("config.cmp")
require("config.codeium")

require("mapping.fzf")

vim.o.background = "dark" -- or "light" for light mode
vim.cmd([[colorscheme gruvbox]])

vim.o.background = "dark" -- or "light"

vim.opt.tabstop = 4 -- número de colunas que um TAB ocupa (visual)
vim.opt.shiftwidth = 4 -- tamanho da indentação usada por comandos como >> e <<
vim.opt.expandtab = true -- converte TABs em espaços reais
vim.opt.softtabstop = 4 -- ao pressionar <Tab>, insere 4 espaços
vim.opt.smartindent = true -- autoindent inteligente ao iniciar linhas novas

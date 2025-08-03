require("config.lazy")

vim.o.background = "dark" -- or "light" for light mode
vim.cmd([[colorscheme gruvbox]])

vim.g.mapleader = " " -- isso vem no topo

vim.o.background = "dark" -- or "light"

vim.opt.tabstop = 4        -- número de colunas que um TAB ocupa (visual)
vim.opt.shiftwidth = 4     -- tamanho da indentação usada por comandos como >> e <<
vim.opt.expandtab = true   -- converte TABs em espaços reais
vim.opt.softtabstop = 4    -- ao pressionar <Tab>, insere 4 espaços
vim.opt.smartindent = true -- autoindent inteligente ao iniciar linhas novas

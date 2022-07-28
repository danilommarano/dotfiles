-- init.lua
-- Danilo M. Marano danilo.m.marano@protonmail.com

--[[ NeoVim Options ]]


-- 1. Variables

-- Set the colorscheme to gruvbox
vim.cmd('colorscheme gruvbox')



-- 2. Global Options (o)

-- Line numbers
vim.o.nu = true

-- After exiting NVim without saving, it will not ask if you want to restore
-- a pending change. For this you need to save your files constantly.
vim.o.backup = false

-- Start searching while typing
vim.o.incsearch = true



-- 3. Window Options (wo)

-- A line is displayed in the 80th character column
vim.wo.colorcolumn = '80'

-- Line goes of the screen instead wraping
vim.wo.wrap = false

-- When searching NVim ignore cases until you insert a capital letter



-- 4. Buffer Options (bo)

-- Tab character is 4 spaces long
tabsize = 4
vim.bo.tabstop = tabsize
vim.bo.softtabstop = tabsize
vim.bo.shiftwidth = tabsize

-- Convert Tab character to multiple spaces
vim.bo.expandtab = true

-- Enable smart indentation
vim.bo.smartindent = true

-- Disable swapfile for buffers
vim.bo.swapfile = false

-- Enable buffer text to be changed
vim.bo.modifiable = true

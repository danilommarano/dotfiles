-- vim.api.nvim_set_keymap(<mode>, <keymap>, <mapped_to>, {<options>})
local keymap = vim.api.nvim_set_keymap
local opts = { noremap = true }



-- 
keymap('n', '<c-s>', ':w<CR>', opts)


-- Telescope
-- 1. Finding files
keymap('n', '<leader>ff', '<cmd>Telescope find_files<cr>', opts)
keymap('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', opts)
keymap('n', '<leader>fb', '<cmd>Telescope buffers<cr>', opts)
keymap('n', '<leader>fh', '<cmd>Telescope help_tags<cr>', opts)

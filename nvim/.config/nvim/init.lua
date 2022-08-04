--     ____                                |
--    / __ \  ____ _   _____  _____  ____  | https://github.com/danilommarano
--   / / / / / __ `/  / ___/ / ___/ / __ \ | https://twitter.com/danilommarano
--  / /_/ / / /_/ /  / /    / /__  / /_/ / |
-- /_____/  \__,_/  /_/     \___/  \____/  |
--                                         |


-- Set leader key to space
vim.g.mapleader = ','

require('plugins')
require('options')
require('keybinds')


-- LSP configuration
require("nvim-lsp-installer").setup({
    automatic_installation = true, -- automatically detect which servers to install (based on which servers are set up via lspconfig)
    ui = {
        icons = {
            server_installed = "✓",
            server_pending = "➜",
            server_uninstalled = "✗"
        }
    }
})

local on_attach = function(client, buff)
    vim.keymap.set('n', 'gd', "<Cmd>lua vim.lsp.buf.definition()<CR>", nil, buff)
    vim.keymap.set('n', 'gD', "<Cmd>lua vim.lsp.buf.defindeclaration()<CR>", nil, buff)
    vim.keymap.set('n', 'K', "<Cmd>lua vim.lsp.buf.hover()<CR>", nil, buff)
    vim.keymap.set('n', 'gi', "<Cmd>lua vim.lsp.buf.implementation()<CR>", nil, buff)
    vim.keymap.set('n', '<C-k>', "<Cmd>lua vim.lsp.buf.signature_help()<CR>", nil, buff)
    vim.keymap.set('n', '<space>wa', "<Cmd>lua vim.lsp.buf.add_workspace_folder()<CR>", nil, buff)
    vim.keymap.set('n', '<space>wr', "<Cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", nil, buff)
    vim.keymap.set('n', '<space>D', "<Cmd>lua vim.lsp.buf.type_definition()<CR>", nil, buff)
    vim.keymap.set('n', '<space>rn', "<Cmd>lua vim.lsp.buf.rename()<CR>", nil, buff)
    vim.keymap.set('n', '<space>ca', "<Cmd>lua vim.lsp.buf.code_action()<CR>", nil, buff)
    vim.keymap.set('n', 'gr', "<Cmd>lua vim.lsp.buf.references()<CR>", nil, buff)
    vim.keymap.set('n', '<space>f', "<Cmd>lua vim.lsp.buf.formatting()<CR>", nil, buff)
end

local servers = { "pyright", "gopls" }

for _, server in pairs(servers) do
    require("lspconfig")[server].setup {
        on_attach = on_attach
    }
end




--     ____                                |
--    / __ \  ____ _   _____  _____  ____  | https://github.com/danilommarano
--   / / / / / __ `/  / ___/ / ___/ / __ \ | https://twitter.com/danilommarano
--  / /_/ / / /_/ /  / /    / /__  / /_/ / | https://
-- /_____/  \__,_/  /_/     \___/  \____/  | 
--                                         |


-- Set leader key to space
vim.g.mapleader = ' '

require('plugins')
require('options')
require('keybinds')

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

require("lspconfig").pyright.setup({})
require("lspconfig").gopls.setup({})


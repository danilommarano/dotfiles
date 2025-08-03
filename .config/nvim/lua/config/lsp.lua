-- lua/config/lsp.lua

require("mason").setup()
require("mason-lspconfig").setup()

local lspconfig = require("lspconfig")

lspconfig.lua_ls.setup({})

lspconfig.pyright.setup({
  capabilities = require("cmp_nvim_lsp").default_capabilities(),
})



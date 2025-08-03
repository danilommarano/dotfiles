-- lua/config/none_ls.lua
local null_ls = require("null-ls")

null_ls.setup({
  sources = {
    -- Formatters
    null_ls.builtins.formatting.prettier,     -- JS/TS/HTML/CSS
    null_ls.builtins.formatting.stylua,       -- Lua
    null_ls.builtins.formatting.black.with({extra_args={"--fast"}}),
  }
})

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.py",
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})


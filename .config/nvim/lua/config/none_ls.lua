local null_ls = require("null-ls")

null_ls.setup({
  sources = {
    -- Formatters
    null_ls.builtins.formatting.prettier,
    null_ls.builtins.formatting.stylua,
    null_ls.builtins.formatting.black.with({ extra_args = { "--fast" } }),

  },
})

vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})


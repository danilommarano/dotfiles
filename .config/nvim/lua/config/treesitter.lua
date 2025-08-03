-- lua/config/treesitter.lua
require("nvim-treesitter.configs").setup({
  ensure_installed = {
    "lua",
    "python",
    "bash",
    "javascript",
    "typescript",
    "html",
    "css",
    "json",
    "yaml",
    "markdown",
  },

  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },

  indent = {
    enable = true,
  },

  playground = {
    enable = true,
  },

  textobjects = {
    select = {
      enable = true,
      lookahead = true, -- Avança automaticamente para o próximo textobject

      keymaps = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
        ["aa"] = "@parameter.outer",
        ["ia"] = "@parameter.inner",
      },
    },
    move = {
      enable = true,
      set_jumps = true,
      goto_next_start = {
        ["]f"] = "@function.outer",
      },
      goto_previous_start = {
        ["[f"] = "@function.outer",
      },
    },
  },
})


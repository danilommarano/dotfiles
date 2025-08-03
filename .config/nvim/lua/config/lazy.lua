-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({
	spec = {

		-- Theming
		{ "nvim-tree/nvim-web-devicons", opts = {} },
		{ "ellisonleao/gruvbox.nvim", priority = 1000, config = true, opts = ... },
		{
			"nvim-lualine/lualine.nvim",
			dependencies = { "nvim-tree/nvim-web-devicons" },
		},
		{
			"lukas-reineke/indent-blankline.nvim",
			main = "ibl",
			---@module "ibl"
			---@type ibl.config
			opts = {},
		},

		-- LSP (Language Server Protocol)
		{
			"neovim/nvim-lspconfig",
			event = { "BufReadPre", "BufNewFile" },
		},
		{
			"williamboman/mason.nvim",
			build = ":MasonUpdate",
			config = true,
		},
		{
			"williamboman/mason-lspconfig.nvim",
			dependencies = { "williamboman/mason.nvim" },
		},
		{
			"nvimtools/none-ls.nvim",
			event = { "BufReadPre", "BufNewFile" },
			dependencies = { "nvim-lua/plenary.nvim" },
		},

		-- Autocomplete
		{
			"hrsh7th/nvim-cmp",
			event = "InsertEnter",
			dependencies = {
				"hrsh7th/cmp-buffer",
				"hrsh7th/cmp-path",
				"hrsh7th/cmp-nvim-lsp",
				"L3MON4D3/LuaSnip",
				"saadparwaiz1/cmp_luasnip",
				"rafamadriz/friendly-snippets",
			},
		},
		{
			"Exafunction/windsurf.nvim",
			dependencies = {
				"nvim-lua/plenary.nvim",
				"hrsh7th/nvim-cmp",
			},
		},
		-- Treesiter and Syntax
		{
			"nvim-treesitter/nvim-treesitter",
			build = ":TSUpdate",
			event = { "BufReadPost", "BufNewFile" },
			config = function()
				require("config.treesitter")
			end,
		},
		{
			"nvim-treesitter/nvim-treesitter-textobjects",
			lazy = true,
		},
		{
			"nvim-treesitter/playground",
			cmd = "TSPlaygroundToggle",
		},

		-- Comentários com `gc`
		{
			"numToStr/Comment.nvim",
			config = function()
				require("Comment").setup()
			end,
			event = "VeryLazy",
		},

		-- Surround (ys, ds, cs)
		{
			"tpope/vim-surround",
			event = "VeryLazy",
		},

		-- Fecha parênteses e aspas
		{
			"windwp/nvim-autopairs",
			event = "InsertEnter",
			config = function()
				require("nvim-autopairs").setup({})
			end,
		},

		-- Git
		-- -- Mostra alterações na margem (lado esquerdo)
		{
			"lewis6991/gitsigns.nvim",
			event = "BufReadPre",
			config = function()
				require("gitsigns").setup()
			end,
		},
		{
			"tpope/vim-fugitive",
			cmd = { "Git", "G" }, -- só carrega quando você usa o comando
		},

		-- Navigation
		{
			"ibhagwan/fzf-lua",
			dependencies = { "nvim-tree/nvim-web-devicons" },
			config = function()
				require("fzf-lua").setup({})
			end,
			cmd = "FzfLua", -- só carrega quando o comando é chamado
		},
	},

	-- Configure any other settings here. See the documentation for more details.
	-- colorscheme that will be used when installing plugins.
	install = { colorscheme = { "habamax" } },
	-- automatically check for plugin updates
	checker = { enabled = true },
})

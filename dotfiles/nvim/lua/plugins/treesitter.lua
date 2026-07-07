return {
    {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	branch = 'main',
	config = function()
	    local configs = require("nvim-treesitter.configs")
	    configs.setup({
		ensure_installed = {
		    "lua",
		    "vim",
		    "javascript",
		    "typescript",
		    "html",
		    "css",
		    "python",
		    "json",
		    "markdown",
		    "bash",
		},
		-- Install parsers synchronously (only applied to `ensure_installed`)
		sync_install = false,

		-- Automatically install missing parsers when entering buffer
		auto_install = true,

		-- List of parsers to ignore installing (or "all")
		ignore_install = {},
		highlight = {
		    enable = true,
		    additional_vim_regex_highlighting = false,
		},

		indent = {
		    enable = true,
		},

		incremental_selection = {
		    enable = true,
		    keymaps = {
			init_selection = "<C-space>",
			node_incremental = "<C-space>",
			scope_incremental = false,
			node_decremental = "<bs>",
		    },
		},

		textobjects = {
		    select = {
			enable = true,
			lookahead = true,
			keymaps = {
			    ["af"] = "@function.outer",
			    ["if"] = "@function.inner",
			    ["ac"] = "@class.outer",
			    ["ic"] = "@class.inner",
			},
		    },
		},
	    })
	end,
    },
}

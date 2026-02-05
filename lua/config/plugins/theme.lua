local init = function()
	vim.cmd("colorscheme tokyonight")
end

local opts = {
	style = "night",
	terminal_colors = true,
	transparent = true,
	styles = {
		comments = { italic = true },
		keywords = { italic = true },
		functions = {},
		variables = {},
		sidebars = "transparent",
		floats = "transparent",
	},
	dim_inactive = false,
	lualine_bold = true,
}

local config = function(_, opt)
	local tokyonight = require("tokyonight")
	tokyonight.setup(opt)
end

return {
	"folke/tokyonight.nvim",
	init = init,
	version = "*",
	enabled = true,
	lazy = false,
	opts = opts,
	config = config,
}

local opts = {
	auto_save = nil,
	disable_on_zoom = true,
	mux = "auto",
}

local keys = {
	{
		"<C-h>",
		mode = { "" },
		function()
			local navigator = require("Navigator")
			navigator.left()
		end,
		noremap = true,
		silent = true,
		desc = "move to the left mux pane",
	},
	{
		"<C-l>",
		mode = { "" },
		function()
			local navigator = require("Navigator")
			navigator.right()
		end,
		noremap = true,
		silent = true,
		desc = "move to the right mux pane",
	},
	{
		"<C-j>",
		mode = { "" },
		function()
			local navigator = require("Navigator")
			navigator.down()
		end,
		noremap = true,
		silent = true,
		desc = "move to the down mux pane",
	},
	{
		"<C-k>",
		mode = { "" },
		function()
			local navigator = require("Navigator")
			navigator.up()
		end,
		noremap = true,
		silent = true,
		desc = "move to the up mux pane",
	},
	{
		"<C-\\>",
		mode = { "" },
		function()
			local navigator = require("Navigator")
			navigator.previous()
		end,
		noremap = true,
		silent = true,
		desc = "move to the previous mux pane",
	},
}

return {
	"numToStr/Navigator.nvim",
	version = "*",
	enabled = true,
	lazy = true,
	event = { "VeryLazy" },
	cmd = {},
	ft = {},
	build = {},
	opts = opts,
	keys = keys,
}

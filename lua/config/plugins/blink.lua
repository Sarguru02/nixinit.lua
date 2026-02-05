local fn = vim.fn
local opts = {
	keymap = {
		preset = "default",
		["<C-l>"] = { "select_next", "fallback" },
		["Tab"] = nil,
		["<C-h>"] = { "select_prev", "fallback" },
	},

	appearance = {
		nerd_font_variant = "mono",
	},
	completion = { documentation = { auto_show = true } },
	sources = {
		default = { "lsp", "path", "snippets", "buffer" },
		providers = {
			cmdline = {
				name = "cmdline",
				enabled = function()
					return fn.has("win32") == 0
						or fn.getcmdtype() ~= ":"
						or not fn.getcmdline():match("^[%%0-9,'<>%-]*!")
				end,
				module = "blink.cmp.sources.cmdline",
			},
		},
	},
	cmdline = {
		enabled = true,
		completion = {
			list = {
				selection = {
					preselect = true,
					auto_insert = true,
				},
			},
			menu = {
				auto_show = true,
			},
			ghost_text = {
				enabled = false,
			},
		},
	},
	fuzzy = { implementation = "prefer_rust_with_warning" },
}

return {
	"saghen/blink.cmp",
	dependencies = { "rafamadriz/friendly-snippets" },
	version = "1.*",

	---@module 'blink.cmp'
	---@type blink.cmp.Config
	opts = opts,
	event = { "InsertEnter", "CmdlineEnter" },
	build = "cargo build --release",
}

return {
	"stevearc/conform.nvim",
	lazy = true,
	keys = {
		{
			"<leader>f",
			function()
				require("conform").format({ async = true, lsp_fallback = true })
			end,
			mode = "",
			desc = "[F]ormat buffer",
		},
	},
	opts = {
		notify_on_error = false,
		formatters_by_ft = {
			lua = { "stylua" },
			javascript = { { "prettierd" } },
			html = { "prettierd" },
			css = { "prettierd" },
			go = { "gofumpt" },
			json = { "prettierd" },
			yaml = { "yamlfmt" },
		},
	},
}

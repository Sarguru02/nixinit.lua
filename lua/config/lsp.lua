local lsp = vim.lsp
local diagnostic = vim.diagnostic
local keymap = vim.keymap

diagnostic.config({
	underline = true,
	virtual_text = true,
	severity_sort = true,
	float = { border = "rounded" },
})

local function toggle_lsp_for_buffer()
	local bufnr = 0
	local clients = vim.lsp.get_clients({ bufnr = bufnr })

	if #clients > 0 then
		-- LSP is active → stop & prevent reattach
		vim.b.lsp_disabled = true
		for _, client in ipairs(clients) do
			client.stop()
		end
		Snacks.notify.info("LSP disabled for this buffer")
	else
		-- LSP inactive → allow reattach
		vim.b.lsp_disabled = false

		-- Trigger re-evaluation
		vim.cmd("doautocmd FileType")

		Snacks.notify.info("LSP enabled for this buffer")
	end
end

local function on_attach(_, bufnr)
	local opts = { buffer = bufnr }

	keymap.set("n", "gd", function()
		Snacks.picker.lsp_definitions()
	end, opts)
	keymap.set("n", "gr", function()
		Snacks.picker.lsp_references()
	end, opts)
	keymap.set("n", "K", function()
		lsp.buf.hover({ border = "rounded", focusable = true })
	end, opts)
	keymap.set("n", "<leader>rn", lsp.buf.rename, opts)
	keymap.set("n", "<leader>ca", lsp.buf.code_action, opts)
	keymap.set("n", "<leader>e", diagnostic.open_float, opts)
	keymap.set("n", "<leader>l", toggle_lsp_for_buffer, opts)
end

local servers = {
	rust_analyzer = {
		cmd = { "rust-analyzer" },
		root_markers = { "cargo.toml", "cargo.lock" },
	},

	nixd = {
		cmd = { "nixd" },
		root_markers = { "flake.nix", "default.nix" },
	},

	lua_ls = {
		cmd = { "lua-language-server" },

		root_markers = {
			".luarc.json",
			".luarc.jsonc",
			".git",
		},

		filetypes = {
			"lua",
		},

		settings = {
			Lua = {
				diagnostics = {
					globals = { "vim" },
				},
				workspace = {
					checkThirdParty = false,
					library = vim.api.nvim_get_runtime_file("", true),
				},
			},
		},
	},
	vtsls = {
		filetypes = {
			"typescript",
			"typescriptreact",
			"javascript",
			"javascriptreact",
		},

		cmd = { "vtsls", "--stdio" },

		root_dir = function(bufnr, on_dir)
			local fname = vim.api.nvim_buf_get_name(bufnr)
			if fname == "" then
				return
			end

			-- do not enable in deno projects
			local deno = vim.fs.find({ "deno.json", "deno.jsonc" }, { path = fname, upward = true })[1]

			if deno then
				return
			end

			-- enable for node projects
			local pkg = vim.fs.find("package.json", { path = fname, upward = true })[1]

			if pkg then
				on_dir(vim.fs.dirname(pkg))
			end
		end,
	},

	hls = {
		cmd = { "haskell-language-server-wrapper", "--lsp" },
		filetypes = { "haskell", "lhaskell" },
		root_markers = {
			"stack.yaml",
			"cabal.project",
			"package.yaml",
			"hie.yaml",
			"flake.nix",
			".git",
		},
	},
}

for name, config in pairs(servers) do
	lsp.config(
		name,
		vim.tbl_extend("force", {
			on_attach = on_attach,
		}, config)
	)
end

for name, config in pairs(servers) do
	local fts = config.filetypes
	if fts and #fts > 0 then
		vim.api.nvim_create_autocmd("FileType", {
			pattern = fts,
			callback = function()
				if not lsp.is_enabled(name) then
					lsp.enable(name)
				end
			end,
		})
	end
end

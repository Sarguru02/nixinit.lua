local lsp = vim.lsp
local diagnostic = vim.diagnostic
local keymap = vim.keymap

local function executable(cmd)
	return vim.fn.executable(cmd) == 1
end

diagnostic.config({
	underline = true,
	virtual_text = true,
	severity_sort = true,
	float = { border = "rounded" },
})

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
end

local servers = {
	rust_analyzer = {
		root_markers = { "cargo.toml", "cargo.lock" },
	},

	nixd = {
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
      "lua"
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
		root_dir = function(bufnr, on_dir)
			-- avoid Deno projects
			if vim.fs.find({ "deno.json", "deno.jsonc" }, { path = fname, upward = true })[1] then
				return nil
			end
			local root_path = vim.fs.find("package.json", { path = vim.fn.getcwd(), upward = true, type = "file" })[1]
			if root_path then
				on_dir(vim.fn.fnamemodify(root_path, ":h"))
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
	local cmd = config.cmd
	local bin = type(cmd) == "table" and cmd[1] or type(cmd) == "string" and cmd or name

	if executable(bin) then
		lsp.config(
			name,
			vim.tbl_extend("force", {
				on_attach = on_attach,
			}, config)
		)

		lsp.enable(name)
  end
end

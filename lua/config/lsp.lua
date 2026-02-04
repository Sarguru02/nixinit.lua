print("entered lsp file")
local api = vim.api
local lsp = vim.lsp
local diagnostic = vim.diagnostic
local keymap = vim.keymap

local function executable(cmd)
  return vim.fn.executable(cmd) == 1
end

local function root_pattern(...)
  local patterns = { ... }

  return function(fname)
    for _, pat in ipairs(patterns) do
      local match = vim.fs.find(pat, {
        path = fname,
        upward = true,
      })[1]

      if match then
        return vim.fs.dirname(match)
      end
    end
  end
end

diagnostic.config({
  underline = true,
  virtual_text = true,
  severity_sort = true,
  float = { border = "rounded" },
})

local function on_attach(_, bufnr)
  local opts = { buffer = bufnr }

  keymap.set("n", "gd", lsp.buf.definition, opts)
  keymap.set("n", "gr", lsp.buf.references, opts)
  keymap.set("n", "K",  lsp.buf.hover, opts)
  keymap.set("n", "<leader>rn", lsp.buf.rename, opts)
  keymap.set("n", "<leader>ca", lsp.buf.code_action, opts)
end


local servers = {
  rust_analyzer = {
    root_markers = { "cargo.toml", "cargo.lock" }
  },

  nixd = {
    root_markers = {"flake.nix", "default.nix"}
  },

  lua_ls = {
    settings = {
      Lua = {
        diagnostics = { globals = { "vim" } },
        workspace = {
          checkThirdParty = false,
          library = api.nvim_get_runtime_file("", true),
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
      local root_path = vim.fs.find("package.json", {path = vim.fn.getcwd(), upward = true, type="file"})[1]
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
      ".git"
    },
  },
}

for name, config in pairs(servers) do
  local cmd = config.cmd
  local bin =
    type(cmd) == "table" and cmd[1]
    or type(cmd) == "string" and cmd
    or name

  if executable(bin) then
    lsp.config(name, vim.tbl_extend("force", {
      on_attach = on_attach,
    }, config))

    lsp.enable(name)
  end
end

require("config.opts")
require("config.lazy")
require("config.maps")
require("config.tabs")
require("config.lsp")


vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("sarguru-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "lua",
  group = vim.api.nvim_create_augroup("Lua_disable_single_quote", { clear = true }),
  callback = function()
    MiniPairs.unmap("i", "'", "''")
  end,
  desc = "Disable single quote Lua",
})

-- helper function to define keymaps for harpoon navigation
local keys_for_navigation = function(keys, num)
	for i = 1, num do
		table.insert(keys, {
			"<leader>" .. i,
			mode = { "n" },
			function()
				require("harpoon"):list():select(i)
			end,
			noremap = true,
			silent = true,
			desc = "navigate to harpoon file " .. i,
		})
	end
end

-- plugin keys
local keys = {
	{
		"<leader>a",
		mode = { "n" },
		function()
			require("harpoon"):list():add()
		end,
		noremap = true,
		silent = true,
		desc = "add file to harpoon",
	},
	{
		"<C-e>",
		mode = { "n" },
		function()
			local harpoon = require("harpoon")
			harpoon.ui:toggle_quick_menu(harpoon:list())
		end,
		noremap = true,
		silent = true,
		desc = "toggle harpoon quick menu",
	},
}

keys_for_navigation(keys, 4)

return {
	"ThePrimeagen/harpoon",
	version = "*",
	branch = "harpoon2",
	enabled = true,
	lazy = true,
	event = {},
	cmd = {},
	ft = {},
	build = {},
	keys = keys,
}

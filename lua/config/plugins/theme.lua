local init = function ()
  vim.cmd("colorscheme tokyonight")
end
-- plugin opts
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

-- plugin config function
local config = function (_, opts)
    -- for convenience
    local tokyonight = require("tokyonight")

    -- configure tokyonight
    tokyonight.setup(opts)
end

-- plugin keys

-- plugin configurations
return {
   "folke/tokyonight.nvim",
   init = init,
   version = "*",
   enabled = true,
   lazy = false,
   opts = opts,
   config = config,
}

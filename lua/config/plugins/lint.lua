return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local lint = require("lint")

    lint.linters_by_ft = {
      lua = { "luacheck" },
      yaml = { "yamllint" },
      yml = { "yamllint" },
      nix = { "deadnix", "nix" },
    }

    local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
      group = lint_augroup,
      callback = function()
        -- Check if linting is disabled globally or for this buffer
        if vim.g.lint_enabled == false or vim.b.lint_disabled then
          return
        end
        lint.try_lint()
      end,
    })

    -- Toggle nvim-lint function
    local toggle_lint = function()
      if vim.g.lint_enabled == false then
        vim.g.lint_enabled = true
        lint.try_lint()
        Snacks.notify.info("nvim-lint enabled !!!")
      else
        vim.g.lint_enabled = false
        vim.diagnostic.reset(nil, 0)
        Snacks.notify.info("nvim-lint disabled !!!")
      end
    end

    -- Add keybinding for toggling lint
    vim.keymap.set("n", "<leader>lt", toggle_lint, { desc = "Toggle nvim-lint" })
  end,
}

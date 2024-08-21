return {
  "johmsalas/text-case.nvim",
  dependencies = { "nvim-telescope/telescope.nvim" },
  config = function()
    require("textcase").setup({
      default_keymappings_enabled =false,
    })
    require("telescope").load_extension("textcase")
  end,
  keys = {
    { "g.", "<cmd>TextCaseOpenTelescope<CR>",         mode = { "n", "x" }, desc = "open telescope for text case change" },
    { "ga", "<cmd>TextCaseStartReplacingCommand<CR>", mode = { "n", "x" }, desc = "text case replace" },
  },
  cmd = {
    -- NOTE: The Subs command name can be customized via the option "substitute_command_name"
    "Subs",
    "TextCaseOpenTelescope",
    "TextCaseOpenTelescopeQuickChange",
    "TextCaseOpenTelescopeLSPChange",
    "TextCaseStartReplacingCommand",
  },
  -- If you want to use the interactive feature of the `Subs` command right away, text-case.nvim
  -- has to be loaded on startup. Otherwise, the interactive feature of the `Subs` will only be
  -- available after the first executing of it or after a keymap of text-case.nvim has been used.
  lazy = false,
}

return {
  "ThePrimeagen/refactoring.nvim",
  dependencies = {
    { "nvim-lua/plenary.nvim" },
    { "nvim-treesitter/nvim-treesitter" }
  },
  keys = {
    { "<leader>r",  function() require("refactoring").select_refactor() end,                           mode = { "n", "v" }, noremap = true, silent = true, expr = false, desc = "refactor" },
    { "<leader>rf", function() return require("refactoring").refactor("Extract Function To File") end, mode = { "n", "x" }, noremap = true, silent = true, expr = true,  desc = "refactor - extract Function To File" },
    { "<leader>rv", function() return require("refactoring").refactor("Extract Variable") end,         mode = { "n", "x" }, noremap = true, silent = true, expr = true,  desc = "refactor - extract Variable" },
    { "<leader>rI", function() return require("refactoring").refactor("Inline Function") end,          mode = { "n", "x" }, noremap = true, silent = true, expr = true,  desc = "refactor - inline Function" },
    { "<leader>ri", function() return require("refactoring").refactor("Inline Variable") end,          mode = { "n", "x" }, noremap = true, silent = true, expr = true,  desc = "refactor - inline Variable" },
  },
}

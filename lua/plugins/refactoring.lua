return {
  "ThePrimeagen/refactoring.nvim",
  dependencies = {
    { "nvim-lua/plenary.nvim" },
    { "nvim-treesitter/nvim-treesitter" }
  },
  keys = {
    { "<leader>r",  function() require("refactoring").select_refactor() end,            mode = { "n", "v" },      noremap = true, silent = true, expr = false, desc = "refactor" },
    { "<leader>rf", function() require("refactoring").refactor("Extract Function") end, mode = { "n", "x", "v" }, noremap = true, silent = true, expr = false, desc = "refactor - extract Function" },
    { "<leader>rv", function() require("refactoring").refactor("Extract Variable") end, mode = { "n", "x", "v" }, noremap = true, silent = true, expr = false, desc = "refactor - extract Variable" },
    { "<leader>rI", function() require("refactoring").refactor("Inline Function") end,  mode = { "n", "x", "v" }, noremap = true, silent = true, expr = false, desc = "refactor - inline Function" },
    { "<leader>ri", function() require("refactoring").refactor("Inline Variable") end,  mode = { "n", "x", "v" }, noremap = true, silent = true, expr = false, desc = "refactor - inline Variable" },
  },
}

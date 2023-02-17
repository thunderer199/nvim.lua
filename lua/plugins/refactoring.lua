return {
    "ThePrimeagen/refactoring.nvim",
    dependencies = {
        { "nvim-lua/plenary.nvim" },
        { "nvim-treesitter/nvim-treesitter" }
    },
    keys = {
      {
        "<leader>r",
        function()
          require("refactoring").select_refactor()
        end,
        mode = { "n", "v" },
        noremap = true,
        silent = true,
        expr = false,
      },
    },
}

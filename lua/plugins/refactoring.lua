return {
    "ThePrimeagen/refactoring.nvim",
    dependencies = {
        { "nvim-lua/plenary.nvim" },
        { "nvim-treesitter/nvim-treesitter" }
    },
    config = function()
        local refactoring = require('refactoring')

        vim.keymap.set("n", "<leader>rr", refactoring.select_refactor)
        vim.keymap.set("v", "<leader>rr", refactoring.select_refactor)
    end
}

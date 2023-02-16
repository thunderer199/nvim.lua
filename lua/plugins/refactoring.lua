return {
    "ThePrimeagen/refactoring.nvim",
    dependencies = {
        { "nvim-lua/plenary.nvim" },
        { "nvim-treesitter/nvim-treesitter" }
    },
    config = function()
        local refactoring = require('refactoring')

        vim.api.nvim_set_keymap("v", "<leader>re",
            [[ <Esc><Cmd>lua require('refactoring').refactor('Extract Function')<CR>]],
            { noremap = true, silent = true, expr = false })
        vim.api.nvim_set_keymap("v", "<leader>rv",
            [[ <Esc><Cmd>lua require('refactoring').refactor('Extract Variable')<CR>]],
            { noremap = true, silent = true, expr = false })
        vim.api.nvim_set_keymap("v", "<leader>ri",
            [[ <Esc><Cmd>lua require('refactoring').refactor('Inline Variable')<CR>]],
            { noremap = true, silent = true, expr = false })

        vim.keymap.set({"n", "v"}, "<leader>rr", refactoring.select_refactor)
    end
}

return {
    {
        'jose-elias-alvarez/typescript.nvim',
        config = function()
            local ts = require('typescript')
            ts.setup({})

            vim.keymap.set('n', '<leader>vo', function()
                ts.actions.organizeImports()
            end, { desc = 'Typescript Organize Imports' })
            vim.keymap.set('n', '<leader>vO', function()
                ts.actions.removeUnused()
            end, { desc = 'Typescript Remove Unused' })
            vim.keymap.set('n', '<leader>vf', function()
                ts.actions.fixAll()
            end, { desc = 'Typescript Fix All' })
            vim.keymap.set('n', '<leader>vi', function()
                ts.actions.addMissingImports()
            end, { desc = 'Typescript Add Missing Imports' })
        end
    },
    {
        "jellydn/typecheck.nvim",
        ft = { "javascript", "javascriptreact", "json", "jsonc", "typescript", "typescriptreact" },
        opts = {
            debug = true,
            mode = "quickfix", -- "quickfix" | "trouble"
        },
    }
}

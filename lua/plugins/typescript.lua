return {
    'jose-elias-alvarez/typescript.nvim',
    config = function()
        local ts = require('typescript')
        ts.setup({})

        vim.keymap.set('n', '<leader>vo', function()
            ts.actions.organizeImports()
        end)
        vim.keymap.set('n', '<leader>vf', function()
            ts.actions.fixAll()
        end)
        vim.keymap.set('n', '<leader>vi', function()
            ts.actions.addMissingImports()
        end)
    end
}

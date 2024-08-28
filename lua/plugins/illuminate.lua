return {
    'RRethy/vim-illuminate',
    event = "VeryLazy",
    config = function()
        local illuminate = require('illuminate');

        illuminate.configure({
            delay = 200,
            providers = {
                'lsp',
                'treesitter',
                'regex',
            },
            large_file_cutoff = 2000,
            filetypes_denylist = {
                'dirbuf',
                'dirvish',
                'fugitive',
                'oil',
                'telescope',
            },
            under_cursor = true,
            min_count_to_highlight = 2,
        })

        vim.keymap.set('n', ']]', illuminate.goto_next_reference,
            { noremap = true, silent = true, desc = 'Go to next reference' })
        vim.keymap.set('n', '[[', illuminate.goto_prev_reference,
            { noremap = true, silent = true, desc = 'Go to previous reference' })

        vim.api.nvim_set_hl(0, 'IlluminatedWordText', { link = 'Visual' })
        vim.api.nvim_set_hl(0, 'IlluminatedWordRead', { link = 'Visual' })
        vim.api.nvim_set_hl(0, 'IlluminatedWordWrite', { link = 'Visual' })
    end
}

return {
    'RRethy/vim-illuminate',
    event = "VeryLazy",
    opts = {
        delay = 200,
        large_file_cutoff = 2000,
        large_file_overrides = {
            -- providers: provider used to get references in the buffer, ordered by priority
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
            },
            under_cursor = true,
            min_count_to_highlight = 1,
        },
    },
    config = function(_, opts)
        local illuminate = require('illuminate');

        illuminate.configure(opts)

        vim.keymap.set('n', ']]', illuminate.goto_next_reference, { noremap = true, silent = true, desc = 'Go to next reference' })
        vim.keymap.set('n', '[[', illuminate.goto_prev_reference, { noremap = true, silent = true, desc = 'Go to previous reference' })

    end
}

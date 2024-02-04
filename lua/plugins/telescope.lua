return {
    'nvim-telescope/telescope.nvim',
    -- tag = '0.1.5',
    dependencies = {
        'nvim-lua/plenary.nvim',
        "nvim-telescope/telescope-live-grep-args.nvim",
    },
    config = function()
        local telescope = require('telescope')
        local lga_actions = require("telescope-live-grep-args.actions")
        local live_grep_args_shortcuts = require("telescope-live-grep-args.shortcuts")
        local builtin = require('telescope.builtin')


        telescope.setup {
            pickers = {
                colorscheme = {
                    enable_preview = true,
                },
            },
            extensions = {
                live_grep_args = {
                    auto_quoting = true, -- enable/disable auto-quoting
                    mappings = {
                        i = {
                            ["<C-k>"] = lga_actions.quote_prompt({ postfix = " --iglob " }),
                            ["<C-g>"] = lga_actions.quote_prompt({ postfix = " --hidden" })
                        },
                    },
                }
            }
        }
        telescope.load_extension("live_grep_args")

        vim.keymap.set('n', '<leader>fg', telescope.extensions.live_grep_args.live_grep_args, {})
        vim.keymap.set('n', '<leader>fh', live_grep_args_shortcuts.grep_word_under_cursor, {})
        vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
        vim.keymap.set('n', '<leader>fhh', builtin.help_tags, {})
        vim.keymap.set('n', '<leader>fd', builtin.diagnostics, {})
        vim.keymap.set('n', '<leader>fr', builtin.resume, {})

        vim.keymap.set('n', '<leader>fc', builtin.git_commits, {})
        vim.keymap.set('n', '<leader>fC', builtin.git_bcommits, {})
        vim.keymap.set('v', '<leader>fC', builtin.git_bcommits_range, {})

        vim.keymap.set('n', '<leader>fo', function()
            builtin.oldfiles({ cwd_only = true, shorten_path = true, })
        end)

        vim.keymap.set('n', '<leader>fm', builtin.marks)
        vim.keymap.set('n', '<leader>fws', builtin.lsp_workspace_symbols)
        vim.keymap.set('n', '<leader>fds', builtin.lsp_document_symbols)

        vim.keymap.set('n', '<leader>ft', builtin.treesitter)
        vim.keymap.set('n', '<leader>ftt', ':TodoTelescope<CR>')
        vim.keymap.set('n', '<leader>fS', builtin.colorscheme)

        vim.keymap.set('n', '<leader>fs', builtin.git_status)
        vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
    end
}

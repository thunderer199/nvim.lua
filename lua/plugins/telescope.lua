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

        local actions = require('telescope.actions')
        local actions_state = require('telescope.actions.state')

        local function open_diff_for_selected_commit()
            -- Open in diffview
            local entry = actions_state.get_selected_entry()
            -- close Telescope window properly prior to switching windows
            actions.close(vim.api.nvim_get_current_buf())
            vim.cmd((":DiffviewOpen %s^!"):format(entry.value))
        end

        telescope.setup {
            pickers = {
                colorscheme = {
                    enable_preview = true,
                },
                git_commits = {
                    mappings = {
                        i = {
                            ['<CR>'] = function() end,
                            ["<C-d>"] = open_diff_for_selected_commit,
                        },
                    },
                },
                git_bcommits = {
                    mappings = {
                        i = {
                            ['<CR>'] = function() end,
                            ["<C-d>"] = open_diff_for_selected_commit,
                        },
                    },
                },
                git_bcommits_range = {
                    mappings = {
                        i = {
                            ['<CR>'] = function() end,
                            ["<C-d>"] = open_diff_for_selected_commit,
                        },
                    },
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

        local get_git_cwd = function()
            local git_dir = require('telescope.utils').get_os_command_output({ 'git', 'rev-parse', '--show-toplevel' })
                [1]

            print(git_dir)
            return git_dir
        end

        vim.keymap.set('n', '<leader>fs', builtin.git_status)
        vim.keymap.set('n', '<leader>ff', function()
            local git_dir = get_git_cwd()
            if git_dir == nil then
                builtin.find_files()
            else
                builtin.git_files({ cwd = git_dir })
            end
        end)
    end
}

return {
    'nvim-telescope/telescope.nvim',
    -- tag = '0.1.5',
    dependencies = {
        'nvim-lua/plenary.nvim',
        "nvim-telescope/telescope-live-grep-args.nvim",
        { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
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

        local function copy_commit_hash()
            local entry = actions_state.get_selected_entry()
            actions.close(vim.api.nvim_get_current_buf())
            vim.fn.setreg('+', entry.value)
        end

        local noop = function() end

        telescope.setup {
            defaults = {
                mappings = {
                    i = {
                        ["<C-s>"] = actions.cycle_previewers_next,
                        ["<C-a>"] = actions.cycle_previewers_prev,
                    },
                },
            },
            pickers = {
                colorscheme = {
                    enable_preview = true,
                },
                git_commits = {
                    mappings = {
                        i = {
                            ['<CR>'] = noop,
                            ["<C-o>"] = open_diff_for_selected_commit,
                            ["<C-g>"] = function()
                                local entry = actions_state.get_selected_entry()
                                actions.close(vim.api.nvim_get_current_buf())
                                vim.cmd((":DiffviewOpen %s"):format(
                                    entry.value
                                ))
                            end,
                            ["<C-p>"] = copy_commit_hash,
                        },
                    },
                },
                git_bcommits = {
                    mappings = {
                        i = {
                            ['<CR>'] = noop,
                            ["<C-o>"] = open_diff_for_selected_commit,
                            ["<C-g>"] = function()
                                local entry = actions_state.get_selected_entry()
                                actions.close(vim.api.nvim_get_current_buf())
                                vim.cmd((":DiffviewOpen %s -- %s"):format(
                                    entry.value,
                                    vim.fn.expand('%:p')
                                ))
                            end,
                            ["<C-p>"] = copy_commit_hash,
                        },
                    },
                },
                git_bcommits_range = {
                    mappings = {
                        i = {
                            ['<CR>'] = noop,
                            ["<C-o>"] = open_diff_for_selected_commit,
                            ["<C-g>"] = function()
                                local entry = actions_state.get_selected_entry()
                                actions.close(vim.api.nvim_get_current_buf())
                                vim.cmd((":DiffviewOpen %s -- %s"):format(
                                    entry.value,
                                    vim.fn.expand('%:p')
                                ))
                            end,
                            ["<C-p>"] = copy_commit_hash,
                        },
                    },
                },
                git_branches = {
                    mappings = {
                        i = {
                            ['<CR>'] = noop,
                            ['<C-r>'] = noop,
                            ['<C-t>'] = noop,
                            ['<C-a>'] = noop,
                            ['<C-s>'] = noop,
                            ['<C-y>'] = noop,
                            ['<C-d>'] = noop,
                            ['<C-o>'] = function()
                                local entry = actions_state.get_selected_entry()
                                actions.close(vim.api.nvim_get_current_buf())
                                vim.cmd((":DiffviewOpen %s"):format(entry.value))
                            end,
                            ['<C-f>'] = function()
                                local entry = actions_state.get_selected_entry()
                                actions.close(vim.api.nvim_get_current_buf())
                                vim.cmd((":DiffviewOpen %s -- %s"):format(
                                    entry.value,
                                    vim.fn.expand('%:p')
                                ))
                            end,
                        },
                    },
                },
            },
            extensions = {
                fzf = {
                    fuzzy = true,                   -- false will only do exact matching
                    override_generic_sorter = true, -- override the generic sorter
                    override_file_sorter = true,    -- override the file sorter
                    case_mode = "smart_case",       -- or "ignore_case" or "respect_case"
                },
                live_grep_args = {
                    auto_quoting = true, -- enable/disable auto-quoting
                    mappings = {
                        i = {
                            ["<C-l>"] = lga_actions.quote_prompt({ postfix = " --iglob " }),
                            ["<C-g>"] = lga_actions.quote_prompt({ postfix = " --hidden" })
                        },
                    },
                }
            }
        }
        telescope.load_extension("live_grep_args")
        telescope.load_extension("fzf")

        vim.keymap.set('n', '<leader>fg', telescope.extensions.live_grep_args.live_grep_args, {})
        vim.keymap.set('n', '<leader>fh', live_grep_args_shortcuts.grep_word_under_cursor, {})
        vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
        vim.keymap.set('n', '<leader>fB', builtin.git_branches, {})
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

        local util = require('vlad.util')

        vim.keymap.set('n', '<leader>fs', builtin.git_status)
        vim.keymap.set('n', '<leader>ff', function()
            local git_dir = util.get_git_cwd()
            if git_dir == nil then
                builtin.find_files()
            else
                builtin.find_files({ cwd = git_dir })
            end
        end)
    end
}

return {
    'nvim-telescope/telescope.nvim',
    -- tag = '0.1.5',
    dependencies = {
        'nvim-lua/plenary.nvim',
        "nvim-telescope/telescope-live-grep-args.nvim",
        { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
        'nvim-telescope/telescope-dap.nvim',
    },
    config = function()
        local telescope = require('telescope')
        local lga_actions = require("telescope-live-grep-args.actions")
        local live_grep_args_shortcuts = require("telescope-live-grep-args.shortcuts")
        local builtin = require('telescope.builtin')

        local actions = require('telescope.actions')
        local actions_state = require('telescope.actions.state')
        local actions_layout = require('telescope.actions.layout')
        local actions_set = require('telescope.actions.set')

        local function open_diff_for_selected_file()
            local entry = actions_state.get_selected_entry()
            actions.close(vim.api.nvim_get_current_buf())
            vim.cmd((":DiffviewOpen %s^! -- %s"):format(
                entry.value,
                vim.fn.expand('%:p')
            ))
        end

        local function open_selected_commit()
            -- Open in diffview
            local entry = actions_state.get_selected_entry()
            -- close Telescope window properly prior to switching windows
            actions.close(vim.api.nvim_get_current_buf())
            vim.cmd((":DiffviewOpen %s^!"):format(entry.value))
        end

        local function open_diff_between_selected_commit_and_head()
            -- Open in diffview
            local entry = actions_state.get_selected_entry()
            -- close Telescope window properly prior to switching windows
            actions.close(vim.api.nvim_get_current_buf())
            vim.cmd((":DiffviewOpen %s^..HEAD"):format(entry.value))
        end

        local function open_diff_between_selected_commit_and_head_for_file()
            -- Open in diffview
            local entry = actions_state.get_selected_entry()
            -- close Telescope window properly prior to switching windows
            actions.close(vim.api.nvim_get_current_buf())
            vim.cmd((":DiffviewOpen %s^..HEAD -- %s"):format(entry.value, vim.fn.expand('%:p')))
        end

        local function open_diff_between_selected_commit_and_current()
            -- Open in diffview
            local entry = actions_state.get_selected_entry()
            -- close Telescope window properly prior to switching windows
            actions.close(vim.api.nvim_get_current_buf())
            vim.cmd((":DiffviewOpen %s^"):format(entry.value))
        end

        local function open_diff_between_selected_commit_and_current_for_file()
            -- Open in diffview
            local entry = actions_state.get_selected_entry()
            -- close Telescope window properly prior to switching windows
            actions.close(vim.api.nvim_get_current_buf())
            vim.cmd((":DiffviewOpen %s^ -- %s"):format(entry.value, vim.fn.expand('%:p')))
        end

        local function copy_commit_hash()
            local entry = actions_state.get_selected_entry()
            actions.close(vim.api.nvim_get_current_buf())
            vim.fn.setreg('+', entry.value)
        end

        local function git_update_selected_branch()
            local entry = actions_state.get_selected_entry()
            actions.close(vim.api.nvim_get_current_buf())
            local upstream = entry.upstream
            if not upstream or upstream == "" then
                print("No upstream branch found")
                return
            end
            local local_branch = entry.value
            -- split the upstream branch into remote and branch name
            local remote, branch = unpack(vim.split(upstream, "/"))
            -- fetch the remote branch
            vim.fn.system(("git fetch %s %s"):format(remote, branch))

            vim.fn.system(("git fetch %s %s:%s"):format(remote, branch, local_branch))
            print(("Updated branch %s with %s"):format(local_branch, upstream))
        end

        local noop = function() end

        telescope.setup {
            defaults = {
                path_display = {
                    filename_first = true,
                },
                mappings = {
                    i = {
                        ["<C-s>"] = actions.cycle_previewers_next,
                        ["<C-a>"] = actions.cycle_previewers_prev,
                        ["<C-t>"] = actions_layout.toggle_preview,
                        ["<M-h>"] = actions.preview_scrolling_left,
                        ["<M-j>"] = actions.preview_scrolling_down,
                        ["<M-k>"] = actions.preview_scrolling_up,
                        ["<M-l>"] = actions.preview_scrolling_right,
                        ["<M-[>"] = function(prompt_bufnr)
                            actions_set.scroll_horizontal_results(prompt_bufnr, -1)
                        end,
                        ["<M-]>"] = function(prompt_bufnr)
                            actions_set.scroll_horizontal_results(prompt_bufnr, 1)
                        end
                    },
                },
            },
            pickers = {
                colorscheme = {
                    enable_preview = true,
                },
                buffers = {
                    mappings = {
                        i = {
                            ['<C-d>'] = actions.delete_buffer,
                        }
                    }
                },
                git_commits = {
                    mappings = {
                        i = {
                            ['<CR>'] = noop,
                            ["<C-o>"] = open_selected_commit,
                            ["<C-w>"] = open_diff_between_selected_commit_and_head,
                            ["<C-e>"] = open_diff_between_selected_commit_and_head_for_file,
                            ["<C-u>"] = open_diff_between_selected_commit_and_current,
                            ["<C-y>"] = open_diff_between_selected_commit_and_current_for_file,
                            ['<C-f>'] = open_diff_for_selected_file,
                            ["<C-p>"] = copy_commit_hash,
                        },
                    },
                },
                git_bcommits = {
                    mappings = {
                        i = {
                            ['<CR>'] = noop,
                            ["<C-o>"] = open_selected_commit,
                            ["<C-w>"] = open_diff_between_selected_commit_and_head,
                            ["<C-e>"] = open_diff_between_selected_commit_and_head_for_file,
                            ["<C-u>"] = open_diff_between_selected_commit_and_current,
                            ["<C-y>"] = open_diff_between_selected_commit_and_current_for_file,
                            ['<C-f>'] = open_diff_for_selected_file,
                            ["<C-p>"] = copy_commit_hash,
                        },
                    },
                },
                git_bcommits_range = {
                    mappings = {
                        i = {
                            ['<CR>'] = noop,
                            ["<C-o>"] = open_selected_commit,
                            ["<C-w>"] = open_diff_between_selected_commit_and_head,
                            ["<C-e>"] = open_diff_between_selected_commit_and_head_for_file,
                            ["<C-u>"] = open_diff_between_selected_commit_and_current,
                            ["<C-y>"] = open_diff_between_selected_commit_and_current_for_file,
                            ['<C-f>'] = open_diff_for_selected_file,
                            ["<C-p>"] = copy_commit_hash,
                        },
                    },
                },
                git_branches = {
                    mappings = {
                        i = {
                            ['<CR>'] = noop,
                            ['<C-p>'] = actions.git_switch_branch,
                            ['<C-a>'] = actions.git_create_branch,
                            ['<C-d>'] = actions.git_delete_branch,
                            ['<C-y>'] = actions.git_merge_branch,
                            ['<C-r>'] = actions.git_rebase_branch,
                            ['<C-u>'] = git_update_selected_branch,
                            ['<C-t>'] = noop,
                            ['<C-s>'] = noop,
                            ['<C-o>'] = function()
                                local entry = actions_state.get_selected_entry()
                                actions.close(vim.api.nvim_get_current_buf())
                                vim.cmd((":DiffviewOpen %s..HEAD"):format(entry.value))
                            end,
                            ['<C-f>'] = open_diff_for_selected_file,
                            ['<C-g>'] = function ()
                                local entry = actions_state.get_selected_entry()
                                actions.close(vim.api.nvim_get_current_buf())
                                vim.cmd((":DiffviewOpen %s..HEAD -- %s"):format(
                                    entry.value,
                                    vim.fn.expand('%:p')
                                ))

                            end
                        },
                    },
                },
                lsp_dynamic_workspace_symbols = {
                    mappings = {
                        i = {
                            ['<C-s>'] = actions.to_fuzzy_refine,
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
                            ["<C-g>"] = lga_actions.quote_prompt({ postfix = " --hidden" }),
                            ["<C-h>"] = lga_actions.quote_prompt({ postfix = " -F" })
                        },
                    },
                }
            }
        }
        telescope.load_extension("live_grep_args")
        telescope.load_extension("fzf")
        telescope.load_extension("dap")

        vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
        vim.keymap.set('n', '<leader>fB', builtin.git_branches, {})
        vim.keymap.set('n', '<leader>fD', builtin.diagnostics, {})
        vim.keymap.set('n', '<leader>fr', builtin.resume, {})
        vim.keymap.set('n', '<leader>fR', builtin.registers, {})

        vim.keymap.set('n', '<leader>fq', builtin.quickfix, {})
        vim.keymap.set('n', '<leader>fQ', builtin.quickfixhistory, {})

        vim.keymap.set('n', '<leader>fc', builtin.git_commits, {})
        vim.keymap.set('n', '<leader>fC', function(...)
            -- if current_path starts with oil:// then we need to remove it
            local current_path = vim.fn.expand('%:p:h')
            if string.find(current_path, "oil://") == 1 then
                current_path = string.sub(current_path, 7)
            else
                builtin.git_bcommits(...)
                return
            end

            -- remove git_base from current_path
            current_path = string.sub(current_path, string.len(require('vlad.util').get_git_cwd() or '/') + 2)
            builtin.git_commits({
                git_command = { "git", "log", "--pretty=oneline", "--", current_path }
            })
        end, {})
        vim.keymap.set('v', '<leader>fC', builtin.git_bcommits_range, {})

        vim.keymap.set('n', '<leader>fm', builtin.marks)
        vim.keymap.set('n', '<leader>fw', builtin.lsp_dynamic_workspace_symbols)
        vim.keymap.set('n', '<leader>fW', builtin.lsp_workspace_symbols)
        vim.keymap.set('n', '<leader>fd', builtin.lsp_document_symbols)

        vim.keymap.set('n', '<leader>ftt', builtin.treesitter)
        vim.keymap.set('n', '<leader>fT', ':TodoTelescope<CR>')
        vim.keymap.set('n', '<leader>fS', builtin.colorscheme)
        vim.keymap.set('n', '<leader>fs', builtin.git_status)

        vim.keymap.set('n', 'gs', function()
            builtin.lsp_document_symbols({
                symbols = { "function", "method", "class", "constructor" },
            })
        end, {})

        local util = require('vlad.util')
        local cwd = util.get_base_path()

        vim.keymap.set('n', '<leader>fg', function()
            telescope.extensions.live_grep_args.live_grep_args({ cwd = cwd })
        end, {})
        vim.keymap.set('n', '<leader>fh', function()
            live_grep_args_shortcuts.grep_word_under_cursor({ cwd = cwd })
        end, {})
        vim.keymap.set('v', '<leader>fh', function()
            live_grep_args_shortcuts.grep_visual_selection({ cwd = cwd })
        end, {})
        vim.keymap.set('n', '<leader>ff', function()
            builtin.find_files({ cwd = cwd })
        end)
        vim.keymap.set('n', '<leader>fo', function()
            builtin.oldfiles({ cwd = cwd, cwd_only = true, shorten_path = true, })
        end)
    end
}

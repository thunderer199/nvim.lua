return {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.0',
    dependencies = { { 'nvim-lua/plenary.nvim' }, { "nvim-telescope/telescope-live-grep-args.nvim" } },
    config = function()
        local telescope = require('telescope')
        local lga_actions = require("telescope-live-grep-args.actions")
        local builtin = require('telescope.builtin')


        telescope.setup {
            extensions = {
                live_grep_args = {
                    auto_quoting = true, -- enable/disable auto-quoting
                    -- define mappings, e.g.
                    mappings = {
                           -- extend mappings
                        i = {
                            ["<C-k>"] = lga_actions.quote_prompt(),
                            ["<C-g>"] = lga_actions.quote_prompt({ postfix = " --iglob " }),
                        },
                    },
                    -- ... also accepts theme settings, for example:
                    -- theme = "dropdown", -- use dropdown theme
                    -- theme = { }, -- use own theme spec
                    -- layout_config = { mirror=true }, -- mirror preview pane
                }
            }
        }
        telescope.load_extension("live_grep_args")

        vim.keymap.set('n', '<leader>fg', telescope.extensions.live_grep_args.live_grep_args, {})
        vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
        vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
        vim.keymap.set('n', '<leader>fd', builtin.diagnostics, {})

        vim.keymap.set('n', '<leader>fo', function()
            builtin.oldfiles({ cwd_only = true, shorten_path = true, })
        end)

        vim.keymap.set('n', '<leader>fm', builtin.marks)
        vim.keymap.set('n', '<leader>fws', builtin.lsp_workspace_symbols)
        vim.keymap.set('n', '<leader>fds', builtin.lsp_document_symbols)

        vim.keymap.set('n', '<leader>ft', builtin.treesitter)
        vim.keymap.set('n', '<leader>fc', builtin.colorscheme)

        local git_files_fallback_to_find_file = function()
            local opts = {} -- define here if you want to define something
            vim.fn.system('git rev-parse --is-inside-work-tree')
            if vim.v.shell_error == 0 then
                builtin.git_files({
                    show_untracked = true,
                })
            else
                builtin.find_files(opts)
            end
        end

        vim.keymap.set('n', '<leader>fs', builtin.git_status)
        vim.keymap.set('n', '<leader>ff', git_files_fallback_to_find_file, {})
    end
}

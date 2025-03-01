return {
    {
        import = 'plugins.languages',
    },
    {
        "folke/lazydev.nvim",
        priority = 100,
        ---@type lazydev.Config
        opts = {},
    },
    'nvim-tree/nvim-web-devicons',
    'AndrewRadev/linediff.vim',
    'tpope/vim-sleuth',
    {
        'machakann/vim-swap',
        keys = {
            { "g<", "<Plug>(swap-prev)",        desc = "Swap to previous buffer" },
            { "g>", "<Plug>(swap-next)",        desc = "Swap to next buffer" },
            { "gS", "<Plug>(swap-interactive)", desc = "Interactive buffer swap" },
        },
        init = function()
            vim.g.swap_no_default_key_mappings = 1
        end
    },
    {
        "OXY2DEV/markview.nvim",
        lazy = false
    },
    {
        "iamcco/markdown-preview.nvim",
        cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
        build = "cd app && npm install && git restore .",
        init = function()
            vim.g.mkdp_filetypes = { "markdown" }
        end,
        ft = { "markdown" },
    },
    { "windwp/nvim-autopairs",    config = true },
    {
        'brenoprata10/nvim-highlight-colors',
        config = true
    },
    { "folke/todo-comments.nvim", dependencies = "nvim-lua/plenary.nvim", config = true },
    {
        'goolord/alpha-nvim',
        dependencies = { { 'nvim-tree/nvim-web-devicons' } },
        lazy = false,
        keys = {
            { "<leader>al", '<cmd>Alpha<cr>' }
        },
        config = function()
            require 'alpha'.setup(require 'alpha.themes.startify'.config)
        end
    },
    {
        'mbbill/undotree',
        keys = {
            { "<leader>u", vim.cmd.UndotreeToggle, desc = "Toggle Undotree" },
        }
    },
    'wakatime/vim-wakatime',
    {
        'stevearc/oil.nvim',
        opts = {
            keymaps = {
                ['yp'] = {
                    desc = 'Copy full filepath to register',
                    callback = function ()
                        local val = require('oil').get_cursor_entry()
                        if not val then
                            return
                        end
                        local base_path = require('oil').get_current_dir()
                        vim.fn.setreg('0', base_path ..  val.name)
                    end,
                },
                ['ga'] = {
                    desc = 'Git add file to staging area',
                    callback = function ()
                        local val = require('oil').get_cursor_entry()
                        if not val then
                            return
                        end
                        local base_path = require('oil').get_current_dir()
                        local full_path = base_path ..  val.name

                        vim.cmd('!Git add ' .. full_path)
                        print('Added ' .. val.name .. ' to git staging area')
                    end,
                }
            },
            lsp_file_methods = {
                timeout_ms = 1000,
                autosave_changes = true,
            },
            view_options = {
                show_hidden = true,
            }
        },
        dependencies = { "nvim-tree/nvim-web-devicons" },
    },
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {
            delay = 2000,
        },
        keys = {
            {
                "<leader>?",
                function()
                    require("which-key").show({ global = false })
                end,
                desc = "Buffer Local Keymaps (which-key)",
            },
        },
    },
    {
        "kr40/nvim-macros",
        cmd = { "MacroSave", "MacroYank", "MacroSelect", "MacroDelete" },
        opts = {

            json_file_path = vim.fs.normalize(vim.fn.stdpath("config") .. "/macros.json"), -- Location where the macros will be stored
            default_macro_register = "q",                                                  -- Use as default register for :MacroYank and :MacroSave and :MacroSelect Raw functions
            json_formatter = "jq",                                                         -- can be "none" | "jq" | "yq" used to pretty print the json file (jq or yq must be installed!)
        }
    }
}

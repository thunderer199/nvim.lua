return {
    {
        import =  'plugins.languages' ,
    },
    {
        "folke/lazydev.nvim",
        priority = 100,
        opts = {},
    },
    'nvim-tree/nvim-web-devicons',
    'tpope/vim-sleuth',
    {
        'machakann/vim-swap',
        keys = {
            { "g<", "<Plug>(swap-prev)", desc = "Swap to previous buffer" },
            { "g>", "<Plug>(swap-next)", desc = "Swap to next buffer" },
            { "gS", "<Plug>(swap-interactive)", desc = "Interactive buffer swap" },
        },
        init = function()
            vim.g.swap_no_default_key_mappings = 1
        end
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
    { "windwp/nvim-autopairs",     config = true },
    {
        'norcalli/nvim-colorizer.lua',
        config = function()
            require'colorizer'.setup()
        end
    },
    { "folke/todo-comments.nvim",  dependencies = "nvim-lua/plenary.nvim", config = true },
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
        cmd = {"MacroSave", "MacroYank", "MacroSelect", "MacroDelete"},
        opts = {

            json_file_path = vim.fs.normalize(vim.fn.stdpath("config") .. "/macros.json"), -- Location where the macros will be stored
            default_macro_register = "q", -- Use as default register for :MacroYank and :MacroSave and :MacroSelect Raw functions
            json_formatter = "jq", -- can be "none" | "jq" | "yq" used to pretty print the json file (jq or yq must be installed!)

        }
    }
}

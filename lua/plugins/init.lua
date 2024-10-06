return {
    {
        "folke/lazydev.nvim",
        priority = 100,
        opts = {},
    },
    'nvim-tree/nvim-web-devicons',
    'tpope/vim-sleuth',
    {
        'jinh0/eyeliner.nvim',
        config = function()
            require 'eyeliner'.setup {
                highlight_on_key = true,
                dim = true,
                max_length = 9999,
                default_keymaps = true,
            }
        end
    },
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
    { 'NvChad/nvim-colorizer.lua', config = true },
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
    }
}

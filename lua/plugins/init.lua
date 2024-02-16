return {
    'nvim-tree/nvim-web-devicons',
    'windwp/nvim-ts-autotag',
    'tpope/vim-sleuth',
    {
        'github/copilot.vim',
        config = function()
            vim.g.copilot_filetypes = { ['*'] = true }
        end
    },
    { "windwp/nvim-autopairs",     config = true },
    { 'NvChad/nvim-colorizer.lua', config = true },
    { "folke/todo-comments.nvim",  dependencies = "nvim-lua/plenary.nvim", config = true },
    'mattn/emmet-vim',
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
    { 'mbbill/undotree', keys = { { "<leader>u", vim.cmd.UndotreeToggle } } },
    'wakatime/vim-wakatime',
    {
        'stevearc/oil.nvim',
        opts = {
            view_options = {
                show_hidden = true,
            }
        },
        dependencies = { "nvim-tree/nvim-web-devicons" },
    }
}

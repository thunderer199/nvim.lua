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
    { 'numToStr/Comment.nvim', event = "VeryLazy", config = true },
    { "windwp/nvim-autopairs", config = true },
    { 'NvChad/nvim-colorizer.lua', config = true },
    { "folke/todo-comments.nvim", dependencies = "nvim-lua/plenary.nvim", config = true },
    'mattn/emmet-vim',
    {
        'goolord/alpha-nvim',
        dependecies = { { 'nvim-tree/nvim-web-devicons' } },
        config = function()
            require 'alpha'.setup(require 'alpha.themes.startify'.config)
        end
    },
    { 'mbbill/undotree', keys = { { "<leader>u", vim.cmd.UndotreeToggle } } },
    'wakatime/vim-wakatime'
}

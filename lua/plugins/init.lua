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
    {
        'numToStr/Comment.nvim',
        event = "VeryLazy",
        config = true,
    },
    {
        "windwp/nvim-autopairs",
        config = true,
    },
    {
        'NvChad/nvim-colorizer.lua',
        config = true,
    },
    'mattn/emmet-vim',
    'tpope/vim-surround',
}

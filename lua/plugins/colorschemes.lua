return {
    'EdenEast/nightfox.nvim',
    'ellisonleao/gruvbox.nvim',
    'folke/tokyonight.nvim',
    { 'catppuccin/nvim', name = 'catppuccin', priority = 1000 },
    {
        'xiyaowong/transparent.nvim',
        lazy = false,
        config = function()
            require('transparent').clear_prefix('lualine')
        end
    }
}

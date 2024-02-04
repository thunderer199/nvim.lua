return {
    'EdenEast/nightfox.nvim',
    'ellisonleao/gruvbox.nvim',
    'folke/tokyonight.nvim',
    {
        'xiyaowong/transparent.nvim',
        lazy = false,
        config = function ()
            require('transparent').clear_prefix('lualine')
        end
    }
}

return {
    'EdenEast/nightfox.nvim',
    'ellisonleao/gruvbox.nvim',
    'folke/tokyonight.nvim',
    {
        'catppuccin/nvim',
        name = 'catppuccin',
        priority = 1000,
        opts = {

            custom_highlights = {
                LineNr = { fg = '#6e7891' },
            },
            integrations = {
                harpoon = true
            }
        }
    },
    {
        'xiyaowong/transparent.nvim',
        lazy = false,
        config = function()
            require('transparent').clear_prefix('lualine')
        end
    },
    -- Lua
    {
        "folke/zen-mode.nvim",
        opts = {
            -- your configuration comes here
            -- or leave it empty to use the default settings
            -- refer to the configuration section below
        }
    }
}

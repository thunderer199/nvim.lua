return {
    'EdenEast/nightfox.nvim',
    'ellisonleao/gruvbox.nvim',
    'folke/tokyonight.nvim',
    {
        "scottmckendry/cyberdream.nvim",
        lazy = false,
        priority = 1000,
        opts = {
            transparent = false,
            borderless_telescope = true,
            theme = {
                highlights = {
                    LineNr = { fg = '#6e7891' },
                    Visual = { bg = '#585c69' },
                }
            },
            extensions = {
                alpha = true,
                cmp = true,
                gitsigns = true,
                lazy = true,
                notify = true,
                telescope = true,
            }
        }
    },
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
            local transparent = require('transparent')
            transparent.setup({
                groups = {
                    'Normal',
                    'NormalNC',
                    'Comment',
                    'Constant',
                    'Special',
                    'Identifier',
                    'Statement',
                    'PreProc',
                    'Type',
                    'Underlined',
                    'Todo',
                    'String',
                    'Function',
                    'Conditional',
                    'Repeat',
                    'Operator',
                    'Structure',
                    'LineNr',
                    'NonText',
                    'SignColumn',
                    -- 'CursorLine',
                    -- 'CursorLineNr',
                    'StatusLine',
                    'StatusLineNC',
                    'EndOfBuffer',
                },
            })
            transparent.clear_prefix('lualine_b')
            transparent.clear_prefix('lualine_c')
            transparent.clear_prefix('lualine_x')
            transparent.clear_prefix('lualine_y')
            transparent.clear_prefix('trouble')
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

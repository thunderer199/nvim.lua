return {
    'phaazon/hop.nvim', 
    branch = 'v2',
    config = function()
        local hop = require 'hop'

        hop.setup { keys = 'etovxqpdygfblzhckisuran' }

        -- hop wor
        vim.keymap.set('', '<leader>l', function()
            hop.hint_words({ current_line_only = false })
        end, {remap=true})

        vim.keymap.set('', '<leader>;', function()
            hop.hint_char1({ current_line_only = false })
        end, {remap=true})
    end
}

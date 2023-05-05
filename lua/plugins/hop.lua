return {
    'phaazon/hop.nvim',
    branch = 'v2',
    keys = {
        { '<leader>l', ':HopWord<CR>' },
        { '<leader>;', ':HopChar2<CR>' },
    },
    config = function()
        local hop = require 'hop'

        hop.setup { keys = 'etovxqpdygfblzhckisuran' }
    end
}

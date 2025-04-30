return {
    'smoka7/hop.nvim',
    version = "*",
    keys = {
        { '<leader>;', ':HopWord<CR>',  desc = "Hop to word" },
        { 's',         ':HopChar1<CR>', desc = "Hop to char" },
        { '<leader>l', ':HopLineStart<CR>', desc = "Hop to line" },
    },
    opts = {},
}

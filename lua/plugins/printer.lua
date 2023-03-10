return {
    'rareitems/printer.nvim',
    keys = { 'gp' },
    config = function()
        local printer = require('printer')

        printer.setup({
            keymap = "gp",
            formatters = {
                vue = function(text_inside, text_var)
                    return string.format('console.log("%s = ", %s)', text_inside, text_var)
                end,
            },
        })
    end
}

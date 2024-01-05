return {
    'rareitems/printer.nvim',
    config = function()
        local printer = require('printer')

        printer.setup({
            keymap = "gp",
            formatters = {
                vue = function(text_inside, text_var)
                    return string.format('console.log("%s = ", %s)', text_inside, text_var)
                end,
                typescriptreact = function(text_inside, text_var)
                    return string.format('console.log("%s = ", %s)', text_inside, text_var)
                end,
            },
        })
    end
}

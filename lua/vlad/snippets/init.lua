local typescript = require('vlad.snippets.ft.typescript')
local ls = require("luasnip")

return {
    register = function()
        local ts_snippet_table = {}
        for key, value in pairs(typescript) do
            table.insert(ts_snippet_table, ls.snippet(key, value))
        end
        ls.add_snippets("typescript", ts_snippet_table)
        ls.add_snippets("typescriptreact", ts_snippet_table)
    end
}

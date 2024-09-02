local ls = require("luasnip")
local fmts = require("vlad.util").snippet_fmts

local i = ls.insert_node
local d = ls.dynamic_node
local sn = ls.snippet_node
local post = require("luasnip.extras.postfix").postfix

return {
  post('.if', {
    d(1, function(_, parent)
      return sn(1, fmts("if [condition]:\n\t[code]", { condition = parent.snippet.env.POSTFIX_MATCH, code = i(1) }))
    end)
  }),
  post('.try', {
    d(1, function(_, parent)
      return sn(1, fmts("try:\n\t[tryBlock]\nexcept Exception as e:\n\t[catchBlock]", {
        tryBlock = parent.snippet.env.POSTFIX_MATCH,
        catchBlock = i(1),
      }))
    end)
  }),
}

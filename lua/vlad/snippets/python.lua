local ls = require("luasnip")
local fmts = require("vlad.util").snippet_fmts

local i = ls.insert_node
local d = ls.dynamic_node
local sn = ls.snippet_node
local post = require("luasnip.extras.postfix").postfix

return {
  post('.if', {
    d(1, function(_, parent)
      return sn(
        1,
        fmts(
          "if "..parent.snippet.env.POSTFIX_MATCH ..":\n\t[condition]",
          { condition = i(1) }
        )
      )
    end)
  }),
}

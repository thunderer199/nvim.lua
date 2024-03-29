local ls = require "luasnip"

local i = ls.insert_node
local s = ls.snippet
local t = ls.text_node
local f = ls.function_node
local c = ls.choice_node

local fmt = require("luasnip.extras.fmt").fmt

local ret_filename = function()
  return vim.fn.expand('%:t:r')
end

ls.add_snippets("typescript", {
  s("vitest", {
    t({
      "import { describe, it, expect } from 'vitest';",
      "",
      "describe('" }),
    c(1, {
      f(ret_filename, {}),
      i(nil, "test"),
    }),
    t({ "', () => {",
    "  it('should work', () => {",
    "    ",
  }),
    i(2, "expect(true).toBe(true);"),
    t({
      "",
      "  });",
      "});"
    }),
  })

})

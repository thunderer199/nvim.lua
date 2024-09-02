local ls = require("luasnip")
local fmts = require("vlad.util").snippet_fmts

local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local s = ls.snippet
local d = ls.dynamic_node
local sn = ls.snippet_node
local post = require("luasnip.extras.postfix").postfix

local ret_filename = function()
  return vim.fn.expand('%:t:r')
end

local vitest = fmts(
  [[
import { describe, it, expect } from 'vitest';

describe('[describeName]', () => {
  it('should work', () => {
    [expectCode]
  });
});
  ]],
  {
    describeName = c(1, { f(ret_filename, {}), i(nil, "test") }),
    expectCode = i(2, "expect(true).toBe(true);"),
  }
);

local itvitest = fmts(
  [[
it('[itName]', async () => {
  [expectCode]
});
  ]],
  {
    itName = i(1, "should "),
    expectCode = i(2, "expect(true).toBe(true);"),
  }
);

return {
  s("vitest", vitest),
  s("itvitest", itvitest),
  post('.if', {
    d(1, function(_, parent)
      return sn(1, fmts("if ([condition]) {\n\t[code]\n}", {
        condition = parent.snippet.env.POSTFIX_MATCH,
        code = i(1, "code"),
      }))
    end)
  }),
  post('.try', {
    d(1, function(_, parent)
      return sn(1, fmts("try {\n\t[tryBlock]\n} catch (error) {\n\t[catchBlock]\n}", {
        tryBlock = parent.snippet.env.POSTFIX_MATCH,
        catchBlock = i(1, "catchBlock"),
      }))
    end)
  }),
}

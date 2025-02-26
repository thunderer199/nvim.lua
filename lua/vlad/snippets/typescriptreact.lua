local ls = require("luasnip")
local fmts = require("vlad.util").snippet_fmts
local fmt = require('luasnip.extras.fmt').fmt

local ts = require("vlad.snippets.typescript")

local i = ls.insert_node
local s = ls.snippet
local f = ls.function_node
local c = ls.choice_node

local function getComponentName()
  local filename = vim.fn.expand("%:t:r")
  return filename:gsub("^%l", string.upper)                   -- capitalize first letter
      :gsub("%-(%l)", string.upper):gsub("%-", "")            -- kebab to PascalCase, remove hyphens
end

local reactFuncComp = fmts(
  [[
import { FC } from 'react';

export interface [ComponentName]Props {
  [types]
}

export const [ComponentName]: FC<[ComponentName]Props> = ({ [props] }) => {
  return (
    <div>
      [cursor]
    </div>
  );
};
  ]],
  {
    ComponentName = c(1, { f(getComponentName, {}), i(nil, "Component") }),
    types = i(2),
    props = i(3),
    cursor = i(4),
  },
  {
    repeat_duplicates = true

  }
);

local reactFuncCompProp = fmts(
  [[
import { FC } from 'react';

export interface [ComponentName]Props {
  [types]
}

export const [ComponentName]: FC<[ComponentName]Props> = (props) => {
  const { [props] } = props;
  return (
    <div>
      [cursor]
    </div>
  );
};
  ]],
  {
    ComponentName = c(1, { f(getComponentName, {}), i(nil, "Component") }),
    types = i(2),
    props = i(3),
    cursor = i(4),
  },
  {
    repeat_duplicates = true
  }
);

local reactUseState = fmt(
  [[
    const [{getVal}, set{SetVal}] = useState({initialVal});
    ]],
  {
    getVal = i(1, "getVal"),
    initialVal = i(2, "initialVal"),
    SetVal = f(function(params)
      local args = params[1]
      return args[1]:sub(1, 1):upper() .. args[1]:sub(2)
    end, { 1 })
  },
  {
    repeat_duplicates = true
  }
);


local snippets = {
  s('rfc', reactFuncComp),
  s('rfcp', reactFuncCompProp),
  s('us', reactUseState),
}

return vim.list_extend(ts, snippets)

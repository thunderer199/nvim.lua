local ls = require("luasnip")
local fmts = require("vlad.util").snippet_fmts
local fmt = require('luasnip.extras.fmt').fmt

local ts = require("vlad.snippets.typescript")

local i = ls.insert_node
local s = ls.snippet
local f = ls.function_node


local reactFuncComp = fmts(
  [[
import React from 'react';

export interface [ComponentName]Props {
  [types]
}

export const [ComponentName]: React.FC<[ComponentName]Props> = ({ [props] }) => {
  return (
    <div>
      [cursor]
    </div>
  );
};
  ]],
  {
    ComponentName = i(1, "Component"),
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
import React from 'react';

export interface [ComponentName]Props {
  [types]
}

export const [ComponentName]: React.FC<[ComponentName]Props> = (props) => {
  const { [props] } = props;
  return (
    <div>
      [cursor]
    </div>
  );
};
  ]],
  {
    ComponentName = i(1, "Component"),
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

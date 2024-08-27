local ls = require("luasnip")
local fmts = require("vlad.util").snippet_fmts

local ts = require("vlad.snippets.typescript")

local i = ls.insert_node
local s = ls.snippet


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

local snippets = {
  s('rfc', reactFuncComp),
  s('rfcp', reactFuncCompProp),
}

return vim.list_extend(ts, snippets)

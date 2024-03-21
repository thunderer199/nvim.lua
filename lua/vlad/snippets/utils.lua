local fmt = require("luasnip.extras.fmt").fmt

local M = {}

local function fmts(str, args, opts)
    if not opts then
        opts = {}
    end
    return fmt(str, args, vim.tbl_extend("force", { delimiters = "[]" }, opts))
end

M.fmts = fmts

return M

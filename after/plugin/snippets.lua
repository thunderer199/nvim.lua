local luaship = require('luasnip');

vim.keymap.set("n", "<leader>]", function() luaship.jump(1) end)
vim.keymap.set("n", "<leader>[", function() luaship.jump(-1) end)

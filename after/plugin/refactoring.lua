local refactoring = require('refactoring')

vim.keymap.set("n", "<leader>rr", refactoring.select_refactor)
vim.keymap.set("v", "<leader>rr", refactoring.select_refactor)

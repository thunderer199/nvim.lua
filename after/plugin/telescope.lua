local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
vim.keymap.set('n', '<C-p>', builtin.git_files, {})

vim.keymap.set('n', '<leader>fo', function()
	builtin.oldfiles({ cwd_only = true, shorten_path = true, })
end)

vim.keymap.set('n', '<leader>fm', builtin.marks)
vim.keymap.set('n', '<leader>fws', builtin.lsp_workspace_symbols)
vim.keymap.set('n', '<leader>fds', builtin.lsp_document_symbols)

vim.keymap.set('n', '<leader>ft', builtin.treesitter)

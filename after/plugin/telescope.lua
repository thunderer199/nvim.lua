local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})

vim.keymap.set('n', '<leader>fo', function()
	builtin.oldfiles({ cwd_only = true, shorten_path = true, })
end)

vim.keymap.set('n', '<leader>fm', builtin.marks)
vim.keymap.set('n', '<leader>fws', builtin.lsp_workspace_symbols)
vim.keymap.set('n', '<leader>fds', builtin.lsp_document_symbols)

vim.keymap.set('n', '<leader>ft', builtin.treesitter)

local git_files_fallback_to_find_file = function()
	local opts = {} -- define here if you want to define something
	vim.fn.system('git rev-parse --is-inside-work-tree')
	if vim.v.shell_error == 0 then
		builtin.git_files(opts)
	else
		builtin.find_files(opts)
	end
end

vim.keymap.set('n', '<leader>ff', git_files_fallback_to_find_file, {})

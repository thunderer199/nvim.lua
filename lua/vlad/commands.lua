vim.api.nvim_create_user_command("CopyPath", function()
	local path = vim.fn.expand("%:p") -- Get absolute path
	local util = require('vlad.util')
	local relative_path = util.removeBaseFromPath(path)
	vim.fn.setreg("+", relative_path)
	vim.notify('Copied "' .. relative_path .. '" to the clipboard!')
end, {})

vim.api.nvim_create_user_command("CopyPathAbsolute", function()
	local path = vim.fn.expand("%:p") -- Get absolute path
	vim.fn.setreg("+", path)
	vim.notify('Copied "' .. path .. '" to the clipboard!')
end, {})

vim.keymap.set('n', '<leader>cp', ':CopyPath<CR>')
vim.keymap.set('n', '<leader>cP', ':CopyPathAbsolute<CR>')

vim.api.nvim_create_user_command("BuffersClose", function()
	local curr_buf = vim.api.nvim_get_current_buf()
	local bufs = vim.api.nvim_list_bufs()
	for _, buf in ipairs(bufs) do
		if buf ~= curr_buf then
			vim.api.nvim_buf_delete(buf, {})
		end
	end
end, {})

vim.api.nvim_create_user_command("CopyPath", function()
	local util = require('vlad.util')
	local git_cwd = util.get_git_cwd()
	local base_dir = vim.fn.getcwd()
	if git_cwd then
		base_dir = git_cwd
	end
	local path = vim.fn.expand("%:p") -- Get absolute path

	-- Ensure paths end with separator for proper replacement
	if base_dir:sub(-1) ~= '/' then
		base_dir = base_dir .. '/'
	end

	-- Remove the base directory from the path
	if path:sub(1, #base_dir) == base_dir then
		path = path:sub(#base_dir + 1)
	end
	vim.fn.setreg("+", path)
	vim.notify('Copied "' .. path .. '" to the clipboard!')
end, {})

vim.keymap.set('n', '<leader>cp', ':CopyPath<CR>')

vim.api.nvim_create_user_command("BuffersClose", function()
	local curr_buf = vim.api.nvim_get_current_buf()
	local bufs = vim.api.nvim_list_bufs()
	for _, buf in ipairs(bufs) do
		if buf ~= curr_buf then
			vim.api.nvim_buf_delete(buf, {})
		end
	end
end, {})

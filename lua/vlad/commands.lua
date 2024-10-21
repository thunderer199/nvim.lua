vim.api.nvim_create_user_command("CopyPath", function()
    local path = vim.fn.expand("%")
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

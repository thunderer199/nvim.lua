local function append_range(path, opts)
	if opts.range > 0 then
		return string.format("%s:%d-%d", path, opts.line1, opts.line2)
	end

	return path
end

vim.api.nvim_create_user_command("CopyPath", function(opts)
	local path = vim.fn.expand("%:p")
	local util = require("vlad.util")
	local relative_path = util.removeBaseFromPath(path)
	local path_with_range = append_range(relative_path, opts)
	vim.fn.setreg("+", path_with_range)
	vim.notify('Copied "' .. path_with_range .. '" to the clipboard!')
end, { range = true })

vim.api.nvim_create_user_command("CopyPathAbsolute", function(opts)
	local path = vim.fn.expand("%:p")
	local path_with_range = append_range(path, opts)
	vim.fn.setreg("+", path_with_range)
	vim.notify('Copied "' .. path_with_range .. '" to the clipboard!')
end, { range = true })

vim.keymap.set({ "n", "x" }, "<leader>cp", ":CopyPath<CR>")
vim.keymap.set({ "n", "x" }, "<leader>cP", ":CopyPathAbsolute<CR>")

vim.api.nvim_create_user_command("BuffersClose", function()
	local curr_buf = vim.api.nvim_get_current_buf()
	local bufs = vim.api.nvim_list_bufs()
	for _, buf in ipairs(bufs) do
		if buf ~= curr_buf then
			vim.api.nvim_buf_delete(buf, {})
		end
	end
end, {})

local function toggle_diff_ignore_whitespace()
	local diffopt = vim.opt.diffopt:get()
	local has_iwhite = vim.tbl_contains(diffopt, "iwhite")
	if has_iwhite then
		vim.opt.diffopt:remove("iwhite")
		vim.notify("Diff: now considering whitespace", vim.log.levels.INFO)
	else
		vim.opt.diffopt:append("iwhite")
		vim.notify("Diff: ignoring whitespace", vim.log.levels.INFO)
	end
end

vim.api.nvim_create_user_command(
	"DiffToggleWhitespace",
	toggle_diff_ignore_whitespace,
	{ desc = "Toggle ignoring whitespace in diffs" }
)

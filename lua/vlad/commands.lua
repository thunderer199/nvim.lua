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

vim.api.nvim_create_user_command("CopyPathContext", function()
	local path = vim.fn.expand("%:p")
	local util = require("vlad.util")
	local relative_path = util.removeBaseFromPath(path)

	local fn_name = nil
	local ok, ts_utils = pcall(require, "nvim-treesitter.ts_utils")
	if ok then
		local node = ts_utils.get_node_at_cursor()
		while node do
			local type = node:type()
			if
				type == "function_declaration"
				or type == "function_definition"
				or type == "method_definition"
				or type == "method_declaration"
				or type == "arrow_function"
				or type == "local_function"
			then
				local name_node = node:field("name")[1]
				if name_node then
					fn_name = vim.treesitter.get_node_text(name_node, 0)
				end
				break
			end
			node = node:parent()
		end
	end

	local result = fn_name and (relative_path .. "#" .. fn_name) or relative_path
	vim.fn.setreg("+", result)
	vim.notify('Copied "' .. result .. '" to the clipboard!')
end, {})

vim.keymap.set({ "n", "x" }, "<leader>cp", ":CopyPath<CR>")
vim.keymap.set({ "n", "x" }, "<leader>cP", ":CopyPathAbsolute<CR>")
vim.keymap.set("n", "<leader>cC", ":CopyPathContext<CR>")

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

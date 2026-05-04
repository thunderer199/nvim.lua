local function append_range(path, opts)
	if opts.range > 0 then
		if opts.line1 == opts.line2 then
			return string.format("%s:%d", path, opts.line1)
		end

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
	local node = vim.treesitter.get_node()
	if node then
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

local function smart_gf()
  -- Get the full word under cursor (may include :line, :start-:end or #L... fragments)
  local raw = vim.fn.expand("<cWORD>")

  -- Trim common trailing punctuation that appears in Markdown/links, e.g. ")", "]", ",", "." etc.
  raw = raw:gsub("[%)%]%.,;\"']+$", "")

  local file = raw
  local start_line, end_line

  -- Handle GitHub-style fragments like #L123 or #L123-L456 (allowing optional repeated L)
  local frag = raw:match("#(.+)$")
  if frag then
    -- GitHub-style: #L123-L456 or #L123-456 (range)
    local s, e = frag:match("^L(%d+)%-L?(%d+)$")
    if s then
      start_line = tonumber(s)
      end_line = tonumber(e)
    else
      -- Single line: #L123
      local s2 = frag:match("^L(%d+)$")
      if s2 then
        start_line = tonumber(s2)
      end
    end

    -- Remove the fragment from the file path
    file = raw:sub(1, #raw - #frag - 1)
  else
    -- Fallback to colon-style line/range like file:29 or file:29-36
    local before_colon, after_colon = raw:match("^(.-):(%d+.*)$")
    if before_colon then
      file = before_colon
      local s, e = after_colon:match("^(%d+)%-(%d+)$")
      if s then
        start_line = tonumber(s)
        end_line = tonumber(e)
      else
        start_line = tonumber(after_colon:match("^(%d+)"))
      end
    end
  end

  -- Open the file (creates new buffer if file doesn't exist)
  vim.cmd("edit " .. vim.fn.fnameescape(file))

  if start_line then
    vim.cmd("normal! " .. start_line .. "Gzz") -- go to start line and center

    if end_line and end_line > start_line then
      -- Range detected → enter Visual Line mode and select to end_line
      vim.cmd("normal! V" .. end_line .. "G")
    end
  end
end

-- Map gf to this smart function
vim.keymap.set("n", "gF", smart_gf, { noremap = true, silent = true, desc = "Go to file" })

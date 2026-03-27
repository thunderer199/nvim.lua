local state = {
	floating_terminal = {
		buf = -1,
		win = -1
	},
	suppress_cleanup_for_win = -1
}

local function create_floating_terminal(opts)
	opts = opts or {}
	local height = math.floor(vim.o.lines * 0.8)
	local width = math.floor(vim.o.columns * 0.8)

	-- in the center of the screen
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)


	local buf = nil
	if vim.api.nvim_buf_is_valid(opts.buf) then
		buf = opts.buf
	else
		buf = vim.api.nvim_create_buf(false, true) -- create a new empty buffer
	end

	local win = vim.api.nvim_open_win(buf, true, {
		relative = 'editor',
		width = width,
		height = height,
		row = row,
		col = col,
		style = 'minimal',
		border = 'rounded'
	})

	return {
		buf = buf,
		win = win
	}
end

local function cleanup_terminal(buf)
	if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == 'terminal' then
		vim.api.nvim_buf_delete(buf, { force = true })
	end

	if state.floating_terminal.buf == buf then
		state.floating_terminal.buf = -1
		state.floating_terminal.win = -1
	end
end

local function register_terminal_cleanup(win, buf)
	vim.api.nvim_create_autocmd('WinClosed', {
		once = true,
		pattern = tostring(win),
		callback = function()
			if state.suppress_cleanup_for_win == win then
				state.suppress_cleanup_for_win = -1

				if state.floating_terminal.win == win then
					state.floating_terminal.win = -1
				end

				return
			end

			cleanup_terminal(buf)
		end,
	})
end

local function toggle_terminal()
	if not vim.api.nvim_win_is_valid(state.floating_terminal.win) then
		state.floating_terminal = create_floating_terminal({ buf = state.floating_terminal.buf })
		register_terminal_cleanup(state.floating_terminal.win, state.floating_terminal.buf)

		if vim.bo[state.floating_terminal.buf].buftype ~= 'terminal' then
			vim.cmd.terminal()
		end
	else
		state.suppress_cleanup_for_win = state.floating_terminal.win
		vim.api.nvim_win_hide(state.floating_terminal.win)
	end
end

local function close_terminal()
	if vim.api.nvim_win_is_valid(state.floating_terminal.win) then
		vim.api.nvim_win_close(state.floating_terminal.win, true)
	elseif vim.api.nvim_buf_is_valid(state.floating_terminal.buf) then
		cleanup_terminal(state.floating_terminal.buf)
	end
end

vim.api.nvim_create_user_command("ToggleTerminal", function()
	toggle_terminal()
end, {})


vim.keymap.set('t', '<esc><esc>', function()
	vim.cmd('stopinsert')

	if vim.api.nvim_get_current_win() == state.floating_terminal.win then
		toggle_terminal()
	end
end, { noremap = true, silent = true })

vim.api.nvim_create_user_command('ExitTerminal', function()
	vim.cmd('stopinsert')
	close_terminal()
end, {})

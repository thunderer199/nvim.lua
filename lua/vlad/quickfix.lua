local function toggle_quickfix()
    local windows = vim.api.nvim_list_wins()
    local quickfix_open = false

    for _, window in pairs(windows) do
        if vim.api.nvim_win_get_config(window).relative == '' then
            local buf = vim.api.nvim_win_get_buf(window)
            if vim.bo[buf].buftype == 'quickfix' then
                quickfix_open = true
                break
            end
        end
    end

    if quickfix_open then
        vim.cmd('cclose')
    else
        vim.cmd('copen')
    end
end


vim.keymap.set("n", "<leader>tQ", toggle_quickfix)

vim.api.nvim_create_user_command("Cppath", function()
    local path = vim.fn.expand("%:p")
    vim.fn.setreg("+", path)
    vim.notify('Copied "' .. path .. '" to the clipboard!')
end, {})

vim.keymap.set('n', '<leader>cp', ':Cppath<CR>')

-- Angular files jump
vim.api.nvim_create_user_command("A", function(opts)
    local type = opts.args
    local path = vim.fn.expand("%:t:r")
    local path_with_ext = vim.fn.expand("%:t")
    local main_path = path
    print('a', path_with_ext)
    if path:find(".spec") then
        main_path = path:gsub(".spec", "")
    end

    if type == 'spec' then
        vim.fn.execute(":find " .. main_path .. ".spec.ts")
    elseif type == 'main' then
        vim.fn.execute(":find " .. main_path .. ".ts")
    elseif type == 'scss' then
        vim.fn.execute(":find " .. main_path .. ".scss")
    elseif type == 'html' then
        vim.fn.execute(":find " .. main_path .. ".html")
    elseif type == 'snapshot' then
        local snapshot_path = '__snapshots__/' .. main_path .. '.spec.ts.snap'
        vim.fn.execute(":find " .. snapshot_path)
    end
end, { nargs = 1 })
-- go to spec file
vim.keymap.set('n', '<leader>at', ':A spec<CR>')
-- got to componrny file
vim.keymap.set('n', '<leader>am', ':A main<CR>')
-- go to scss file
vim.keymap.set('n', '<leader>as', ':A scss<CR>')
-- go to html file
vim.keymap.set('n', '<leader>ah', ':A html<CR>')
--  go to snapshot file
vim.keymap.set('n', '<leader>an', ':A snapshot<CR>')

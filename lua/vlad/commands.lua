vim.api.nvim_create_user_command("CopyPath", function()
    local path = vim.fn.expand("%")
    vim.fn.setreg("+", path)
    vim.notify('Copied "' .. path .. '" to the clipboard!')
end, {})

vim.keymap.set('n', '<leader>cp', ':CopyPath<CR>')

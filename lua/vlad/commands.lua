vim.api.nvim_create_user_command("CopyPath", function()
    local path = vim.fn.expand("%")
    vim.fn.setreg("+", path)
    vim.notify('Copied "' .. path .. '" to the clipboard!')
end, {})

vim.keymap.set('n', '<leader>cp', ':CopyPath<CR>')

vim.api.nvim_create_user_command("InlayHintsToggle", function()
    if vim.lsp.inlay_hint.is_enabled({0}) then
        vim.lsp.inlay_hint.enable(false, {0})
    else
        vim.lsp.inlay_hint.enable(true, {0})
    end
end, {})

vim.keymap.set('n', '<leader>ih', ':InlayHintsToggle<CR>')

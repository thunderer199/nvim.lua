vim.api.nvim_create_augroup("HybridNumbers", { clear = true })
vim.api.nvim_create_autocmd(
    { "BufEnter", "FocusGained", "InsertLeave" },
    { command = "set relativenumber", group = "HybridNumbers" }
)
vim.api.nvim_create_autocmd(
    { "BufLeave", "FocusLost", "InsertEnter" },
    { command = "set norelativenumber", group = "HybridNumbers" }
)

vim.api.nvim_create_augroup("AutoSave", { clear = true })
vim.api.nvim_create_autocmd(
    { "FocusLost", "InsertLeave" },
    { command = "silent! wa", group = "AutoSave" }
)

-- Show errors and warnings in a floating window
vim.api.nvim_create_autocmd("CursorHold", {
    callback = function()
        -- get diagnostics for current buffer and line
        -- if the are more than one, show them in a floating window
        local diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line('.') - 1 })
        if #diagnostics <= 1 then
            return
        end
        vim.diagnostic.open_float(nil, { focusable = false, source = "if_many" })
    end,
})

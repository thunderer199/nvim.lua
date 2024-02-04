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

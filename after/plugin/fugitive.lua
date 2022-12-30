vim.keymap.set("n", "<leader>gs", vim.cmd.Git)
vim.keymap.set("n", "<leader>gd", vim.cmd.Gdiff)
vim.keymap.set("n", "<leader>gl", vim.cmd.Gclog)
vim.keymap.set("n", "<leader>gb", function() vim.cmd.Git("blame") end)


-- fugitive live grep
vim.keymap.set("n", "<leader>gg", function()
  vim.cmd.Git("grep -n --no-color -I -i -e " .. vim.fn.input("Grep for > "))
end)

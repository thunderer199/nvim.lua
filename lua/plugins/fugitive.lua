return {
    'tpope/vim-fugitive',
    keys = {
        { '<leader>gs', 'Git fugitive' }
    },
    config = function() 
        vim.keymap.set("n", "<leader>gs", vim.cmd.Git)
        vim.keymap.set("n", "<leader>gd", vim.cmd.Gdiff)
        vim.keymap.set("n", "<leader>gl", vim.cmd.Gclog)
        vim.keymap.set("n", "<leader>gb", function() vim.cmd.Git("blame") end)
        vim.keymap.set("n", "<leader>gB", function() vim.cmd.Git("branch") end)
        vim.keymap.set("n", "<leader>ge", vim.cmd.Gedit)


        local fugitive_cmd_group = vim.api.nvim_create_augroup("fugitive_cmd_group", {})

        local autocmd = vim.api.nvim_create_autocmd
        autocmd("BufWinEnter", {
            group = fugitive_cmd_group,
            pattern = "*",
            callback = function()
                if vim.bo.ft ~= "fugitive" then
                    return
                end

                local bufnr = vim.api.nvim_get_current_buf()
                local opts = { buffer = bufnr, remap = false }
                vim.keymap.set("n", "<leader>gp", function()
                    vim.cmd.Git('push')
                end, opts)

                -- rebase always
                vim.keymap.set("n", "<leader>gP", function()
                    vim.cmd.Git('pull --rebase')
                end, opts)

                vim.keymap.set("n", "<leader>gpu", function()
                    vim.cmd.Git('push -u origin HEAD')
                end, opts);
            end
        })
    end
}

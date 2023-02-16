return {
    'prettier/vim-prettier',
    keys = {
        { "<leader>p", ':PrettierAsync<CR>' },
        { "<leader>p", ":PrettierPartial<CR>",mode = "v" },
    }
}

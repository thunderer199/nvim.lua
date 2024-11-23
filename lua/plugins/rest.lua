return {
    {
        "rest-nvim/rest.nvim",
        lazy = false,
        keys = {
            { "<leader>R", ':Rest run<CR>', ft = { "http" } },
        },
        cmd = { "Rest" },
        init = function ()
            -- formatprg for json
            vim.cmd([[
                autocmd FileType json setlocal formatprg=jq\ --indent\ 4\ --tab
            ]])
        end,
        ---@type rest.Opts
        -- opts = {
        -- },
    },
}

return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
        bigfile = {
            enabled = true,
            notify = true,
        },
        -- notifier = { enabled = true },
        quickfile = { enabled = true },
        -- statuscolumn = { enabled = true },
        -- words = { enabled = true },
    },
    keys = {
        {
            "<leader>bd",
            function()
                ---@class snacks
                Snacks.bufdelete.other()
                print("Other Buffers Deleted")
            end,
            desc = "Delete other buffers",
        },
    }
}

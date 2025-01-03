return {
    {
        "jellydn/typecheck.nvim",
        ft = { "javascript", "javascriptreact", "json", "jsonc", "typescript", "typescriptreact" },
        opts = {
            debug = true,
            mode = "trouble", -- "quickfix" | "trouble"
        },
    },
    {
        "vuki656/package-info.nvim",
        event = "BufReadPre",
        dependencies = {
            "MunifTanjim/nui.nvim",

        },
        config = function()
            require("package-info").setup({

                hide_up_to_date = true,
                autostart = false,
                package_manager = "npm",
            })
            vim.api.nvim_create_user_command('PackageInfoToggle', function()
                require("package-info").toggle()
            end, {})
        end,
    },
}

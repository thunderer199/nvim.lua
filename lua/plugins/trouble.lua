return {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    -- vim.keymap.set("n", "<leader>xx", function() require("trouble").toggle() end)
    keys = {
        { "<leader>tt", function() require("trouble").toggle() end, mode = "n" },
        { "<leader>tw", function() require("trouble").toggle("workspace_diagnostics") end, mode = "n" },
        { "<leader>td", function() require("trouble").toggle("document_diagnostics") end, mode = "n" },
        { "gD", function() require('trouble').toggle("lsp_references") end, mode = "n" },
        { "gd", function() require('trouble').toggle("lsp_definitions") end, mode = "n" },
        { "gr", function() require('trouble').toggle("lsp_references") end, mode = "n" },
        { "gi", function() require('trouble').toggle("lsp_implementations") end, mode = "n" },
        { "gt", function() require('trouble').toggle("lsp_type_definitions") end, mode = "n" },
    },
    opts = {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
        mode = "workspace_diagnostics", -- "workspace_diagnostics", "document_diagnostics", "quickfix", "lsp_references", "loclist"

    },
}

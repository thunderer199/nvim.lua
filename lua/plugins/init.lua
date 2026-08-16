return {
    {
        import = 'plugins.languages',
    },
    {
        "folke/lazydev.nvim",
        priority = 100,
        ---@type lazydev.Config
        opts = {},
    },
    'nvim-tree/nvim-web-devicons',
    'AndrewRadev/linediff.vim',
    {
        "vuki656/review.nvim",
        cmd = "Review",
        opts = {
            templates = {
                { key = "t", label = "Types",          text = "Add proper types here; infer from usage and avoid `any`/loose types: " },
                { key = "e", label = "Error handling", text = "Add error handling; return typed errors and handle the failure path explicitly." },
                { key = "p", label = "Performance",    text = "Performance concern: avoid the redundant allocation/work here: " },
                { key = "s", label = "Simplify",       text = "Simplify this; reduce nesting, drop dead branches, and keep it readable." },
                { key = "x", label = "Extract",        text = "Extract this into a separate function/component with a clear, intention-revealing name." },
                { key = "n", label = "Naming",         text = "Rename for clarity to match the surrounding codebase conventions: " },
                { key = "u", label = "Edge case",      text = "Handle the null/empty/edge case here; cover it in the existing tests." },
                { key = "T", label = "Tests",          text = "Add tests for this behavior, including the failure path." },
                { key = "m", label = "Magic/dead",     text = "Replace this magic value / dead code with a named constant or remove it." },
                { key = "l", label = "Observability",  text = "Add structured logging/observability here for the failure path." },
                { key = "d", label = "Delete",         text = "Remove this; it is unused or duplicates existing logic." },
            },
        },
    },
    'tpope/vim-sleuth',
    {
        "kevinhwang91/nvim-fundo",
        dependencies = {
            "kevinhwang91/promise-async",
        },
        build = function()
            require("fundo").install()
        end,
        config = true,
        lazy = false,
        init = function()
            vim.opt.undofile = true
        end,
    },
    {
        'machakann/vim-swap',
        keys = {
            { "g<", "<Plug>(swap-prev)",        desc = "Swap to previous buffer" },
            { "g>", "<Plug>(swap-next)",        desc = "Swap to next buffer" },
            { "gS", "<Plug>(swap-interactive)", desc = "Interactive buffer swap" },
        },
        init = function()
            vim.g.swap_no_default_key_mappings = 1
        end
    },
    {
        "OXY2DEV/markview.nvim",
        priority = 40,
        lazy = false,
        config = {
            preview = {
                map_gx = false
            }
        }
    },
    {
        "iamcco/markdown-preview.nvim",
        cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
        build = "cd app && npm install && git restore .",
        init = function()
            vim.g.mkdp_filetypes = { "markdown" }
        end,
        ft = { "markdown" },
    },
    { "windwp/nvim-autopairs",    config = true },
    {
        'brenoprata10/nvim-highlight-colors',
        config = true
    },
    { "folke/todo-comments.nvim", dependencies = "nvim-lua/plenary.nvim", config = true },
    {
        'goolord/alpha-nvim',
        dependencies = { { 'nvim-tree/nvim-web-devicons' } },
        lazy = false,
        keys = {
            { "<leader>al", '<cmd>Alpha<cr>' }
        },
        config = function()
            require 'alpha'.setup(require 'alpha.themes.startify'.config)
        end
    },
    {
        'mbbill/undotree',
        keys = {
            { "<leader>u", vim.cmd.UndotreeToggle, desc = "Toggle Undotree" },
        }
    },
    'wakatime/vim-wakatime',
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {
            delay = function(ctx)
                if ctx.plugin == "spelling" then
                    return 20
                end
                if ctx.plugin == "marks" or ctx.plugin == "registers" then
                    return 1000
                end
                return 2000
            end,
        },
        keys = {
            {
                "<leader>?",
                function()
                    require("which-key").show({ global = false })
                end,
                desc = "Buffer Local Keymaps (which-key)",
            },
        },
    },
    {
        "kr40/nvim-macros",
        cmd = { "MacroSave", "MacroYank", "MacroSelect", "MacroDelete" },
        opts = {

            json_file_path = vim.fs.normalize(vim.fn.stdpath("config") .. "/macros.json"), -- Location where the macros will be stored
            default_macro_register = "q",                                                  -- Use as default register for :MacroYank and :MacroSave and :MacroSelect Raw functions
            json_formatter = "jq",                                                         -- can be "none" | "jq" | "yq" used to pretty print the json file (jq or yq must be installed!)
        }
    }
}

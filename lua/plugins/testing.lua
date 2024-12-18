return {
    "nvim-neotest/neotest",
    event = "VeryLazy",
    dependencies = {
        "nvim-neotest/nvim-nio",
        "nvim-lua/plenary.nvim",
        "antoinemadec/FixCursorHold.nvim",
        "nvim-treesitter/nvim-treesitter",

        -- adapters
        "marilari88/neotest-vitest",
        "nvim-neotest/neotest-jest",
        "nvim-neotest/neotest-python",
    },
    keys = {
        {
            '<leader>tn',
            function()
                require("neotest").run.run()
            end,
            desc = 'NeoTest: Run nearest test'
        },
        {
            '<leader>tf',
            function()
                require("neotest").run.run(vim.fn.expand("%"))
            end,
            desc = 'NeoTest: Run current file'
        },
        {
            '<leader>tl',
            function()
                require("neotest").run.run_last()
            end,
            desc = 'NeoTest: Run last file'
        },
        {
            '<leader>dt',
            function()
                require("neotest").run.run({ strategy = "dap" })
            end,
            desc = 'NeoTest: Debug nearest test'
        },
        {
            '<leader>ts',
            function()
                require("neotest").summary.toggle()
            end,
            desc = 'NeoTest: Open summary'
        },
        {
            '<leader>to',
            function()
                require("neotest").output.open({ enter = true })
            end,
            desc = 'NeoTest: Open output'
        }
    },
    config = function()
        local util = require("vlad.util")

        local vitestConfig = {
            vitestCommand = function(path)
                if vim.g.custom_test_config ~= nil and next(vim.g.custom_test_config) then
                    for _, value in pairs(vim.g.custom_test_config) do
                        if value.check(path) then
                            return value.vitest_cmd(path)
                        end
                    end
                end

                return "npx vitest"
            end,
            cwd = function(path)
                return util.find_parent_with_package_json(path)
            end,
            is_test_file = function(path)
                if path == nil then
                    return false
                end

                for _, x in ipairs({ "spec", "test", "api.test", "it" }) do
                    for _, ext in ipairs({ "js", "jsx", "coffee", "ts", "tsx" }) do
                        if string.match(path, "%." .. x .. "%." .. ext .. "$") then
                            return true
                        end
                    end
                end

                return false;
            end,
            filter_dir = function(name)
                return name ~= "node_modules" or name ~= "dist" or name ~= "build"
            end,
            vitestConfigFile = function(path)
                if vim.g.custom_test_config ~= nil and next(vim.g.custom_test_config) then
                    for _, value in pairs(vim.g.custom_test_config) do
                        if value.check(path) then
                            return value.cwd(path)
                        end
                    end
                end
                return vim.fn.getcwd() .. "/vitest.config.js"
            end,
        };

        local jestConfig = {
            jestCommand = "npx jest",
            env = { CI = true },
            cwd = function(path)
                return util.find_parent_with_package_json(path)
            end,
        };

        require('neotest').setup({
            quickfix = {
                enabled = false,
            },
            diagnostic = {
                enabled = true,
                severity = vim.diagnostic.severity.ERROR,
            },
            adapters = {
                require('neotest-jest')(jestConfig),
                require('neotest-vitest')(vitestConfig),
                require("neotest-python")({
                    dap = { justMyCode = true },
                    args = { "--log-level", "DEBUG" },
                    runner = "pytest",
                })

            }
        })
    end
}

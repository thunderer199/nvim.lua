return {
    "nvim-neotest/neotest",
    dependencies = {
        "nvim-neotest/nvim-nio",
        "nvim-lua/plenary.nvim",
        "antoinemadec/FixCursorHold.nvim",
        "nvim-treesitter/nvim-treesitter",

        -- adapters
        "marilari88/neotest-vitest",
        "nvim-neotest/neotest-jest",
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
        local find_parent_with_package_json = function(path)
            local current_path = path
            while current_path ~= "/" do
                local package_json = current_path .. "/package.json"
                if vim.fn.filereadable(package_json) == 1 then
                    return current_path
                end
                current_path = vim.fn.fnamemodify(current_path, ":h")
            end
            return nil
        end


        require('neotest').setup({
            adapters = {
                require('neotest-jest')({
                    jestCommand = "npx jest",
                    -- jestConfigFile = "custom.jest.config.ts",
                    env = { CI = true },
                    cwd = function(path)
                        return find_parent_with_package_json(path)
                    end,
                }),
                require('neotest-vitest')({
                    vitestCommand = "npx vitest",
                    cwd = function(path)
                        return find_parent_with_package_json(path)
                    end,
                    -- filter_dir = function(name, rel_path, root)
                    --     return name ~= "node_modules"
                    -- end,
                    -- is_test_file = function(path)
                    --     return true
                    -- end,
                    -- vitestConfigFile = function(path)
                    --     print("CHECKING", path)
                    --     for key, value in pairs(vim.g.vlad_custom_debug) do
                    --         if value.check(path) then
                    --             print('x', key)
                    --         end
                    --     end
                    --     print("CONFIG FILE", find_parent_with_package_json(path))
                    --     return vim.fn.getcwd() .. "/vitest.config.js"
                    -- end,
                })
            }
        })
    end
}

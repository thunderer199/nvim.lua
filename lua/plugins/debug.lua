return {
    {
        'mxsdev/nvim-dap-vscode-js',
        dependencies = {
            'mfussenegger/nvim-dap',
            'rcarriga/nvim-dap-ui',
            'theHamsta/nvim-dap-virtual-text',
        },
        config = function()
            require("nvim-dap-virtual-text").setup({
                enabled = true,
            })
            local dap = require("dap")
            local dapui = require("dapui")

            dapui.setup(
                {
                    layouts = {
                        {
                            elements = {
                                { id = "stacks",      size = 0.25 },
                                { id = "scopes",      size = 0.5 },
                                { id = "breakpoints", size = 0.25 },
                            },
                            position = "left",
                            size = 0.25
                        },
                        {
                            elements = { id = "watches", size = 0.25 },
                            position = "bottom",
                            size = 10,
                        }
                    },
                    mappings = {
                        edit = "e",
                        expand = { "<CR>", "<2-LeftMouse>" },
                        open = "o",
                        remove = "d",
                        repl = "r",
                        toggle = "t"
                    },
                    render = {
                        indent = 1,
                        max_value_lines = 100
                    }
                }
            );

            require("dap-vscode-js").setup({
                -- node_path = "node", -- Path of node executable. Defaults to $NODE_PATH, and then "node"
                -- debugger_path = "(runtimedir)/site/pack/packer/opt/vscode-js-debug", -- Path to vscode-js-debug installation.
                -- debugger_cmd = { "js-debug-adapter" }, -- Command to use to launch the debug server. Takes precedence over `node_path` and `debugger_path`.
                adapters = { 'pwa-node', 'pwa-chrome', 'pwa-msedge', 'node-terminal', 'pwa-extensionHost' }, -- which adapters to register in nvim-dap
                -- log_file_path = "(stdpath cache)/dap_vscode_js.log" -- Path for file logging
                -- log_file_level = false -- Logging level for output to file. Set to false to disable file logging.
                -- log_console_level = vim.log.levels.ERROR -- Logging level for output to console. Set to false to disable console output.
            })

            for _, language in ipairs({ "typescript", "javascript", "javascriptreact", "typescriptreact" }) do
                require("dap").configurations[language] = {
                    {
                        type = "pwa-node",
                        request = "launch",
                        name = "Launch file",
                        program = "${file}",
                        cwd = "${workspaceFolder}",
                    },
                    {
                        type = "pwa-node",
                        request = "attach",
                        name = "Attach",
                        processId = require 'dap.utils'.pick_process,
                        cwd = "${workspaceFolder}",
                    },
                    -- vitest run
                    {
                        type = "pwa-node",
                        request = "launch",
                        name = "Launch vitest",
                        program = "${workspaceFolder}/node_modules/vitest/vitest.mjs",
                        args = { "run", "${relativeFile}" },
                        cwd = "${workspaceFolder}",
                        sourceMaps = true,
                        skipFiles = { "<node_internals>/**", "**/node_modules/**" },
                        smartStep = true,
                        console = "integratedTerminal",
                    },
                }
            end


            dap.adapters["pwa-node"] = {
                type = "server",
                host = "localhost",
                port = "${port}",
                executable = {
                    command = "node",
                    args = {
                        vim.fn.stdpath('data') .. '/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js',
                        "${port}"
                    }
                }
            }

            vim.keymap.set('n', '<leader>dx', function() dap.continue() end)
            vim.keymap.set('n', '<leader>dX', function() dap.terminate() end)
            vim.keymap.set('n', '<leader>dz', function() dap.run_last() end)
            vim.keymap.set('n', '<leader>dI', function() dap.run_to_cursor() end)
            vim.keymap.set('n', '<leader>dR', function() dap.repl.open() end)
            vim.keymap.set('n', '<leader>dC', function() dapui.float_element('console') end)

            vim.keymap.set('n', '<leader>db', function() dap.toggle_breakpoint() end)

            vim.keymap.set('n', '<leader>dB', function()
                dap.set_breakpoint(vim.fn.input('Breakpoint condition: '))
            end)

            vim.keymap.set('n', '<leader>dq', function() dap.step_out() end)
            vim.keymap.set('n', '<leader>dw', function() dap.step_over() end)
            vim.keymap.set('n', '<leader>de', function() dap.step_into() end)

            vim.keymap.set('n', '<leader>di', function() dapui.eval() end)

            vim.keymap.set('n', '<leader>do', function()
                dapui.toggle()
            end)

            dap.listeners.before.attach.dapui_config = function()
                dapui.open()
            end
            dap.listeners.before.launch.dapui_config = function()
                dapui.open()
            end
            dap.listeners.before.event_terminated.dapui_config = function()
                dapui.close()
            end
            dap.listeners.before.event_exited.dapui_config = function()
                dapui.close()
            end
        end,
    }
}

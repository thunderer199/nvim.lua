return {
    {
        'mxsdev/nvim-dap-vscode-js',
        dependencies = {
            'mfussenegger/nvim-dap',
            'rcarriga/nvim-dap-ui',
            'theHamsta/nvim-dap-virtual-text',
            'nvim-neotest/nvim-nio',
            'mfussenegger/nvim-dap-python',
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
                                { id = "stacks",  size = 0.25 },
                                { id = "scopes",  size = 0.5 },
                                { id = "watches", size = 0.25 },
                            },
                            position = "left",
                            size = 0.25
                        },
                        -- {
                        --     elements = { id = "watches", size = 0.25 },
                        --     position = "bottom",
                        --     size = 10,
                        -- }
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

            require("dap-python").setup("python")
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
                        processId = function()
                            require 'dap.utils'.pick_process({
                                filter = function(p)
                                    -- return p.name == 'node' and string.find(p.cmd, '--inspect')
                                    local list = { 'node', 'ts-node', '--inspect', 'vitest' }
                                    for _, v in ipairs(list) do
                                        if string.find(p.name, v) then
                                            return true
                                        end
                                    end

                                    return false
                                end
                            })
                        end,
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

            vim.keymap.set('n', '<leader>dx', function() dap.continue() end, { desc = "Debug - Continue" })
            vim.keymap.set('n', '<leader>dX', function() dap.terminate() end, { desc = "Debug - Terminate" })
            vim.keymap.set('n', '<leader>dz', function() dap.run_last() end, { desc = "Debug - Run last" })
            vim.keymap.set('n', '<leader>dI', function() dap.run_to_cursor() end, { desc = "Debug - Run to cursor" })
            vim.keymap.set('n', '<leader>dR', function() dap.repl.open() end, { desc = "Debug - REPL" })
            vim.keymap.set('n', '<leader>dC', function() dapui.float_element('console') end, { desc = "Debug - Console" })

            vim.keymap.set('n', '<leader>db', function() dap.toggle_breakpoint() end, { desc = "Debug - Toggle breakpoint" })

            vim.keymap.set('n', '<leader>dn', function() dap.toggle_breakpoint(nil, nil, vim.fn.input('Log point message: '), true) end, { desc = "Debug - Logpoint" })

            vim.keymap.set('n', '<leader>dB', function() dap.set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, { desc = "Debug - Set breakpoint with condition" })

            vim.keymap.set('n', '<leader>dq', function() dap.step_out() end, { desc = "Debug - Step out" })
            vim.keymap.set('n', '<leader>dw', function() dap.step_over() end, { desc = "Debug - Step over" })
            vim.keymap.set('n', '<leader>de', function() dap.step_into() end, { desc = "Debug - Step into" })

            vim.keymap.set('n', '<leader>di', function() dapui.eval() end, { desc = "Debug - Evaluate" })
            vim.keymap.set('n', '<leader>dl', function() dapui.float_element("breakpoints") end, { desc = "Debug - breakpoints list" })
            vim.keymap.set('n', '<leader>dL', function() dap.clear_breakpoints() end, { desc = "Debug - Clear all breakpoints" })

            vim.keymap.set('n', '<leader>do', function() dapui.toggle() end, { desc = "Debug - Toggle UI" })

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

return {
    {
        'stevearc/conform.nvim',
        opts = {
            formatters_by_ft = {
                javascript = { { "prettier", "prettierd" }, "injected" },
                typescript = { { "prettier", "prettierd" }, "injected" },
                typescriptreact = { { "prettier", "prettierd" }, "injected" },
                javascriptreact = { { "prettier", "prettierd" }, "injected" },
                python = { { "ruff" } },
                json = { { "json-lsp", "prettier", "prettierd" } },
                html = { { "prettier", "prettierd" } },
                scss = { { "prettier", "prettierd" } },
                css = { { "prettier", "prettierd" } },
                less = { { "prettier", "prettierd" } },
                stylus = { { "prettier", "prettierd" } },
                yaml = { { "prettier", "prettierd" }, "injected" },
                sql = { { "sql_formatter" } },
            },
            formatters = {
                sql_formatter = {
                    prepend_args = { "--language", "plsql" },
                },
                injected = {
                    options = {
                        ignore_errors = false,
                        lang_to_formatters = {
                            sql = { { "sql_formatter" } },
                        },
                        lang_to_ext = {
                            sql = { "sql" },
                        },
                    }
                }
            }
        },
        init = function()
            -- Set this value to true to silence errors when formatting a block fails
            -- require("conform.formatters.injected").options.ignore_errors = false

            local conform = require("conform")

            vim.api.nvim_create_user_command(
                "Format",
                function(args)
                    local range = nil
                    if args.count ~= -1 then
                        local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
                        range = {
                            ["start"] = { args.line1, 0 },
                            ["end"] = { args.line2, end_line:len() },
                        }
                    end

                    conform.format({ async = false, lsp_format = "fallback", range = range })
                end,
                { range = true }
            )

            vim.keymap.set({ "n", "v" }, "<leader>f", ":Format<CR>");
        end,
    }
}

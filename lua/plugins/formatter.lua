return {
    {
        'stevearc/conform.nvim',
        opts = {
            formatters_by_ft = {
                javascript = { { "prettierd", "prettier" } },
                typescript = { { "prettierd", "prettier" } },
                typescriptreact = { { "prettier", "prettierd" } },
                javascriptreact = { { "prettier", "prettierd" } },
                json = { { "json-lsp", "prettierd", "prettier" } },
                html = { { "prettierd", "prettier" } },
                scss = { { "prettierd", "prettier" } },
                css = { { "prettierd", "prettier" } },
                less = { { "prettierd", "prettier" } },
                stylus = { { "prettierd", "prettier" } },
            },
        },
        init = function()
            -- Set this value to true to silence errors when formatting a block fails
            require("conform.formatters.injected").options.ignore_errors = false

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

                    conform.format({ async = false, lsp_fallback = true, range = range })
                end,
                { range = true }
            )

            vim.keymap.set({ "n", "v" }, "<leader>f", ":Format<CR>");
        end,
    }
}

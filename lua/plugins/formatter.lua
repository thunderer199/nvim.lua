return {
    {
        'stevearc/conform.nvim',
        config = function()
            local conform = require("conform")

            ---@param bufnr integer
            ---@param ... string
            ---@return string
            local function first(bufnr, ...)
                local conform = require("conform")
                for i = 1, select("#", ...) do
                    local formatter = select(i, ...)
                    if conform.get_formatter_info(formatter, bufnr).available then
                        return formatter
                    end
                end
                return select(1, ...)
            end

            local function prettier(bufnr)
                return first(bufnr, "prettier", "prettierd")
            end
            local function json(bufnr)
                return first(bufnr, "json-lsp", "prettier", "prettierd")
            end

            local function with_injected(fn)
                return function(bufnr)
                    return { fn(bufnr), "injected" }
                end
            end

            conform.setup({
                formatters_by_ft = {
                    javascript = with_injected(prettier),
                    typescript = with_injected(prettier),
                    typescriptreact = with_injected(prettier),
                    javascriptreact = with_injected(prettier),
                    vue = with_injected(prettier),
                    python = { "ruff_format" },
                    json = with_injected(json),
                    html = with_injected(prettier),
                    scss = with_injected(prettier),
                    css = with_injected(prettier),
                    less = with_injected(prettier),
                    stylus = with_injected(prettier),
                    yaml = with_injected(prettier),
                    sql = { "sql_formatter" },
                },
                formatters = {
                    sql_formatter = {
                        prepend_args = { "--language", "postgresql" },
                    },
                    injected = {
                        options = {
                            ignore_errors = false,
                            lang_to_formatters = {
                                sql = { "sql_formatter" },
                            },
                            lang_to_ext = {
                                sql = { "sql" },
                            },
                        }
                    }
                }
            })


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

return {
    {
        "folke/trouble.nvim",
        opts = {
            modes = {
                symbols = {
                    win = {
                        position = "right",
                        size = 0.25,
                    },
                    multiline = false,
                }
            }
        },
        lazy = false,
        keys = {
            {
                "<leader>tt",
                "<cmd>Trouble qflist toggle<cr>",
                desc = "Quickfix List (Trouble)",
            },
            {
                "<leader>tD",
                "<cmd>Trouble diagnostics toggle<cr>",
                desc = "Diagnostic List (Trouble)",
            },
            {
                "<leader>tL",
                "<cmd>Trouble loclist toggle<cr>",
                desc = "Location List (Trouble)",
            },
            {
                "<leader>o",
                "<cmd>Trouble symbols toggle focus=true<cr>",
                desc = "Outline (Trouble)",
            },
            {
                "<C-]>",
                function()
                    local View = require("trouble.view")
                    local views = View.get({ open = true })
                    if #views == 0 then return end

                    local view = views[1].view
                    local cursor = vim.api.nvim_win_get_cursor(view.win.win)
                    local current_row = cursor[1]

                    -- Find the next group (file) node
                    for row = current_row + 1, vim.api.nvim_buf_line_count(view.win.buf) do
                        local loc = view.renderer:at(row)
                        if loc.node and loc.node.group and loc.first_line then
                            vim.api.nvim_win_set_cursor(view.win.win, { row, 0 })
                            return
                        end
                    end
                end,
                desc = "Next File",
            },
            {
                "<C-[>",
                function()
                    local View = require("trouble.view")
                    local views = View.get({ open = true })
                    if #views == 0 then return end

                    local view = views[1].view
                    local cursor = vim.api.nvim_win_get_cursor(view.win.win)
                    local current_row = cursor[1]

                    -- Find the previous group (file) node
                    for row = current_row - 1, 1, -1 do
                        local loc = view.renderer:at(row)
                        if loc.node and loc.node.group and loc.first_line then
                            vim.api.nvim_win_set_cursor(view.win.win, { row, 0 })
                            return
                        end
                    end
                end,
                desc = "Previous File",
            }
        },
        config = function(_, opts)
            vim.api.nvim_create_autocmd("BufRead", {
                callback = function(ev)
                    if vim.bo[ev.buf].buftype == "quickfix" then
                        vim.schedule(function()
                            vim.cmd([[cclose]])
                            vim.cmd([[Trouble qflist open focus=false]])
                        end)
                    end
                end,
            })

            require('trouble').setup(opts)
        end,
    } }

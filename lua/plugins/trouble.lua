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

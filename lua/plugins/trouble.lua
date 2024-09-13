return {
    {
        "folke/trouble.nvim",
        opts = {}, -- for default options, refer to the configuration section for custom setup.
        lazy = false,
        keys = {
            {
                "<leader>tt",
                "<cmd>Trouble qflist toggle<cr>",
                desc = "Quickfix List (Trouble)",
            },
            {
                "<leader>ty",
                "<cmd>Trouble diagnostics toggle<cr>",
                desc = "Diagnostic List (Trouble)",
            },
            {
                "<leader>o",
                "<cmd>Trouble symbols toggle focus=true<cr>",
                desc = "Outline (Trouble)",
            }
        },
        config = function()
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

            require('trouble').setup()
        end,
    } }

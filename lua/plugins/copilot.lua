return {
    {
        "github/copilot.vim",
        config = function()
            vim.g.copilot_filetypes = { ["*"] = true }
        end
    },
    {
        "CopilotC-Nvim/CopilotChat.nvim",
        branch = "canary",
        lazy = false,
        dependencies = {
            -- { "zbirenbaum/copilot.lua" }, -- or github/copilot.vim
            { "github/copilot.vim" },
            { "nvim-lua/plenary.nvim" }, -- for curl, log wrapper
        },
        keys = {
            -- Show help actions with telescope
            {
                "<leader>ch",
                function()
                    print("Show help actions with telescope")
                    local actions = require("CopilotChat.actions")
                    require("CopilotChat.integrations.telescope").pick(actions.help_actions())
                end,
                desc = "CopilotChat - Help actions",
            },
            -- Show prompts actions with telescope
            {
                "<leader>cg",
                function()
                    local actions = require("CopilotChat.actions")
                    require("CopilotChat.integrations.telescope").pick(actions.prompt_actions())
                end,
                desc = "CopilotChat - Prompt actions",
            },
            {
                "<leader>ct",
                function()
                    local chat = require("CopilotChat")

                    chat.toggle()
                end,
                desc = "CopilotChat - Toggle Float",
            },
            {
                "<leader>cf",
                function()
                    local chat = require("CopilotChat")

                    chat.toggle({
                        window = {
                            layout = 'float',
                            title = 'CopilotChat',
                        },
                    })
                end,
                desc = "CopilotChat - Toggle Float",
            },
            {
                "<leader>cT",
                ":CopilotChatTests<CR>",
                desc = "CopilotChat - Tests",
                mode = { "n", "v" },
            },
            {
                "<leader>cF",
                ":CopilotChatFixDiagnostic<CR>",
                desc = "CopilotChat - Fix",
                mode = { "n", "v" },
            },
            {
                "<leader>cD",
                ":CopilotChatDocs<CR>",
                desc = "CopilotChat - Docs",
                mode = { "n", "v" },
            },
            {
                "<leader>cr",
                function()
                    local chat = require("CopilotChat")
                    chat.ask("Review changes and provide feedback.",
                        {
                            selection = require("CopilotChat.select").visual,
                        }
                    )
                end,
                desc = "CopilotChat - Review",
                mode = { "n", "v" },
            },
            {
                "<leader>cR",
                function()
                    local chat = require("CopilotChat")
                    chat.ask("Review changes and refactor code using the provided suggestions.",
                        {
                            selection = require("CopilotChat.select").visual,
                        }
                    )
                end,
                desc = "CopilotChat - Review",
                mode = { "n", "v" },
            },
            {
                "<leader>cC",
                function()
                    local chat = require("CopilotChat")

                    chat.ask(
                        "Write commit message for the change. It should be a short, imperative tense description of the change, that is less than 100 characters. Format in a way that your output goes straight into the commit message.",
                        {
                            callback = function(response)
                                local util = require("vlad.util")

                                -- find git commit buffer
                                local bufnr = vim.fn.bufnr("COMMIT_EDITMSG")
                                -- if not found, quit
                                if bufnr == -1 then
                                    print("Git commit buffer not found")
                                    return
                                end
                                -- append response to buffer start
                                local lines = util.split_into_lines(response)
                                -- trim ", ' and whitespace
                                for i, line in ipairs(lines) do
                                    lines[i] = util.trim_quotes(line)
                                end
                                vim.api.nvim_buf_set_lines(bufnr, 0, 0, false, lines)
                                -- close chat buffer
                                vim.cmd("q")
                            end,
                            selection = function(source)
                                return require("CopilotChat.select").gitdiff(source, true)
                            end,
                        })
                end,
                desc = "CopilotChat - Commit staged",
            },
            {
                "<leader>cq",
                function()
                    local input = vim.fn.input("Quick Chat: ")
                    if input ~= "" then
                        require("CopilotChat").ask(input, { selection = require("CopilotChat.select").buffer })
                    end
                end,
                desc = "CopilotChat - Quick chat",
            }
        },
        opts = {
            mappings = {
                complete = {
                    detail = 'Use @<C-i> or /<C-i> for options.',
                    insert = '<C-i>',
                },
                close = {
                    normal = 'q',
                    insert = '<C-c>'
                },
                reset = {
                    normal = '<C-l>',
                    insert = '<C-l>'
                },
                submit_prompt = {
                    normal = '<CR>',
                    insert = '<C-i>'
                },
                accept_diff = {
                    normal = '<C-y>',
                    insert = '<C-y>'
                },
                yank_diff = {
                    normal = 'gy',
                },
                show_diff = {
                    normal = 'gd'
                },
                show_system_prompt = {
                    normal = 'gp'
                },
                show_user_selection = {
                    normal = 'gs'
                },
            },
        },
    },

}

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

                    chat.toggle({
                        window = {
                            layout = 'float',
                            title = 'My Title',
                        },
                    })
                end,
                desc = "CopilotChat - Toggle",
            },
            {
                "<leader>cT",
                ":CopilotChatTests<CR>",
                desc = "CopilotChat - Tests",
                mode = { "n", "v" },
            },
            {
                "<leader>cF",
                ":CopilotChatFix<CR>",
                desc = "CopilotChat - Fix",
                mode = { "n", "v" },
            },
            {
                "<leader>cC",
                -- ":CopilotChatCommitStaged<CR>",
                function()
                    local chat = require("CopilotChat")

                    chat.ask(
                        "Write commit message for the change with commitizen convention. It should be a short, imperative tense description of the change, that is less than 100 characters. Format in a way that your output goes straight into the commit message.",
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
                                    lines[i] = util.trim_string(line, '"')
                                    lines[i] = util.trim_string(line, "'")
                                    lines[i] = util.trim_string(line, " ")
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
            -- debug = true, -- Enable debugging
        },
    },

}

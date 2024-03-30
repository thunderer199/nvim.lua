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
                        "Write commit message for the change with commitizen convention. It should be a short, imperative tense description of the change, that is less than 100 characters.",
                        {
                            callback = function(response)
                                local function split_into_lines(str)
                                    local t = {}
                                    for s in str:gmatch("[^\r\n]+") do
                                        table.insert(t, s)
                                    end
                                    return t
                                end

                                -- find git commit buffer
                                local bufnr = vim.fn.bufnr("COMMIT_EDITMSG")
                                -- if not found, quit
                                if bufnr == -1 then
                                    return
                                end
                                -- append response to buffer start
                                local lines = split_into_lines(response)[2]
                                vim.api.nvim_buf_set_lines(bufnr, 0, 0, false, {lines})
                                -- close current buffer
                                vim.cmd("wq")
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

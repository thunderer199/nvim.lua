return {
    {
        "github/copilot.vim",
        init = function()
            local util = require("vlad.util")

            vim.g.copilot_workspace_folders = { util.get_base_path() }
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
                "<leader>cH",
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
                desc = "CopilotChat - Toggle Panel",
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
                desc = "CopilotChat - Fix Diagnostic",
                mode = { "n", "v" },
            },
            {
                "<leader>ch",
                ":CopilotChatFix<CR>",
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
                "<leader>cE",
                ":CopilotChatExplain<CR>",
                desc = "CopilotChat - Explain",
                mode = { "n", "v" },
            },
            {
                "<leader>cr",
                function()
                    local chat = require("CopilotChat")
                    chat.ask("Review code and provide feedback, following best practices.",
                        {
                            selection = require("CopilotChat.select").visual,
                        }
                    )
                end,
                desc = "CopilotChat - Review",
                mode = { "n", "v" },
            },
            {
                "<leader>cs",
                ":CopilotChatReview<CR>",
                desc = "CopilotChat - Review (github predefined)",
                mode = { "n", "v" },
            },
            {
                "<leader>cS",
                function()
                    local chat = require("CopilotChat")
                    chat.ask("Spellcheck the provided code. Including strings, comments, and identifiers.",
                        {
                            selection = require("CopilotChat.select").buffer,
                        }
                    )
                end,
                desc = "CopilotChat - Spellcheck",
                mode = { "n", "v" },
            },
            {
                "<leader>cR",
                function()
                    local chat = require("CopilotChat")
                    chat.ask(
                        "Review provided code following best industry practices. Refactor code using the provided suggestions.",
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
                                local lines = vim.fn.split(response, "\n", true)
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
        ---@type CopilotChat.config
        opts = {
            model = 'claude-3.5-sonnet',
            selection = function(source)
                local select = require("CopilotChat.select")
                return select.visual(source) or select.buffer(source)
            end,
            mappings = {
                complete = {
                    detail = 'Use @<Tab> or /<Tab> for options.',
                    insert = '<Tab>',
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
                    insert = '<C-p>'
                },
                accept_diff = {
                    normal = '<C-y>',
                    insert = '<C-y>'
                },
                yank_diff = {
                    normal = 'gy',
                    register = '"',
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

return {
    {
        "github/copilot.vim",
        -- cond = false,
        init = function()
            local util = require("vlad.util")

            local v = util.get_base_path()
            print("Copilot workspace: " .. v)
            vim.g.copilot_workspace_folders = { v }
            vim.g.copilot_filetypes = { ["*"] = true }
        end
    },
    {
        "CopilotC-Nvim/CopilotChat.nvim",
        branch = "main",
        lazy = false,
        dependencies = {
            -- { "zbirenbaum/copilot.lua" }, -- or github/copilot.vim
            { "github/copilot.vim" },
            { "nvim-lua/plenary.nvim" }, -- for curl, log wrapper
        },
        keys = {
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
                "<leader>cq",
                function()
                    local input = vim.fn.input("Quick Chat: ")
                    if input ~= "" then
                        require("CopilotChat").ask(input, { selection = require("CopilotChat.select").buffer })
                    end
                end,
                desc = "CopilotChat - Quick chat",
            },
            {
                "<leader>cx",
                ":CopilotChatInline<cr>",
                mode = "x",
                desc = "CopilotChat - Inline chat",
            },
        },
        config = function(_, opts)
            local chat = require("CopilotChat")
            chat.setup(opts)

            local select = require("CopilotChat.select")
            vim.api.nvim_create_user_command("CopilotChatVisual", function(args)
                chat.ask(args.args, { selection = select.visual })
            end, { nargs = "*", range = true })

            vim.api.nvim_create_user_command("CopilotChatInline", function(args)
                chat.ask(args.args, {
                    selection = select.visual,
                    window = {
                        layout = "float",
                        relative = "cursor",
                        width = 1,
                        height = 0.4,
                        row = 1,
                    },
                })
            end, { nargs = "*", range = true })
        end,
        ---@type CopilotChat.config
        opts = {
            model = 'claude-3.5-sonnet',
            selection = function(source)
                local select = require("CopilotChat.select")
                return select.visual(source) or select.buffer(source)
            end,
            prompts = {
                BestPracticeFeedback = {
                    model = 'claude-3.5-sonnet',
                    prompt =
                    "Review the provided code thoroughly and offer feedback following best practices. Focus on clarity, correctness, maintainability, and performance.",
                    system_prompt =
                    "You are a highly skilled software engineer and code reviewer. Take a deep breath before you begin.",
                },
                Spellcheck = {
                    model = 'gpt-4o',
                    prompt =
                    "Spellcheck the provided code and check its grammar. Pay special attention to strings, comments, and identifiers. Provide concise corrections without altering the logic or functionality of the code.",
                    system_prompt =
                    "You are an expert editor with a keen sense of grammar, spelling, and style. Take a deep breath before you start.",
                },
                ReviewCustom = {
                    model = 'claude-3.5-sonnet',
                    prompt =
                    "Review provided code following best industry practices. Refactor code using the provided suggestions. After the review, made requested changes and submit the code.",
                    system_prompt =
                    "You are an experienced and meticulous software engineer with deep expertise in code quality, best practices, design patterns, and maintainability. Your primary objective is to perform thorough code reviews. When analyzing code, follow industry best practices, and provide constructive feedback to improve code quality. Identify issues with clarity and precision. Suggest practical improvements or alternatives. Offer a brief summary of strengths, weaknesses, and recommended changes. Remember: Take a deep breath before you start to review the code carefully and craft clear, actionable guidance.",
                },
                SecurityAudit = {
                    model = 'o1',
                    prompt =
                    "Examine the provided code for potential security vulnerabilities and best-practice compliance. Provide clear remediation steps.",
                    system_prompt =
                    "You are a veteran security analyst with expertise in secure coding practices. Take a deep breath before you begin. Your goal is to thoroughly audit the provided code for security flaws, highlight potential attack vectors, and offer actionable steps to mitigate any risks. Always aim to maintain code functionality while enhancing overall security."
                },
                TestStrategy = {
                    model = 'o1',
                    prompt =
                    "Review the provided code to suggest comprehensive testing strategies, identify missing test cases, and propose improvements for existing tests. Focus on coverage and reliability.",
                    system_prompt =
                    "You are a seasoned QA engineer and software tester. Take a deep breath before you begin. Your goal is to ensure robust test coverage by identifying gaps, proposing new test cases, and refining current testing methodologies."
                },
                RefactorHelper = {
                    model = 'o1',
                    prompt =
                    "Refactor the provided code to enhance maintainability, readability, and extensibility. Avoid altering core functionality unless necessary.",
                    system_prompt =
                    "You are a meticulous refactoring expert. Take a deep breath before starting. Your focus is on reorganizing and simplifying the code to align with best practices while keeping the same output and behavior."
                },
                BetterNamings = {
                    model = 'o1-mini',
                    prompt =
                    "Please propose clearer, more descriptive names for the following variables and functions. Follow established naming conventions and briefly explain why each suggested name is an improvement.",
                    system_prompt =
                    "You are an expert in code readability and naming conventions. Take a deep breath before you start. Your task is to evaluate existing variable and function names, then suggest improved alternatives that enhance clarity and maintain consistency."
                }

            },
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
                show_info = {
                    normal = 'gp'
                },
                show_context = {
                    normal = 'gs'
                },
            },
        },
    },

}

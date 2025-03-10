local util = require("vlad.util")
local envs = util.read_env_config()

return {
    {
        "github/copilot.vim",
        cond = envs['NVIM_COPILOT_STATE'] ~= 'off',
        init = function()
            local v = util.get_base_path()
            print("Copilot workspace: " .. v)
            vim.g.copilot_workspace_folders = { v }
            vim.g.copilot_filetypes = { ["*"] = true }

            -- meta and right arrow
            vim.keymap.set('i', '<M-\\>', '<Plug>(copilot-accept-word)')
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
            model = 'claude-3.7-sonnet',
            selection = function(source)
                local select = require("CopilotChat.select")
                return select.visual(source) or select.buffer(source)
            end,
            prompts = {
                BestPracticeFeedback = {
                    model = 'claude-3.7-sonnet',
                    prompt =
                    "Review the provided code thoroughly and offer feedback following best practices. Focus on clarity, correctness, maintainability, and performance.",
                    system_prompt =
                    "You are a highly skilled software engineer and code reviewer. Take a deep breath before you begin. Do not include line numbers in any code blocks.",
                },
                Spellcheck = {
                    model = 'gpt-4o',
                    prompt =
                    "Spellcheck the provided code and check its grammar. Pay special attention to strings, comments, and identifiers. Provide concise corrections without altering the logic or functionality of the code.",
                    system_prompt =
                    "You are an expert editor with a keen sense of grammar, spelling, and style. Take a deep breath before you start. Do not include line numbers in any code blocks.",
                },
                ReviewCustom = {
                    model = 'claude-3.7-sonnet-thought',
                    prompt =
                    "Review provided code following best industry practices. Refactor code using the provided suggestions. After the review, made requested changes and submit the code.",
                    system_prompt =
                    "You are an experienced and meticulous software engineer with deep expertise in code quality, best practices, design patterns, and maintainability. Your primary objective is to perform thorough code reviews. When analyzing code, follow industry best practices, and provide constructive feedback to improve code quality. Identify issues with clarity and precision. Suggest practical improvements or alternatives. Offer a brief summary of strengths, weaknesses, and recommended changes. Remember: Take a deep breath before you start to review the code carefully and craft clear, actionable guidance. Do not include line numbers in any code blocks.",
                },
                SecurityAudit = {
                    model = 'claude-3.7-sonnet-thought',
                    prompt =
                    "Examine the provided code for potential security vulnerabilities and best-practice compliance. Provide clear remediation steps.",
                    system_prompt =
                    "You are a veteran security analyst with expertise in secure coding practices. Take a deep breath before you begin. Your goal is to thoroughly audit the provided code for security flaws, highlight potential attack vectors, and offer actionable steps to mitigate any risks. Always aim to maintain code functionality while enhancing overall security. Do not include line numbers in any code blocks."
                },
                TestStrategy = {
                    model = 'o3-mini',
                    prompt =
                    "Review the provided code to suggest comprehensive testing strategies, identify missing test cases, and propose improvements for existing tests. Focus on coverage and reliability.",
                    system_prompt =
                    "You are a seasoned QA engineer and software tester. Take a deep breath before you begin. Your goal is to ensure robust test coverage by identifying gaps, proposing new test cases, and refining current testing methodologies. Do not include line numbers in any code blocks."
                },
                RefactorHelper = {
                    model = 'o3-mini',
                    prompt =
                    "Refactor the provided code to enhance maintainability, readability, and extensibility. Avoid altering core functionality unless necessary.",
                    system_prompt =
                    "You are a meticulous refactoring expert. Take a deep breath before starting. Your focus is on reorganizing and simplifying the code to align with best practices while keeping the same output and behavior. Do not include line numbers in any code blocks."
                },
                BetterNamings = {
                    model = 'o3-mini',
                    prompt =
                    "Please propose clearer, more descriptive names for the following variables and functions. Follow established naming conventions and briefly explain why each suggested name is an improvement.",
                    system_prompt =
                    "You are an expert in code readability and naming conventions. Take a deep breath before you start. Your task is to evaluate existing variable and function names, then suggest improved alternatives that enhance clarity and maintain consistency. Do not include line numbers in any code blocks."
                },
                MemoryLeakSearch = {
                    model = 'claude-3.7-sonnet-thought',
                    prompt = "Identify potential memory leaks in the provided code and suggest remediation steps.",
                    system_prompt =
                    "You are a memory management expert. Take a deep breath before you start. Your goal is to identify potential memory leaks in the provided code and suggest remediation steps. Do not include line numbers in any code blocks."
                },
                PerformanceImprovements = {
                    model = 'claude-3.7-sonnet-thought',
                    prompt =
                    "Identify performance bottlenecks in the provided code and suggest improvements to enhance speed and efficiency.",
                    system_prompt =
                    "You are a performance optimization expert. Take a deep breath before you start. Your goal is to identify performance bottlenecks in the provided code and suggest improvements to enhance speed and efficiency. Do not include line numbers in any code blocks."
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

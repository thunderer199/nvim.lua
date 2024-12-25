return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    init = function()
        local snacks = require("snacks")
        vim.api.nvim_create_user_command("ZenMode", function()
            snacks.zen.zen({ toggles = { dim = false, git_signs = true } })
        end, {})
        vim.api.nvim_create_user_command("ZenModeDim", function()
            snacks.zen.zen({ toggles = { dim = true, git_signs = true } })
        end, {})

        vim.api.nvim_create_user_command("GitBrowse", function()
            local util = require('vlad.util')
            local urls = {
                github = {
                    branch = "/tree/{branch}",
                    file = "/blob/{branch}/{file}#L{line_start}-L{line_end}",
                    commit = "/commit/{commit}",
                },
                gitlab = {
                    branch = "/-/tree/{branch}",
                    file = "/-/blob/{branch}/{file}#L{line_start}-L{line_end}",
                    commit = "/-/commit/{commit}",
                },
            }

            local list = {}
            for service, patterns in pairs(urls) do
                local file = util.read_file(os.getenv('HOME') .. '/.' .. service .. '-enterprise')
                if file then
                    local lines = util.split_into_lines(file)
                    for _, line in ipairs(lines) do
                        local domain = line:gsub("%.", "%%.")
                        domain = domain:gsub("^https?://", "")

                        list[domain] = patterns
                    end
                end
            end

            snacks.gitbrowse.open({
                url_patterns = list,
            })
        end, {})
    end,
    opts = {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
        bigfile = {
            enabled = true,
            notify = true,
        },
        -- notifier = { enabled = true },
        quickfile = { enabled = true },
        -- statuscolumn = { enabled = true },
        -- words = { enabled = true },
        zen = {
            toggles = {
                dim = true,
                git_signs = false,
                mini_diff_signs = false,
                -- diagnostics = false,
                -- inlay_hints = false,
            },
            ---@type snacks.win.Config
            -- win = { style = "zen" },

        },
    },
    keys = {
        {
            "<leader>bd",
            function()
                ---@class snacks
                Snacks.bufdelete.other()
                print("Other Buffers Deleted")
            end,
            desc = "Delete other buffers",
        },
    }
}

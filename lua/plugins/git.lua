return {
    {
        "NeogitOrg/neogit",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "sindrets/diffview.nvim",
            "nvim-telescope/telescope.nvim",
        },
        keys = {
            { "<leader>gg", function() require("neogit").open() end }
        },
        enabled = false,
        config = true,
        opts = {
            kind = "split_above",
            integrations = {
                telescope = true,
                fzf_lua = true,
                diffview = true,
            },
            mappings = {
                status = {
                    ["="] = "Toggle",
                    ["+"] = "Stage",
                    ["-"] = "Unstage",
                }
            }
        }
    },
    {
        "sindrets/diffview.nvim",
        lazy = false,
        config = function()
            require('diffview').setup({
                default = {
                    layout = 'diff3_mixed'
                }
            })
            vim.keymap.set("n", "<leader>gd", ":DiffviewOpen<CR>", { desc = "Diffview Open" })
            vim.keymap.set("n", "<leader>gl", ":DiffviewFileHistory --n=25<CR>", { desc = "Diffview Git History" })
            vim.keymap.set("n", "<leader>gc", ":DiffviewFileHistory %<CR>", { desc = "Diffview File History" })
            vim.keymap.set("v", "<leader>gc", function()
                vim.cmd("'<,'>DiffviewFileHistory")
            end, { desc = "Diffview Selection History" })
        end,
    },
    {
        'tpope/vim-fugitive',
        dependencies = {
            'tpope/vim-rhubarb',
        },
        keys = {
            { '<leader>gs', vim.cmd.Git,                                  desc = "Git Status" },
            { "<leader>gb", function() vim.cmd.Git("blame -w -M") end,    desc = "Git Blame move and ignore whitespace" },
            { "<leader>gB", function() vim.cmd.Git("blame -w -M -C") end, desc = "Git Blame move and copy" },
            { "<leader>ge", vim.cmd.Gedit,                                desc = "Gedit" },
        },
        cmd = {
            "GBrowse", "Gedit"
        },
        config = function()
            -- vim read txt file
            local util = require('vlad.util')
            local file = util.read_file(os.getenv('HOME') .. '/.github-enterprise')
            if file then
                local lines = util.split_into_lines(file)
                vim.g.github_enterprise_urls = lines
            end

            local fugitive_cmd_group = vim.api.nvim_create_augroup("fugitive_cmd_group", {})

            vim.api.nvim_create_autocmd("BufWinEnter", {
                group = fugitive_cmd_group,
                pattern = "*",
                callback = function()
                    if vim.bo.ft ~= "fugitive" then
                        return
                    end

                    local bufnr = vim.api.nvim_get_current_buf()
                    local opts = { buffer = bufnr, remap = false }
                    vim.keymap.set("n", "<leader>gp", function()
                        vim.cmd.Git('push')
                    end, opts)

                    -- rebase always
                    vim.keymap.set("n", "<leader>gP", function()
                        vim.cmd.Git('pull --rebase')
                    end, opts)

                    vim.keymap.set("n", "<leader>gpu", function()
                        vim.cmd.Git('push -u origin HEAD')
                    end, opts);

                    vim.keymap.set("n", "<leader>gpf", function()
                        vim.cmd.Git('push --force-with-lease')
                    end, opts);
                end
            })
        end
    },
    {
        'lewis6991/gitsigns.nvim',
        config = function()
            require('gitsigns').setup {
                on_attach = function(bufnr)
                    local gs = package.loaded.gitsigns

                    local function map(mode, l, r, opts)
                        opts = opts or {}
                        opts.buffer = bufnr
                        vim.keymap.set(mode, l, r, opts)
                    end

                    -- Navigation
                    map('n', ']h', function()
                        if vim.wo.diff then return ']h' end
                        vim.schedule(function() gs.next_hunk() end)
                        return '<Ignore>'
                    end, { expr = true, desc = "Next Hunk" })

                    map('n', '[h', function()
                        if vim.wo.diff then return '[h' end
                        vim.schedule(function() gs.prev_hunk() end)
                        return '<Ignore>'
                    end, { expr = true, desc = "Previous Hunk" })

                    -- Actions
                    map('n', '<leader>hs', gs.stage_hunk, { desc = "Stage Hunk" })
                    map('n', '<leader>hr', gs.reset_hunk, { desc = "Reset Hunk" })
                    map('v', '<leader>hs', function()
                        gs.stage_hunk { vim.fn.line('.'), vim.fn.line('v') }
                    end, { desc = "Stage Hunk" })
                    map('v', '<leader>hr', function()
                        gs.reset_hunk { vim.fn.line('.'), vim.fn.line('v') }
                    end, { desc = "Reset Hunk" })
                    map('n', '<leader>hS', gs.stage_buffer, { desc = "Stage Buffer" })
                    map('n', '<leader>hu', gs.undo_stage_hunk, { desc = "Undo Stage Hunk" })
                    map('n', '<leader>hR', gs.reset_buffer, { desc = "Reset Buffer" })
                    map('n', '<leader>hp', gs.preview_hunk, { desc = "Preview Hunk" })

                    map('n', '<leader>hb', function() gs.blame_line { full = true } end, { desc = "Blame Line" })
                    map('n', '<leader>tb', gs.toggle_current_line_blame, { desc = "Toggle Blame" })
                    map('n', '<leader>td', gs.toggle_deleted, { desc = "Toggle Deleted" })

                    -- Text object
                    map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
                end
            }
        end
    },
}

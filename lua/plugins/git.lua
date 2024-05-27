return {
    {
        'ruifm/gitlinker.nvim',
        config = true,
        keys = {
            { '<leader>gy', function() require "gitlinker".get_buf_range_url("n") end },
            { '<leader>gy', function() require "gitlinker".get_buf_range_url("v") end, mode = 'v' },
        },
    },
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
            vim.keymap.set("n", "<leader>gd", ":DiffviewOpen<CR>")
            vim.keymap.set("n", "<leader>gl", ":DiffviewFileHistory --n=25<CR>")
            vim.keymap.set("n", "<leader>gc", ":DiffviewFileHistory %<CR>")
            vim.keymap.set("v", "<leader>gc", function()
                vim.cmd("'<,'>DiffviewFileHistory")
            end)
        end,
    },
    {
        'tpope/vim-fugitive',
        keys = {
            { '<leader>gs', vim.cmd.Git },
            { "<leader>gb", function() vim.cmd.Git("blame -w -M") end },
            { "<leader>gB", function() vim.cmd.Git("blame") end },
            { "<leader>ge", vim.cmd.Gedit },
        },
        config = function()
            local fugitive_cmd_group = vim.api.nvim_create_augroup("fugitive_cmd_group", {})

            local autocmd = vim.api.nvim_create_autocmd
            autocmd("BufWinEnter", {
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
                    end, { expr = true })

                    map('n', '[h', function()
                        if vim.wo.diff then return '[h' end
                        vim.schedule(function() gs.prev_hunk() end)
                        return '<Ignore>'
                    end, { expr = true })

                    -- Actions
                    map('n', '<leader>hs', gs.stage_hunk)
                    map('n', '<leader>hr', gs.reset_hunk)
                    map('v', '<leader>hs', function()
                        gs.stage_hunk { vim.fn.line('.'), vim.fn.line('v') }
                    end)
                    map('v', '<leader>hr', function()
                        gs.reset_hunk { vim.fn.line('.'), vim.fn.line('v') }
                    end)
                    map('n', '<leader>hS', gs.stage_buffer)
                    map('n', '<leader>hu', gs.undo_stage_hunk)
                    map('n', '<leader>hR', gs.reset_buffer)
                    map('n', '<leader>hp', gs.preview_hunk)

                    map('n', '<leader>hb', function() gs.blame_line { full = true } end)
                    map('n', '<leader>tb', gs.toggle_current_line_blame)
                    map('n', '<leader>td', gs.toggle_deleted)

                    -- Text object
                    map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
                end
            }
        end
    },
}

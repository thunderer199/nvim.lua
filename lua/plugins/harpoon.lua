return {
    'theprimeagen/harpoon',
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
        local harpoon = require("harpoon")

        local get_git_cwd = function()
            local git_dir = require('telescope.utils').get_os_command_output({ 'git', 'rev-parse', '--show-toplevel' })
                [1]

            return git_dir
        end

        harpoon:setup({
            settings = {
                save_on_toggle = true,
                sync_on_ui_close = true,
                key = function()
                    local git_dir = get_git_cwd()
                    if git_dir == nil then
                        return vim.loop.cwd()
                    else
                        return git_dir
                    end
                end
            }
        })

        vim.keymap.set("n", "<leader>a", function() harpoon:list():append() end)
        vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

        -- Alt - n - go to next file
        vim.keymap.set("n", "<M-n>", function() harpoon:list():next({ ui_nav_wrap = true }) end)
        -- Alt - b - go to previous file
        vim.keymap.set("n", "<M-b>", function() harpoon:list():prev({ ui_nav_wrap = true }) end)

        -- map alt + hjkl to navigate between files
        vim.keymap.set("n", "<M-h>", function() harpoon:list():select(1) end)
        vim.keymap.set("n", "<M-j>", function() harpoon:list():select(2) end)
        vim.keymap.set("n", "<M-k>", function() harpoon:list():select(3) end)
        vim.keymap.set("n", "<M-l>", function() harpoon:list():select(4) end)
    end
}

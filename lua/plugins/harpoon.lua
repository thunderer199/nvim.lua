return {
    'theprimeagen/harpoon',
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
        local harpoon = require("harpoon")
        local util = require("vlad.util")


        local basepath = require('vlad.util').get_base_path()
        harpoon:setup({
            default = {
                create_list_item = function()
                    local filepath = vim.fn.expand('%:p')

                    local bufnr = vim.fn.bufnr(filepath, false)

                    local pos = { 1, 0 }
                    if bufnr ~= -1 then
                        pos = vim.api.nvim_win_get_cursor(0)
                    end

                    -- if oil file viewer than set pos to nil
                    if filepath:find('oil:') ~= nil then
                        pos = { 1, 0 }
                    end

                    return {
                        value = filepath,
                        context = {
                            row = pos[1],
                            col = pos[2],
                        }
                    }
                end,
                display = function(item)
                    local display_name = item.value
                    if display_name:find(basepath, 1, true) == 1 then
                        display_name = display_name:sub(#basepath + 2, -1)
                    end
                    return display_name
                end
            },
            settings = {
                save_on_toggle = true,
                sync_on_ui_close = true,
                key = function()
                    local git_dir = util.get_git_cwd()
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

return {
    'theprimeagen/harpoon',
    branch = "harpoon2",
    commit = "a38be6e",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
        local harpoon = require("harpoon")
        local util = require("vlad.util")

        local isPrevNextMovement = false;

        local basepath = require('vlad.util').get_base_path()
        harpoon:setup({
            default = {
                create_list_item = function(_, name)
                    local filepath = vim.api.nvim_buf_get_name(
                        vim.api.nvim_get_current_buf()
                    )

                    -- if name appear that is result of editing list in harpoon preview
                    if name ~= nil then
                        filepath = basepath .. '/' .. name
                    end
                    print(filepath)

                    local bufnr = vim.fn.bufnr(filepath, false)

                    local pos = { 1, 0 }
                    if bufnr ~= -1 then
                        pos = vim.api.nvim_win_get_cursor(0)
                    end

                    return {
                        value = filepath,
                        context = {
                            row = pos[1],
                            col = pos[2],
                        }
                    }
                end,
                select = function(list_item, list, options)
                    options = options or {}
                    if list_item == nil then
                        return
                    end

                    -- find index
                    local index = nil
                    for i, item in ipairs(list.items) do
                        if item.value == list_item.value then
                            index = i
                            break
                        end
                    end

                    if isPrevNextMovement then
                        isPrevNextMovement = false
                    elseif index ~= nil then
                        list._index = index
                    end

                    local bufnr = vim.fn.bufnr(list_item.value)
                    local set_position = false
                    if bufnr == -1 then
                        set_position = true
                        bufnr = vim.fn.bufnr(list_item.value, true)
                    end
                    if not vim.api.nvim_buf_is_loaded(bufnr) then
                        vim.fn.bufload(bufnr)
                        vim.api.nvim_set_option_value("buflisted", true, {
                            buf = bufnr,
                        })
                    end
                    -- if oil file viewer than set pos to nil
                    if list_item.value:find('oil:') ~= nil then
                        set_position = false
                    end

                    if options.vsplit then
                        vim.cmd("vsplit")
                    elseif options.split then
                        vim.cmd("split")
                    elseif options.tabedit then
                        vim.cmd("tabedit")
                    end

                    vim.api.nvim_set_current_buf(bufnr)

                    if set_position then
                        vim.api.nvim_win_set_cursor(0, {
                            list_item.context.row or 1,
                            list_item.context.col or 0,
                        })
                        -- center the cursor
                        vim.cmd("normal! zz")
                    end
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

        local function can_append()
            local filepath = vim.api.nvim_buf_get_name(
                vim.api.nvim_get_current_buf()
            )

            if filepath == "" then
                return false
            end
            if filepath:find("fugitive://") ~= nil then
                return false
            end
            if filepath:find(".git/") ~= nil then
                return false
            end

            return true
        end

        vim.keymap.set("n", "<leader>a", function()
            if can_append() then
                harpoon:list():append()
            end
        end)
        vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

        -- Alt - n - go to next file
        vim.keymap.set("n", "<M-n>", function()
            isPrevNextMovement = true
            harpoon:list():next({ ui_nav_wrap = true })
        end)
        -- Alt - b - go to previous file
        vim.keymap.set("n", "<M-b>", function()
            isPrevNextMovement = true
            harpoon:list():prev({ ui_nav_wrap = true })
        end)

        -- map alt + hjkl to navigate between files
        vim.keymap.set("n", "<M-h>", function() harpoon:list():select(1) end)
        vim.keymap.set("n", "<M-j>", function() harpoon:list():select(2) end)
        vim.keymap.set("n", "<M-k>", function() harpoon:list():select(3) end)
        vim.keymap.set("n", "<M-l>", function() harpoon:list():select(4) end)
    end
}

return {
    {
        'stevearc/oil.nvim',
        opts = {
            keymaps = {
                ['F'] = {
                    desc = 'Send (append) to location list',
                    callback = function()
                        local val = require('oil').get_cursor_entry()
                        if not val then
                            return
                        end
                        local base_path = require('oil').get_current_dir()
                        local full_path = base_path .. val.name

                        if val.type == 'directory' then
                            -- Add all files in the directory to the location list
                            local files = vim.fn.glob(full_path .. '/*', false, true)
                            local entries = {}
                            for _, file_path in ipairs(files) do
                                if vim.fn.isdirectory(file_path) ~= 1 then
                                    local file_name = vim.fn.fnamemodify(file_path, ':t')
                                    table.insert(entries, {
                                        filename = file_path,
                                        lnum = 1,
                                        col = 1,
                                        text = file_name
                                    })
                                end
                            end
                            vim.fn.setloclist(0, entries, 'a')
                            print('Added ' .. #entries .. ' files from ' .. val.name .. ' to location list')
                        else
                            local entry = {
                                filename = full_path,
                                lnum = 1,
                                col = 1,
                                text = val.name
                            }
                            vim.fn.setloclist(0, {entry}, 'a')
                            print('Added ' .. val.name .. ' to location list')
                        end
                    end,
                },
                ['Yp'] = {
                    desc = 'Copy full filepath to register',
                    callback = function()
                        local util = require('vlad.util')
                        local val = require('oil').get_cursor_entry()
                        if not val then
                            return
                        end
                        local base_path = require('oil').get_current_dir()
                        local relative_path = util.removeBaseFromPath(base_path)
                        vim.fn.setreg('0', relative_path .. val.name)
                        print('Copied ' .. relative_path .. val.name .. ' to register 0')
                    end,
                },
                ['YP'] = {
                    desc = 'Copy full folder path to register',
                    callback = function()
                        local util = require('vlad.util')
                        local val = require('oil').get_cursor_entry()
                        if not val then
                            return
                        end
                        local base_path = require('oil').get_current_dir()
                        local relative_path = util.removeBaseFromPath(base_path)
                        vim.fn.setreg('0', relative_path)
                        print('Copied ' .. relative_path .. ' to register 0')
                    end,
                },
                ['ga'] = {
                    desc = 'Git add file to staging area',
                    callback = function()
                        local val = require('oil').get_cursor_entry()
                        if not val then
                            return
                        end
                        local base_path = require('oil').get_current_dir()
                        local full_path = base_path .. val.name

                        vim.cmd('!Git add ' .. full_path)
                        print('Added ' .. val.name .. ' to git staging area')
                    end,
                }
            },
            lsp_file_methods = {
                timeout_ms = 1000,
                autosave_changes = true,
            },
            view_options = {
                show_hidden = true,
            }
        },
        dependencies = { "nvim-tree/nvim-web-devicons" },
    }
}

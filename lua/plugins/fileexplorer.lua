return {
    {
        'stevearc/oil.nvim',
        opts = {
            keymaps = {
                ['yp'] = {
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
                    end,
                },
                ['yP'] = {
                    desc = 'Copy full filepath to register',
                    callback = function()
                        local util = require('vlad.util')
                        local val = require('oil').get_cursor_entry()
                        if not val then
                            return
                        end
                        local base_path = require('oil').get_current_dir()
                        local relative_path = util.removeBaseFromPath(base_path)
                        vim.fn.setreg('0', relative_path)
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

return {
    'nvim-lualine/lualine.nvim',
    config = function()
        require('lualine').setup {
            options = {
                theme = 'modus-vivendi',
            },
            sections = {
                lualine_a = { 'mode' },
                lualine_b = { 'branch', 'diff' },
                lualine_c = {
                    'diagnostics',
                    {
                        'filename',
                        file_status = true,
                        newfile_status = true,
                        path = 1,
                        shorting_target = 40,
                        symbols = {
                            modified = '[+]', -- Text to show when the file is modified.
                            readonly = '[r/o]', -- Text to show when the file is non-modifiable or readonly.
                            unnamed = '[No Name]', -- Text to show for unnamed buffers.
                            newfile = '[New]', -- Text to show for newly created file before first write
                            git = '[Git]', -- Text to show when the file is modified.
                        }
                    }
                },
                lualine_x = { 'encoding', 'fileformat', 'filetype' },
                lualine_y = { 'progress', 'searchcount' },
                lualine_z = { 'location' }
            },
            inactive_sections = {
                lualine_a = {},
                lualine_b = {},
                lualine_c = { 'filename' },
                lualine_x = { 'location' },
                lualine_y = {},
                lualine_z = {}
            },
            tabline = {},
        }
    end
}

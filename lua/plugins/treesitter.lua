return {
    {
        'nvim-treesitter/nvim-treesitter',
        branch = 'main',
        build = ':TSUpdate',
        dependencies = {
            "OXY2DEV/markview.nvim",
            'nvim-treesitter/nvim-treesitter-context',
            'windwp/nvim-ts-autotag',
        },
        config = function()
            require 'treesitter-context'.setup {
                enable = true,
                multiple_threshold = 10,
            }

            local ensureInstalled = { "vimdoc", "javascript", "typescript", "tsx", "html", "xml", "css", "scss", "json", "c", "lua", "rust", "http", "python", "c_sharp", "vue", "yaml", "bash" }
            local alreadyInstalled = require('nvim-treesitter.config').get_installed()
            local parsersToInstall = vim.iter(ensureInstalled)
                :filter(function(parser)
                    return not vim.tbl_contains(alreadyInstalled, parser)
                end)
                :totable()
            if #parsersToInstall > 0 then
                require('nvim-treesitter').install(parsersToInstall)
            end

            vim.api.nvim_create_autocmd('FileType', {
                callback = function()
                    pcall(vim.treesitter.start)
                    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                end,
            })

            require('nvim-ts-autotag').setup({
                opts = {
                    enable_close = true,
                    enable_rename = true,
                    enable_close_on_slash = false,
                },
            })

            local function get_path_in_file()
                local bufnr = vim.api.nvim_get_current_buf()

                local node = vim.treesitter.get_node()

                local file_extension = vim.fn.expand('%:e')

                local function json_parser()
                    local result = {}
                    while node do
                        if tostring(node) == '<node pair>' then
                            local key_node = node:named_child(0):named_child(0)
                            local key = vim.treesitter.get_node_text(key_node, bufnr)
                            table.insert(result, 1, key)
                        end
                        node = node:parent()
                    end
                    return result
                end

                local function yaml_parser()
                    local result = {}
                    while node do
                        if tostring(node) == '<node block_mapping_pair>' then
                            local key_node = node:named_child(0):named_child(0):named_child(0)
                            local key = vim.treesitter.get_node_text(key_node, bufnr)
                            table.insert(result, 1, key)
                        end
                        node = node:parent()
                    end

                    return result
                end

                local res;

                local json_file_extensions = { 'json', 'jsonc', 'js', 'ts', 'jsx', 'tsx' }
                if vim.tbl_contains(json_file_extensions, file_extension) then
                    res = json_parser();
                elseif vim.tbl_contains({ 'yaml', 'yml' }, file_extension) then
                    res = yaml_parser();
                end

                if res ~= nil then
                    local path = vim.fn.join(res, '.')
                    print(path)
                    vim.fn.setreg('+', path)
                end
            end
            vim.keymap.set('n', '<leader>nn', get_path_in_file, { desc = 'Copy path in file' })
        end
    },
    {
        'nvim-treesitter/nvim-treesitter-textobjects',
        branch = 'main',
        dependencies = { 'nvim-treesitter/nvim-treesitter' },
        init = function()
            vim.g.no_plugin_maps = true
        end,
        config = function()
            require('nvim-treesitter-textobjects').setup({
                select = {
                    lookahead = true,
                    include_surrounding_whitespace = true,
                },
                move = {
                    set_jumps = true,
                },
            })

            local select = require('nvim-treesitter-textobjects.select')
            local move = require('nvim-treesitter-textobjects.move')
            local swap = require('nvim-treesitter-textobjects.swap')

            local select_maps = {
                ['aa'] = '@parameter.outer',
                ['ia'] = '@parameter.inner',
                ['af'] = '@function.outer',
                ['if'] = '@function.inner',
                ['id'] = '@conditional.inner',
                ['ad'] = '@conditional.outer',
                ['ac'] = '@class.outer',
                ['ic'] = '@class.inner',
            }
            for key, capture in pairs(select_maps) do
                vim.keymap.set({ 'x', 'o' }, key, function()
                    select.select_textobject(capture, 'textobjects')
                end)
            end

            local move_maps = {
                [']m'] = { 'goto_next_start',     '@function.outer' },
                [']o'] = { 'goto_next_start',     '@class.outer' },
                [']f'] = { 'goto_next_start',     '@conditional.outer' },
                [']M'] = { 'goto_next_end',       '@function.outer' },
                [']O'] = { 'goto_next_end',       '@class.outer' },
                ['[m'] = { 'goto_previous_start', '@function.outer' },
                ['[o'] = { 'goto_previous_start', '@class.outer' },
                ['[f'] = { 'goto_previous_start', '@conditional.outer' },
                ['[M'] = { 'goto_previous_end',   '@function.outer' },
                ['[O'] = { 'goto_previous_end',   '@class.outer' },
                ['[F'] = { 'goto_previous_end',   '@conditional.outer' },
            }
            for key, def in pairs(move_maps) do
                vim.keymap.set('n', key, function()
                    move[def[1]](def[2], 'textobjects')
                end)
            end

            vim.keymap.set('n', '<leader>k', function()
                swap.swap_next('@parameter.inner')
            end)
            vim.keymap.set('n', '<leader>j', function()
                swap.swap_previous('@parameter.inner')
            end)
        end,
    },
}

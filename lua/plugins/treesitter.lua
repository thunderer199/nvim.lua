return {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    dependencies = {
        'nvim-treesitter/nvim-treesitter-textobjects',
        'nvim-treesitter/nvim-treesitter-context',
        'nvim-treesitter/playground',
        'windwp/nvim-ts-autotag',
    },
    config = function()
        require 'treesitter-context'.setup {
            enable = true,
            multiple_threshold = 10,
        };

        require 'nvim-treesitter.configs'.setup {
            -- A list of parser names, or "all"
            ensure_installed = { "help", "javascript", "typescript", "css", "scss", "json", "c", "lua", "rust" },

            -- Install parsers synchronously (only applied to `ensure_installed`)
            sync_install = false,

            -- Automatically install missing parsers when entering buffer
            -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
            auto_install = true,

            indent = {
                enable = true,
            },

            highlight = {
                -- `false` will disable the whole extension
                enable = true,

                -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
                -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
                -- Using this option may slow down your editor, and you may see some duplicate highlights.
                -- Instead of true it can also be a list of languages
                additional_vim_regex_highlighting = false,
            },
            textobjects = {
                select = {
                    enable = true,
                    lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
                    keymaps = {
                        ['aa'] = '@parameter.outer',
                        ['ia'] = '@parameter.inner',
                        ['af'] = '@function.outer',
                        ['if'] = '@function.inner',
                        ['id'] = '@conditional.inner',
                        ['ad'] = '@conditional.outer',
                        ['ac'] = '@class.outer',
                        ['ic'] = '@class.inner',
                    },
                    include_surrounding_whitespace = true,
                },
                move = {
                    enable = true,
                    set_jumps = true, -- whether to set jumps in the jumplist
                    goto_next_start = {
                        [']m'] = '@function.outer',
                        [']]'] = '@class.outer',
                        [']d'] = '@conditional.outer',
                    },
                    goto_next_end = {
                        [']M'] = '@function.outer',
                        [']['] = '@class.outer',
                        ['[D'] = '@conditional.outer',
                    },
                    goto_previous_start = {
                        ['[m'] = '@function.outer',
                        ['[['] = '@class.outer',
                        ['[d'] = '@conditional.outer',
                    },
                    goto_previous_end = {
                        ['[M'] = '@function.outer',
                        ['[]'] = '@class.outer',
                        ['[d'] = '@conditional.outer',
                    },
                
                },
                swap = {
                    enable = true,
                    swap_next = {
                        ["<leader>k"] = "@parameter.inner",
                    },
                    swap_previous = {
                        ["<leader>j"] = "@parameter.inner",
                    },
                },
            },
        }

        require('nvim-ts-autotag').setup({
            opts = {
                -- Defaults
                enable_close = true, -- Auto close tags
                enable_rename = true, -- Auto rename pairs of tags
                enable_close_on_slash = false -- Auto close on trailing </
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
}

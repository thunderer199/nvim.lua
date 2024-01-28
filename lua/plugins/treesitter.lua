return {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    dependencies = {
        'nvim-treesitter/nvim-treesitter-textobjects',
        'nvim-treesitter/nvim-treesitter-context',
        'nvim-treesitter/playground'
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

            autotag = {
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
                    },
                    include_surrounding_whitespace = true,
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

        require("vim.treesitter.query").set("yaml", "injections", "(block_scalar) @sql")

        local ts_utils = require 'nvim-treesitter.ts_utils'
        local function get_json_path()
            local node = ts_utils.get_node_at_cursor()
            local file_extension = vim.fn.expand('%:e')

            local function json_parser()
                local result = {}
                while node do
                    if tostring(node) == '<node pair>' then
                        local key_node = node:named_child(0):named_child(0)
                        table.insert(result, 1, ts_utils.get_node_text(key_node)[1])
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
                        local key = ts_utils.get_node_text(key_node)
                        table.insert(result, 1, key[1])
                    end
                    node = node:parent()
                end

                return result
            end

            local json_file_extensions = {
                'json',
                'jsonc',
                'js',
                'ts',
                'jsx',
                'tsx',
            }

            local res;
            if vim.tbl_contains(json_file_extensions, file_extension) then
                res = json_parser();
            elseif file_extension == 'yaml' then
                res = yaml_parser();
            end

            if res ~= nil then
                local path = vim.fn.join(res, '.')
                print(path)
                vim.fn.setreg('+', path)
            end
        end
        vim.keymap.set('n', '<leader>nn', get_json_path)
    end
}

return {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    dependencies = {
        'nvim-treesitter/nvim-treesitter-textobjects',
        'nvim-treesitter/nvim-treesitter-context',
    },
    config = function()
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

        local ts_utils = require 'nvim-treesitter.ts_utils'
        local function get_json_path()
            local result = {}
            local node = ts_utils.get_node_at_cursor()
            while node do
                if tostring(node) == '<node pair>' then
                    local key_node = node:named_child(0):named_child(0)
                    table.insert(result, 1, ts_utils.get_node_text(key_node)[1])
                end
                node = node:parent()
            end
            print(vim.fn.join(result, '.'))
            -- copy to clipboard
            vim.fn.setreg('+', vim.fn.join(result, '.'))
        end
        vim.keymap.set('n', '<leader>nn', get_json_path)

    end
}

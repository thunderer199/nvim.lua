return {
    'VonHeikemen/lsp-zero.nvim',
    dependencies = {
        -- LSP Support
        { 'neovim/nvim-lspconfig' },
        { 'williamboman/mason.nvim' },
        { 'williamboman/mason-lspconfig.nvim' },

        -- Autocompletion
        { 'hrsh7th/nvim-cmp' },
        { 'hrsh7th/cmp-buffer' },
        { 'hrsh7th/cmp-path' },
        { 'saadparwaiz1/cmp_luasnip' },
        { 'hrsh7th/cmp-nvim-lsp' },

        -- Snippets
        { 'L3MON4D3/LuaSnip' },
        { 'rafamadriz/friendly-snippets' },

        --- emmet
        { 'mattn/emmet-vim' },
    },
    config = function()
        local lsp = require('lsp-zero')

        lsp.preset('recommended')

        lsp.ensure_installed({
            'tsserver',
        })

        local cmp = require('cmp')
        local cmp_select = { behavior = cmp.SelectBehavior.Replace }
        local cmp_mappings = lsp.defaults.cmp_mappings({
            ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
            ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
            ['<C-d>'] = cmp.mapping.scroll_docs(-4),
            ['<C-f>'] = cmp.mapping.scroll_docs(4),
            ['<C-e>'] = cmp.mapping.close(),
            ['<C-y>'] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
            ["<C-s>"] = cmp.mapping(cmp.mapping.complete(), { "i", "s" }),
        })

        -- disable completion with tab
        -- this helps with copilot setup
        cmp_mappings['<Tab>'] = nil
        cmp_mappings['<S-Tab>'] = nil

        lsp.setup_nvim_cmp({
            mapping = cmp_mappings,
            sources = {
                { name = 'emmet_vim', max_item_count = 5, keyword_length = 2 },
                { name = 'luasnip', max_item_count = 5, keyword_length = 3 },
                { name = 'path' },
                { name = 'nvim_lsp' },
                { name = 'buffer' },
            }
        })

        lsp.set_preferences({
            -- suggest_lsp_servers = false,
            sign_icons = {
                error = 'E',
                warn = 'W',
                hint = 'H',
                info = 'I'
            }
        })

        lsp.on_attach(function(client, bufnr)
            local opts = { buffer = bufnr, remap = false }


            vim.keymap.set("n", "<leader>vo", function()
                vim.lsp.buf.execute_command({
                    command = "_typescript.organizeImports",
                    arguments = { vim.fn.expand("%:p") }
                })
            end)

            vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
            vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
            vim.keymap.set("n", "gI", vim.lsp.buf.implementation, opts)
            vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
            vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
            -- go to type definition
            vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, opts)
            vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
            vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
            vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
            vim.keymap.set({ "n", "v" }, "<leader>va", vim.lsp.buf.code_action, opts)
            vim.keymap.set("n", "<leader>vn", vim.lsp.buf.rename, opts)
            vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts)
            vim.keymap.set("n", "<leader>fl", vim.diagnostic.open_float, opts)

            local function copy_diagnostic_for_current_line()
                local diagnostics = vim.diagnostic.get(0, { lnum = vim.api.nvim_win_get_cursor(0)[1] - 1 })
                if next(diagnostics) == nil then
                    print("No diagnostics found on this line")
                    return
                end

                local lines = {}
                for _, diagnostic in ipairs(diagnostics) do
                    table.insert(lines, diagnostic.message)
                end

                local joined_lines = table.concat(lines, "\n")
                vim.fn.setreg('+', joined_lines)
                print("Diagnostic copied to clipboard")
            end

            vim.keymap.set("n", "<leader>cd", copy_diagnostic_for_current_line, opts)
        end)

        lsp.setup()

        vim.diagnostic.config({
            virtual_text = true,
        })


        local luaship = require('luasnip');

        vim.keymap.set("n", "<leader>]", function() luaship.jump(1) end)
        vim.keymap.set("n", "<leader>[", function() luaship.jump(-1) end)
    end
}

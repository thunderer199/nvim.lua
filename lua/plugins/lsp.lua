return {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v4.x',
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

        -- json schemas
        "b0o/schemastore.nvim",
    },
    config = function()
        local lsp = require('lsp-zero')

        local lsp_on_attach = function(_client, bufnr)
            local opts = { buffer = bufnr, remap = false }

            local diagnostic_goto = function(next, severity)
                local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
                severity = severity and vim.diagnostic.severity[severity] or nil
                return function()
                    go({ severity = severity })
                end
            end

            vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
            vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
            vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
            vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
            vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, opts)
            vim.keymap.set("n", "gI", vim.lsp.buf.incoming_calls, opts)
            vim.keymap.set("n", "go", vim.lsp.buf.outgoing_calls, opts)

            vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
            vim.keymap.set("n", "[d", function() vim.diagnostic.goto_prev() end, opts)
            vim.keymap.set("n", "]d", function() vim.diagnostic.goto_next() end, opts)
            vim.keymap.set("n", "[e", diagnostic_goto(false, vim.diagnostic.severity.ERROR), opts);
            vim.keymap.set("n", "]e", diagnostic_goto(true, vim.diagnostic.severity.ERROR), opts);
            vim.keymap.set({ "n", "v" }, "<leader>va", vim.lsp.buf.code_action, opts)
            vim.keymap.set("n", "<leader>vn", vim.lsp.buf.rename, opts)
            vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts)
            vim.keymap.set("n", "<leader>fl", vim.diagnostic.open_float, opts)
            vim.keymap.set("n", "<leader>vd", vim.lsp.buf.document_symbol, opts)
            vim.keymap.set("n", "<leader>vw", vim.lsp.buf.workspace_symbol, opts)

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
        end


        lsp.extend_lspconfig({
            sign_text = true,
            lsp_attach = lsp_on_attach,
            capabilities = require('cmp_nvim_lsp').default_capabilities(),
        })

        require('mason').setup({})
        require('mason-lspconfig').setup({
            ensure_installed = { 'tsserver', 'jsonls' },
            handlers = {
                lsp.default_setup,
            }
        })

        require('lspconfig').jsonls.setup({
            settings = {
                json = {
                    schemas = require('schemastore').json.schemas(),
                    validate = { enable = true },
                },
            },
        })

        require('lspconfig').tsserver.setup({
            settings = {
                typescript = {
                    inlayHints = {
                        includeInlayParameterNameHints = "all",
                        includeInlayParameterNameHintsWhenArgumentMatchesName = true,
                        includeInlayFunctionParameterTypeHints = true,
                        includeInlayVariableTypeHints = true,
                        includeInlayVariableTypeHintsWhenTypeMatchesName = true,
                        includeInlayPropertyDeclarationTypeHints = true,
                        includeInlayFunctionLikeReturnTypeHints = true,
                        includeInlayEnumMemberValueHints = true,
                    },
                },
            }
        })

        require('lspconfig').basedpyright.setup({
            settings = {
                basedpyright = {
                    analysis = {
                        typeCheckingMode = "standard",
                        logLevel = "Trace",
                        autoSearchPaths = true,
                        useLibraryCodeForTypes = true
                    }
                },
            }
        })

        local util = require("lspconfig.util")

        require('lspconfig').angularls.setup({
            root_dir = util.root_pattern("angular.json", "project.json"),
        })

        require('lspconfig').lua_ls.setup({
            settings = {
                Lua = {
                    completion = {
                        callSnippet = "Replace",
                    },
                },
            },
        })

        local cmp = require('cmp')
        local cmp_mappings = ({
            ['<C-k>'] = cmp.mapping(function()
                if cmp.visible() then
                    cmp.select_prev_item({ behavior = cmp.SelectBehavior.Replace })
                else
                    cmp.complete()
                end
            end, { "i", "s" }),
            ['<C-j>'] = cmp.mapping(function()
                if cmp.visible() then
                    cmp.select_next_item({ behavior = cmp.SelectBehavior.Replace })
                else
                    cmp.complete()
                end
            end, { "i", "s" }),
            ['<C-f>'] = cmp.mapping.scroll_docs(-4),
            ['<C-d>'] = cmp.mapping.scroll_docs(4),
            ['<C-l>'] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
            ['<CR>'] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
            ['<C-e>'] = cmp.mapping.abort(),
            ['<Down>'] = cmp.mapping.close(),
            ['<Up>'] = cmp.mapping.close(),
            ['<C-p>'] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = true }),
            ['<C-s>'] = cmp.mapping(function()
                if cmp.visible() then
                    cmp.abort()
                else
                    cmp.complete()
                end
            end, { "i", "s" })
        })
        cmp.setup({
            mapping = cmp_mappings,
            preselect = cmp.PreselectMode.Item,
            completion = {
                completeopt = 'menu,menuone,noinsert'
            },
            window = {
                documentation = cmp.config.window.bordered()
            },
            formatting = {
                expandable_indicator = true,
                fields = { 'abbr', 'menu', 'kind' },
                format = function(entry, item)
                    local n = entry.source.name
                    if n == 'nvim_lsp' then
                        item.menu = '[LSP] ' .. (item.menu or '')
                    elseif n == 'nvim_lua' then
                        item.menu = '[nvim] ' .. (item.menu or '')
                    else
                        item.menu =  string.format('[%s] ', n) .. (item.menu or '')
                    end
                    return item
                end,
            },
            snippet = {
                expand = function(args)
                    require('luasnip').lsp_expand(args.body)
                end,
            },
            sources = {
                { name = 'luasnip',              max_item_count = 5, keyword_length = 3 },
                { name = 'path' },
                { name = 'nvim_lsp' },
                { name = "vim-dadbod-completion" },
                { name = 'buffer' },
            }
        })

        local cmd_mapping = {
            ['<C-j>'] = {
                c = function(fallback)
                    if cmp.visible() then
                        cmp.select_next_item()
                    else
                        fallback()
                    end
                end,
            },
            ['<C-k>'] = {
                c = function(fallback)
                    if cmp.visible() then
                        cmp.select_prev_item()
                    else
                        fallback()
                    end
                end,
            },
            ['<C-e>'] = {
                c = cmp.mapping.abort()
            },
            ['<C-l>'] = {
                c = cmp.mapping.confirm({ select = false }),
            },
            ['<C-s>'] = {
                c = function()
                    if cmp.visible() then
                        cmp.abort()
                    else
                        cmp.complete()
                    end
                end,
            },

        }
        cmp.setup.cmdline({ '/', '?' }, {
            mapping = cmd_mapping,
            sources = {
                { name = 'buffer' }
            }
        })

        cmp.setup.cmdline(':', {
            mapping = cmd_mapping,
            sources = cmp.config.sources(
                { { name = 'path' } },
                { { name = 'cmdline' } }
            ),
            matching = { disallow_symbol_nonprefix_matching = false }
        })

        local luasnip = require('luasnip');

        require("luasnip.loaders.from_lua").load({ paths = { "~/.config/nvim/lua/vlad/snippets" } })
        require("luasnip.loaders.from_vscode").load({ paths = { "~/.config/nvim/lua/vlad/vscode_snippets" } })


        vim.keymap.set({ "i", "n" }, "<C-m>", function()
            if luasnip.choice_active() then
                luasnip.change_choice(1)
            end
        end, { desc = "Luasnip change choice" })
        vim.keymap.set({ "i", "n" }, "<C-n>", function()
            if luasnip.expandable() then
                luasnip.expand()
            elseif luasnip.jumpable(1) then
                luasnip.jump(1)
            end
        end, { desc = "Luasnip jump forward" })
        vim.keymap.set({ "i", "n" }, "<C-b>", function()
            if luasnip.jumpable(-1) then
                luasnip.jump(-1)
            end
        end, { desc = "Luasnip jump backward" })

        vim.diagnostic.config({
            virtual_text = true,
        })
    end
}

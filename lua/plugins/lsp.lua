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
        { 'hrsh7th/cmp-nvim-lsp' },

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

        vim.diagnostic.config({
            virtual_text = true,
        })
    end
}

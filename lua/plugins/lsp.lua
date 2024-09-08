return {
    'neovim/nvim-lspconfig',
    dependencies = {
        -- LSP Support
        { 'williamboman/mason.nvim',          config = true },
        { 'williamboman/mason-lspconfig.nvim' },

        'WhoIsSethDaniel/mason-tool-installer.nvim',

        -- Autocompletion
        { 'hrsh7th/nvim-cmp' },
        { 'hrsh7th/cmp-nvim-lsp' },

        -- json schemas
        "b0o/schemastore.nvim",
    },
    config = function()
        local lsp_on_attach = function(bufnr)
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
            vim.keymap.set("n", "[d", diagnostic_goto(false), opts)
            vim.keymap.set("n", "]d", diagnostic_goto(true), opts)
            vim.keymap.set("n", "[e", diagnostic_goto(false, vim.diagnostic.severity.ERROR), opts);
            vim.keymap.set("n", "]e", diagnostic_goto(true, vim.diagnostic.severity.ERROR), opts);
            vim.keymap.set({ "n", "v" }, "<leader>va", vim.lsp.buf.code_action, opts)
            vim.keymap.set("n", "<leader>vn", vim.lsp.buf.rename, opts)
            vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts)
            vim.keymap.set("n", "<leader>fl", vim.diagnostic.open_float, opts)
            vim.keymap.set("n", "<leader>vd", vim.lsp.buf.document_symbol, opts)
            vim.keymap.set("n", "<leader>vw", vim.lsp.buf.workspace_symbol, opts)
        end

        local actions = {
            tsserver = {
                {
                    '<leader>vo',
                    function()
                        vim.lsp.buf.code_action {
                            apply = true,
                            context = {
                                only = { 'source.organizeImports.ts' },
                                diagnostics = {},
                            },
                        }
                    end,
                    { desc = 'Typescript Organize Imports' },
                },
                {
                    '<leader>vi',
                    function()
                        vim.lsp.buf.code_action {
                            apply = true,
                            context = {
                                only = { 'source.addMissingImports.ts' },
                                diagnostics = {},
                            },
                        }
                    end,
                    { desc = 'Typescript Add Missing Imports' },
                },
                {
                    '<leader>vf',
                    function()
                        vim.lsp.buf.code_action {
                            apply = true,
                            context = {
                                only = { 'source.fixAll.ts' },
                                diagnostics = {},
                            },
                        }
                    end,
                    { desc = 'Typescript Fix All' },
                },
                {
                    '<leader>vO',
                    function()
                        vim.lsp.buf.code_action {
                            apply = true,
                            context = {
                                only = { 'source.removeUnused.ts' },
                                diagnostics = {},
                            },
                        }
                    end,
                    { desc = 'Typescript Remove Unused' },
                },
            },
            ruff = {
                {
                    '<leader>vo',
                    function()
                        vim.lsp.buf.code_action({
                            apply = true,
                            context = {
                                only = { 'source.organizeImports' },
                                diagnostics = {},
                            }
                        })
                    end,
                    { desc = 'Ruff Organize Imports' },
                },
                {
                    '<leader>vf',
                    function()
                        vim.lsp.buf.code_action({
                            apply = true,
                            context = {
                                only = { 'source.fixAll' },
                                diagnostics = {},
                            }
                        })
                    end,
                    { desc = 'Ruff Fix All' },
                },
            }
        }

        vim.api.nvim_create_autocmd('LspAttach', {
            group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
            callback = function(event)
                -- The following two autocommands are used to highlight references of the
                -- word under your cursor when your cursor rests there for a little while.
                --    See `:help CursorHold` for information about when this is executed
                --
                -- When you move your cursor, the highlights will be cleared (the second autocommand).
                local client = vim.lsp.get_client_by_id(event.data.client_id)

                lsp_on_attach(event.buf)

                if client and actions[client.name] then
                    for _, action in ipairs(actions[client.name]) do
                        vim.keymap.set('n', action[1], action[2], { buffer = event.buf, desc = action[3].desc })
                    end
                end

                if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
                    local highlight_augroup = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })
                    vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                        buffer = event.buf,
                        group = highlight_augroup,
                        callback = vim.lsp.buf.document_highlight,
                    })

                    vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                        buffer = event.buf,
                        group = highlight_augroup,
                        callback = vim.lsp.buf.clear_references,
                    })

                    vim.api.nvim_create_autocmd('LspDetach', {
                        group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
                        callback = function(event2)
                            vim.lsp.buf.clear_references()
                            vim.api.nvim_clear_autocmds { group = 'lsp-highlight', buffer = event2.buf }
                        end,
                    })
                end

                if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
                    vim.keymap.set(
                        'n',
                        '<leader>ih',
                        function()
                            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
                        end,
                        { buffer = event.buf, desc = 'Toggle Inlay Hints' }
                    );
                end
            end,
        })

        local util = require("lspconfig.util")
        local servers = {
            jsonls = {
                settings = {
                    json = {
                        schemas = require('schemastore').json.schemas(),
                        validate = { enable = true },
                    },
                },
            },
            tsserver = {
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
            },
            basedpyright = {
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
            },
            angularls = {
                root_dir = util.root_pattern("angular.json", "project.json"),
            },
            lua_ls = {
                settings = {
                    Lua = {
                        completion = {
                            callSnippet = "Replace",
                        },
                    },
                },
            },
            typos_lsp = {
                init_options = {
                    diagnosticSeverity = "Information",
                },
            },
            volar = {
                filetypes = { 'vue' },
                init_options = {
                    vue = {
                        hybridMode = false,
                    },
                },
            },
        }

        local capabilities = vim.lsp.protocol.make_client_capabilities()
        capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

        require('mason-lspconfig').setup({
            ensure_installed = { 'tsserver', 'jsonls' },
            handlers = {
                function(server_name)
                    local server = servers[server_name] or {}
                    -- This handles overriding only values explicitly passed
                    -- by the server configuration above. Useful when disabling
                    -- certain features of an LSP (for example, turning off formatting for tsserver)
                    server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
                    require('lspconfig')[server_name].setup(server)
                end,
            }
        })

        vim.diagnostic.config({
            virtual_text = true,
        })

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
}

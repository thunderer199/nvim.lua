return {
    {
        'hrsh7th/nvim-cmp',
        dependencies = {
            { 'hrsh7th/cmp-buffer' },
            { 'hrsh7th/cmp-path' },
            { 'hrsh7th/cmp-nvim-lsp' },

            -- dependency on snippets
            { 'L3MON4D3/LuaSnip' },
            { 'saadparwaiz1/cmp_luasnip' },
        },
        config = function()
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
                            item.menu = string.format('[%s] ', n) .. (item.menu or '')
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
        end
    }
}

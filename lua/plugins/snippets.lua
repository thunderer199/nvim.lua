return {
    'L3MON4D3/LuaSnip',
    config = function()
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
    end
}

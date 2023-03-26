return {
    'theprimeagen/harpoon',
    config = function()
        local mark = require("harpoon.mark")
        local ui = require("harpoon.ui")
        local harpoon = require("harpoon")

        vim.keymap.set("n", "<leader>a", mark.add_file)
        vim.keymap.set("n", "<C-e>", ui.toggle_quick_menu)

        vim.keymap.set("n", "<C-n>", function() ui.nav_next() end)
        vim.keymap.set("n", "<C-z>", function() ui.nav_prev() end)


        -- map alt + hjkl to navigate between files
        vim.keymap.set("n", "˙", function() ui.nav_file(1) end)
        vim.keymap.set("n", "∆", function() ui.nav_file(2) end)
        vim.keymap.set("n", "˚", function() ui.nav_file(3) end)
        vim.keymap.set("n", "¬", function() ui.nav_file(4) end)

        harpoon.setup({
            global_settings = {
                mark_branch = true
            }
        })
    end
}

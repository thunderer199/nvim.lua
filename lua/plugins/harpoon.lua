return {
    'theprimeagen/harpoon',
    config = function()
        local mark = require("harpoon.mark")
        local ui = require("harpoon.ui")
        local harpoon = require("harpoon")

        vim.keymap.set("n", "<leader>a", mark.add_file)
        vim.keymap.set("n", "<C-e>", ui.toggle_quick_menu)
        vim.keymap.set("n", "<leader>aa", mark.rm_file)

        vim.keymap.set("n", "<C-n>", function() ui.nav_next() end)
        vim.keymap.set("n", "<C-z>", function() ui.nav_prev() end)

        harpoon.setup({
            global_settings = {
                mark_branch = true
            }
        })
    end
}

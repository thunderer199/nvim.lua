vim.g.mapleader = " "
vim.keymap.set("n", "-", ":Oil<CR>")

-- move undent
vim.keymap.set("v", "<M-j>", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "<M-k>", ":m '<-2<CR>gv=gv")

-- stay in center
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- copy to system buffer
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

vim.keymap.set("n", "Q", "<nop>")
vim.keymap.set('n', 'QQ', '<cmd>qa!<CR>')

-- replace word under cursor
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- quick fix navigation
vim.keymap.set(
    "n",
    "<C-k>",
    function ()
        require('trouble').next({ jump = true })
    end,
    { desc = "Next quickfix" }
)
vim.keymap.set(
    "n",
    "<C-j>",
    function ()
        require('trouble').prev({ jump = true })
    end,
    { desc = "Previous quickfix" }
)

-- buffer navigation
vim.keymap.set("n", "]b", "<cmd>bn<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "[b", "<cmd>bp<CR>", { desc = "Previous buffer" })

-- save file faster
vim.keymap.set("n", "<leader>w", "<cmd>w<CR>", { desc = "Save file" })
vim.keymap.set('n', '<leader>q', '<cmd>q<CR>', { desc = 'Quit' })
vim.keymap.set('n', '<leader>x', '<cmd>x<CR>', { desc = 'Save and Quit' })

-- gF to create a new file
vim.keymap.set("n", "gF", ":e <cfile><CR>", { desc = "Create a new file under cursor" })

-- splits
vim.keymap.set("n", "Ws", ':split<CR><C-w>k', { desc = "Split window horizontally" })
vim.keymap.set("n", "Wv", ':vsplit<CR><C-w>l', { desc = "Split window vertically" })

-- close tab
vim.keymap.set("n", "gx", "<cmd>tabclose<CR>", { desc = "Close tab" })

-- -- open URL under cursor in browser
-- vim.keymap.set('n', 'gx', function()
--   local url = vim.fn.expand('<cWORD>')
--   vim.fn.jobstart({'open', url}, {detach = true})
-- end)

vim.keymap.set("n", "<leader>X", "<cmd>!chmod +x %<CR>", { desc = "Make file executable" })

-- mapping for diffget
vim.keymap.set("n", "<leader>dh", ":diffget //2<CR>")
vim.keymap.set("n", "<leader>dl", ":diffget //3<CR>")

vim.keymap.set("n", "<leader>z", function()
    local type = vim.bo.filetype
    if type == 'python' then
        vim.cmd('!python %')
    elseif type == 'javascript' then
        vim.cmd('!node %')
    elseif type == 'sh' then
        vim.cmd('!bash %')
    else
        print("No run command for filetype: " .. type)
    end

end)

vim.keymap.set(
    "n",
    "<leader>e",
    function()
        vim.cmd('enew')
        vim.bo.buftype = 'nofile'
        vim.bo.bufhidden = 'hide'
        vim.bo.swapfile = false

        print("Scratch buffer created")
    end,
    { desc = "Create Scratch buffer" }
)

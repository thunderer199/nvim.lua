vim.g.mapleader = " "
vim.keymap.set("n", "-", ":Oil<CR>")

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
vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")

-- buffer navigation
vim.keymap.set("n", "<leader>bn", "<cmd>bn<CR>")
vim.keymap.set("n", "<leader>bp", "<cmd>bp<CR>")
vim.keymap.set("n", "<leader>bl", ":buffers<CR>")

-- save file faster
vim.keymap.set("n", "<leader>w", "<cmd>w<CR>")
vim.keymap.set('n', '<leader>q', '<cmd>q<CR>')
vim.keymap.set('n', '<leader>x', '<cmd>x<CR>')

-- gF to cteate a new file
vim.keymap.set("n", "gF", ":e <cfile><CR>")

-- C-w to <leader>e
vim.keymap.set("n", "<leader>e", "<C-w>")

-- splits
vim.keymap.set("n", "ws", ':split<CR><C-w>k')
vim.keymap.set("n", "wv", ':vsplit<CR><C-w>l')

-- close tab
vim.keymap.set("n", "gx", "<cmd>tabclose<CR>")


-- mapping for diffget
vim.keymap.set("n", "<leader>dh", ":diffget //2<CR>")
vim.keymap.set("n", "<leader>dl", ":diffget //3<CR>")

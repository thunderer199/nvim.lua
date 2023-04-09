vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- move undent
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- stay in center
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- paste without buffer rewrite
vim.keymap.set("x", "<leader>p", [["_dP]])

-- copy to system buffer
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

-- delete to void buffer
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])

vim.keymap.set("n", "Q", "<nop>")
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)

-- quick fix navigation
vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

-- replace word under cursor
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- buffer navigation
vim.keymap.set("n", "<leader>bn", "<cmd>bn<CR>")
vim.keymap.set("n", "<leader>bp", "<cmd>bp<CR>")

-- save file faster
vim.keymap.set("n", "<leader>w", "<cmd>w<CR>")
vim.keymap.set('n', '<leader>q', '<cmd>q<CR>')
vim.keymap.set('n', '<leader>x', '<cmd>x<CR>')
vim.keymap.set('n', 'QQ', '<cmd>q!<CR>')

-- C-w to <leader>e
vim.keymap.set("n", "<leader>e", "<C-w>")

-- splits
vim.keymap.set("n", "ss", ':split<CR><C-w>k')
vim.keymap.set("n", "sv", ':vsplit<CR><C-w>l')

vim.keymap.set('n', '<leader>sh', '<C-w>h')
vim.keymap.set('n', '<leader>sk', '<C-w>k')
vim.keymap.set('n', '<leader>sj', '<C-w>j')
vim.keymap.set('n', '<leader>sl', '<C-w>l')

-- go to last edit 
vim.keymap.set('n', '<leader>g', '<cmd>normal! `^<CR>')

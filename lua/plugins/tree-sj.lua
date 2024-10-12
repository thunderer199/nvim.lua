return {
  'Wansmer/treesj',
  keys = {
    { '<leader>m', function() require('treesj').toggle() end, desc = 'Toggle Treesitter Join' },
  },
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
  opts = { max_join_length = 1000, use_default_keymaps = false },
}

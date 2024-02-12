return {
  'kristijanhusak/vim-dadbod-ui',
  dependencies = {
    { 'tpope/vim-dadbod',                     lazy = true },
    { 'kristijanhusak/vim-dadbod-completion', ft = { 'sql', 'mysql', 'plsql' }, lazy = true },
  },
  cmd = { 'DBUI', 'DBUIToggle', 'DBUIAddConnection', 'DBUIFindBuffer' },
  init = function()
    -- Your DBUI configuration
    vim.g.db_ui_use_nerd_fonts = 1
    vim.g.db_ui_execute_on_save = 0

    vim.keymap.set('n', '<leader>du', '<cmd>DBUIToggle<CR>');
    vim.keymap.set('n', '<leader>dr', ':normal vip<CR><PLUG>(DBUI_ExecuteQuery)');
    vim.keymap.set('n', '<leader>ds', '<PLUG>(DBUI_ExecuteQuery)');
  end,
}

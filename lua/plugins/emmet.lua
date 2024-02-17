return {
  'mattn/emmet-vim',
  lazy = false,
  config = function()
    vim.g.user_emmet_install_global = 0
    -- vim.keymap.set('i', '<C-y>,', '<plug>(emmet-expand-abbr)');
    -- vim.keymap.set('i', '<C-y>u', '<plug>(emmet-update-tag)');
    -- vim.keymap.set('i', '<C-y>;', '<plug>(emmet-expand-word)');
    -- vim.keymap.set('i', '<C-y>d', '<plug>(emmet-balance-tag-inward)');
    -- vim.keymap.set('i', '<C-y>D', '<plug>(emmet-balance-tag-outward)');
    -- vim.keymap.set('i', '<C-y>n', '<plug>(emmet-move-next)');
    -- vim.keymap.set('i', '<C-y>N', '<plug>(emmet-move-prev)');
    -- vim.keymap.set('i', '<C-y>i', '<plug>(emmet-image-size)');
    -- vim.keymap.set('i', '<C-y>/', '<plug>(emmet-toggle-comment)');
    -- vim.keymap.set('i', '<C-y>j', '<plug>(emmet-split-join-tag)');
    -- vim.keymap.set('i', '<C-y>k', '<plug>(emmet-remove-tag)');
    -- vim.keymap.set('i', '<C-y>a', '<plug>(emmet-anchorize-url)');
    -- vim.keymap.set('i', '<C-y>A', '<plug>(emmet-anchorize-summary)');
    -- vim.keymap.set('i', '<C-y>m', '<plug>(emmet-merge-lines)');
    -- vim.keymap.set('i', '<C-y>c', '<plug>(emmet-code-pretty)');
  end
}

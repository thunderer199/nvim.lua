return {
  "mfussenegger/nvim-lint",
  config = function()
    local lint = require("lint")

    lint.linters_by_ft = {
      javascript = { "eslint" },
      typescript = { "eslint" },
      javascriptreact = { "eslint" },
      typescriptreact = { "eslint" },
      svelte = { "eslint" },
      css = { "stylelint" },
      scss = { "stylelint" },
      less = { "stylelint" },
      stylus = { "stylelint" },
    }

    local util = require("vlad.util")

    local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
      group = lint_augroup,
      callback = function()
        local cwd = vim.fn.getcwd()
        local dir = cwd;

        local rootDir =  cwd  .. '/package.json'
        if vim.fn.filereadable(rootDir) ~= 1 then
          local localDir = util.find_parent_with_package_json(vim.fn.expand("%:p"))
          dir = localDir or cwd
        end
        lint.try_lint(nil, {
          ignore_errors = true,
          cwd = dir,
        })
      end,
    })
  end,
}

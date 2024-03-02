return {
    'JellyApple102/flote.nvim',
    config = true,
    opts = {
        files = {
            cwd = function()
                local util = require('vlad.util')

                local git_dir = util.get_git_cwd()
                if git_dir == nil then
                    return vim.fn.getcwd()
                else
                    return git_dir
                end
            end
        }
    }
};

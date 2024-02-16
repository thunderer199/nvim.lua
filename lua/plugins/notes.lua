return {
    'JellyApple102/flote.nvim',
    config = true,
    opts = {
        files = {
            cwd = function()
                local get_git_cwd = function()
                    local git_dir = require('telescope.utils').get_os_command_output({ 'git', 'rev-parse',
                            '--show-toplevel' })
                        [1]

                    print(git_dir)
                    return git_dir
                end

                local git_dir = get_git_cwd()
                if git_dir == nil then
                    return vim.fn.getcwd()
                else
                    return git_dir
                end
            end
        }
    }
};

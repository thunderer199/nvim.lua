local M = {};

local get_git_cwd = function()
    local utils = require('telescope.utils')
    local git_dir = utils.get_os_command_output({ 'git', 'rev-parse', '--show-toplevel' })[1]

    return git_dir
end

local get_base_path = function()
    local git_dir = get_git_cwd()
    if git_dir == nil then
        return vim.loop.cwd()
    else
        return git_dir
    end
end

M.get_git_cwd = get_git_cwd;
M.get_base_path = get_base_path;

return M;

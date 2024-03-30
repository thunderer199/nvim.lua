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


local function split_into_lines(str)
    local t = {}
    for s in str:gmatch("[^\r\n]+") do
        table.insert(t, s)
    end
    return t
end

local function trim_string(s, char)
    return s:gsub("^" .. char .. "(.-)" .. char .. "$", "%1")
end


M.get_git_cwd = get_git_cwd;
M.get_base_path = get_base_path;
M.split_into_lines = split_into_lines;
M.trim_string = trim_string;

return M;

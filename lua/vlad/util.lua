local M = {};

---@return string|nil
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
    local pattern = "^%" .. char .. "*(.-)%" .. char .. "*$"
    return (s:gsub(pattern, "%1"))
end

local function trim_quotes(s)
    -- trim ", ', ` and whitespace
    local characters = { "\"", "'", "`", " " }
    for _, char in ipairs(characters) do
        s = trim_string(s, char)
    end
    return s
end

local function starts_with(full_string, prefix)
    return full_string:sub(1, #prefix) == prefix
end

-- Find the parent directory that contains a file
---@param path string 
---@param file_name string
local find_parent_with_file = function(path, file_name)
    if path == "" then
        return nil
    end
    if path == nil then
        return nil
    end
    -- start with / to avoid infinite loop
    if not starts_with(path, "/") then
        return nil
    end

    local current_path = path
    while current_path ~= "/" do
        local package_json = current_path .. "/" .. file_name
        if vim.fn.filereadable(package_json) == 1 then
            return current_path
        end
        current_path = vim.fn.fnamemodify(current_path, ":h")
    end
    return nil
end

local find_parent_with_package_json = function(path)
    if path == "" then
        return nil
    end
    if path == nil then
        return nil
    end
    -- start with / to avoid infinite loop
    if not starts_with(path, "/") then
        return nil
    end

    local current_path = path
    while current_path ~= "/" do
        local package_json = current_path .. "/package.json"
        if vim.fn.filereadable(package_json) == 1 then
            return current_path
        end
        current_path = vim.fn.fnamemodify(current_path, ":h")
    end
    return nil
end


M.find_parent_with_package_json = find_parent_with_package_json;
M.find_parent_with_file = find_parent_with_file;
M.starts_with = starts_with;
M.get_git_cwd = get_git_cwd;
M.get_base_path = get_base_path;
M.split_into_lines = split_into_lines;
M.trim_string = trim_string;
M.trim_quotes = trim_quotes;

return M;

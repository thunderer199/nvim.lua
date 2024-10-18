local function try_file(main_path, extensions)
    for _, ext in ipairs(extensions) do
        if vim.loop.fs_stat(main_path .. ext) then
            return main_path .. ext
        end
    end

    return main_path
end

local function combine_parts(basepath, filename, postfixes, prefixes, extensions)
    local result = {}
    for _, postfix in ipairs(postfixes) do
        table.insert(result, basepath .. filename .. postfix)
    end

    for _, prefix in ipairs(prefixes) do
        for _, ext in ipairs(extensions) do
            table.insert(result, basepath .. prefix .. filename .. ext)
        end
    end

    return result
end

local function get_first_existing_file(files)
    for _, file in ipairs(files) do
        if vim.uv.fs_stat(file) then
            return file
        end
    end

    return nil
end

local function path_to_snapshot(main_path, extension)
    local splited = vim.split(main_path, "/")
    -- add __snapshots__ folder to the path
    -- e.g. src/app/app.component.spec.ts -> src/app/__snapshots__/app.component.spec.ts.snap
    local last = splited[#splited]
    splited[#splited] = "__snapshots__"
    splited[#splited + 1] = last .. extension .. '.snap'
    local p = table.concat(splited, "/")
    return p
end

local function cartesian_product(t1, t2)
    local result = {}
    for i = 1, #t1 do
        for j = 1, #t2 do
            result[#result + 1] = t1[i] .. t2[j]
        end
    end
    return result
end

local function ends_with(str, ending)
    return str:sub(-#ending) == ending
end

-- Angular files jump
vim.api.nvim_create_user_command("JToFile", function(opts)
    local main_file_extensions = { ".ts", ".tsx", ".js", ".jsx" , ".vue", ".py" }
    local style_extensions = { ".scss", ".css", ".less", ".module.scss", ".module.css", ".module.less" }
    local story_extensions = { ".stories.tsx", ".stories.ts" , ".stories.js" , ".stories.jsx"}

    local test_prefixes = { "test_" }
    local test_postfixes = { ".spec", ".test", "_test" }
    local test_file_extensions = cartesian_product(test_postfixes, main_file_extensions)

    local type = opts.args
    local path = vim.fn.expand("%:r")
    local main_path = path
    local filename = path:match("([^/]+)$")
    local filename_index = path:find(filename)
    -- folder is path without filename
    local folder = path:sub(1, filename_index - 1)
    if ends_with(path, ".spec") then
        main_path = path:gsub(".spec$", "")
    elseif ends_with(path, ".test") then
        main_path = path:gsub(".test$", "")
    elseif ends_with(path, "_test") then
        main_path = path:gsub("_test$", "")
    elseif ends_with(path, ".module") then
        main_path = path:gsub(".module$", "")
    elseif ends_with(path, ".stories") then
        main_path = path:gsub(".stories$", "")
    elseif filename:find("^test_") then
        main_path = path:gsub("/test_", "/")
    end

    -- for snapshot move one level up
    if path:find(".snap") then
        local splited = vim.split(main_path, "/")
        -- remove last folder element from the path
        -- e.g. src/app/__snapshots__/app.component.spec.ts.snap -> src/app/app.component.spec.ts
        table.remove(splited, #splited - 1)
        main_path = vim.fn.join(splited, "/")
        -- -- remove .ts from env of the line
        -- main_path = main_path:gsub("%.spec%.ts$", "")
        -- main_path = main_path:gsub("%.test%.ts$", "")

        for _, ext in ipairs(test_file_extensions) do
            -- replace . with %. to escape it
            ext = ext:gsub("%.", "%%.")
            main_path = main_path:gsub(ext .. "$", "")
        end
    end

    if type == 'spec' then
        local possible_files = combine_parts(folder, filename, test_file_extensions, test_prefixes, main_file_extensions)
        local file = get_first_existing_file(possible_files)
        if not file then
            print("Spec file not found")
        else
            vim.fn.execute(":find " .. file)
        end
    elseif type == 'main' then
        vim.fn.execute(":find " .. try_file(main_path, main_file_extensions))
    elseif type == 'scss' then
        vim.fn.execute(":find " .. try_file(main_path, style_extensions))
    elseif type == 'html' then
        vim.fn.execute(":find " .. try_file(main_path, { ".html" }))
    elseif type == 'story' then
        vim.fn.execute(":find " .. try_file(main_path, story_extensions))
    elseif type == 'snapshot' then
        local snap_path;
        for _, ext in ipairs(test_file_extensions) do
            local _path = path_to_snapshot(main_path, ext)
            if vim.loop.fs_stat(_path) then
                snap_path = _path
                break
            end
        end

        if snap_path then
            vim.fn.execute(":find " .. snap_path)
        else
            print("Snapshot file not found")
        end
    else
        print("Unknown type", type)
    end
end, { nargs = 1 })

-- go to spec file
vim.keymap.set('n', '<leader>at', ':JToFile spec<CR>')
-- got to componrny file
vim.keymap.set('n', '<leader>am', ':JToFile main<CR>')
-- go to scss file
vim.keymap.set('n', '<leader>as', ':JToFile scss<CR>')
-- go to html file
vim.keymap.set('n', '<leader>ah', ':JToFile html<CR>')
-- go to story file
vim.keymap.set('n', '<leader>aS', ':JToFile story<CR>')
--  go to snapshot file
vim.keymap.set('n', '<leader>an', ':JToFile snapshot<CR>')

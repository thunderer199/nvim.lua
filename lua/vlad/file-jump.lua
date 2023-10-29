local function try_file(main_path, extensions)
    for _, ext in ipairs(extensions) do
        if vim.loop.fs_stat(main_path .. ext) then
            return main_path .. ext
        end
    end

    return main_path
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

-- Angular files jump
vim.api.nvim_create_user_command("JToFile", function(opts)
    local js_extensions = { ".ts", ".tsx", ".js", ".jsx" , ".vue" }
    local test_postfixes = { ".spec", ".test" }
    local style_extensions = { ".scss", ".css", ".less", ".module.scss", ".module.css", ".module.less" }
    local story_extensions = { ".stories.tsx", ".stories.ts" , ".stories.js" , ".stories.jsx"}
    local test_js_extensions = cartesian_product(test_postfixes, js_extensions)

    local type = opts.args
    local path = vim.fn.expand("%:r")
    local main_path = path
    if path:find(".spec") then
        main_path = path:gsub(".spec$", "")
    elseif path:find(".test") then
        main_path = path:gsub(".test$", "")
    elseif path:find(".module") then
        main_path = path:gsub(".module$", "")
    elseif path:find(".stories") then
        main_path = path:gsub(".stories$", "")
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

        for _, ext in ipairs(test_js_extensions) do
            -- replace . with %. to escape it
            ext = ext:gsub("%.", "%%.")
            main_path = main_path:gsub(ext .. "$", "")
        end
    end

    if type == 'spec' then
        vim.fn.execute(":find " .. try_file(main_path, test_js_extensions))
    elseif type == 'main' then
        vim.fn.execute(":find " .. try_file(main_path, js_extensions))
    elseif type == 'scss' then
        vim.fn.execute(":find " .. try_file(main_path, style_extensions))
    elseif type == 'html' then
        vim.fn.execute(":find " .. try_file(main_path, { ".html" }))
    elseif type == 'story' then
        vim.fn.execute(":find " .. try_file(main_path, story_extensions))
    elseif type == 'snapshot' then
        local p;
        for _, ext in ipairs(test_js_extensions) do
            local f = path_to_snapshot(main_path, ext)
            if vim.loop.fs_stat(f) then
                p = f
                break
            end
        end

        print(p)
        if p then
            vim.fn.execute(":find " .. p)
        else
            print("Snapshot file not found")
        end
    else
        print("Unknown type")
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

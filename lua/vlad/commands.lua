vim.api.nvim_create_user_command("Cppath", function()
    local path = vim.fn.expand("%")
    vim.fn.setreg("+", path)
    vim.notify('Copied "' .. path .. '" to the clipboard!')
end, {})

vim.keymap.set('n', '<leader>cp', ':Cppath<CR>')

local function try_file(main_path, extensions)
    for _, ext in pairs(extensions) do
        if vim.fn.filereadable(main_path .. ext) == 1 then
            return main_path .. ext
        end
    end

    return main_path
end

-- Angular files jump
vim.api.nvim_create_user_command("JToFile", function(opts)
    local type = opts.args
    local path = vim.fn.expand("%:r")
    local main_path = path
    if path:find(".spec") then
        main_path = path:gsub(".spec", "")
    elseif path:find(".test") then
        main_path = path:gsub(".test", "")
    end

    -- for snapshot move one level up
    if path:find(".snap") then
        local splited = vim.split(main_path, "/")
        local last = table.remove(splited)
        table.remove(splited)
        table.insert(splited, last)
        main_path = vim.fn.join(splited, "/")
        -- remove .ts from env of the line
        main_path = main_path:gsub(".ts$", "")
    end

    local js_extensions = { ".ts", ".tsx", ".js", ".jsx" }
    local style_extensions = { ".scss", ".css", ".less", ".module.scss", ".module.css", ".module.less" }
    if type == 'spec' then
        local p = try_file(main_path .. ".spec", js_extensions)
        if vim.fn.filereadable(p) == 1 then
            vim.fn.execute(":find " .. p)
        else
            vim.fn.execute(":find " .. try_file(main_path .. ".test", js_extensions))
        end
    elseif type == 'main' then
        vim.fn.execute(":find " .. try_file(main_path, js_extensions))
    elseif type == 'scss' then
        vim.fn.execute(":find " .. try_file(main_path, style_extensions))
    elseif type == 'html' then
        vim.fn.execute(":find " .. main_path .. ".html")
    elseif type == 'snapshot' then
        local splited = vim.split(main_path, "/")
        local last = table.remove(splited)
        table.insert(splited, "__snapshots__")
        table.insert(splited, last .. ".spec.ts.snap")
        local p = vim.fn.join(splited, "/")
        vim.fn.execute(":find " .. p)
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
--  go to snapshot file
vim.keymap.set('n', '<leader>an', ':JToFile snapshot<CR>')

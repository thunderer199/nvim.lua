return {
    {
        "mistweaverco/kulala.nvim",
        keys = {
            { "<leader>Rs", desc = "Send request" },
            { "<leader>Ra", desc = "Send all requests" }, -- ← This is what you wanted!
            { "<leader>Rb", desc = "Open scratchpad" },
        },
        ft = { "http", "rest" },
        opts = {
            global_keymaps = true, -- enables all default keymaps
            global_keymaps_prefix = "<leader>R",
            -- Add more options here if needed
        },
        init = function()
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "http",
                group = vim.api.nvim_create_augroup("KulalaEnvFallback", { clear = true }),
                callback = function()
                    local kulala = require("kulala")

                    local current_env = kulala.get_selected_env()
                    local env_file = vim.fn.findfile("http-client.env.json", ".;")
                    local env_data = nil
                    if env_file ~= "" then
                        local ok, data = pcall(vim.fn.readfile, env_file)
                        if ok and data then
                            env_data = vim.json.decode(table.concat(data, "\n"))
                        end
                    end
                    local env_list = env_data and vim.tbl_keys(env_data) or {}

                    local env_exists = false
                    for _, name in ipairs(env_list) do
                        if name == current_env then
                            env_exists = true
                            break
                        end
                    end

                    if not env_exists and #env_list > 0 then
                        local fallback = env_list[1]
                        kulala.set_selected_env(fallback)
                        vim.notify(
                            string.format("Kulala: '%s' not found → switched to '%s'", current_env, fallback),
                            vim.log.levels.WARN
                        )
                    end
                end,
            })
        end
    }
}

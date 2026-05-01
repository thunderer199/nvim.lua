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
            -- add more options here if needed
        },
        init = function()
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "http",
                group = vim.api.nvim_create_augroup("KulalaEnvFallback", { clear = true }),
                callback = function()
                    local kulala = require("kulala")
                    local env_parser = require("kulala.parser.env")

                    local current_env = kulala.get_selected_env()

                    -- Get all available environments from http-client.env.json
                    local available_envs = {}
                    local env_data = require("kulala.db").find_unique("http_client_env") or {}
                    for name, _ in pairs(env_data) do
                        table.insert(available_envs, name)
                    end
                    print('DEBUGPRINT[76]: rest.lua:26: available_envs=' .. vim.inspect(available_envs))

                    -- If current env doesn't exist in the file → fallback to first one
                    if not env_data[current_env] and #available_envs > 0 then
                        local fallback = available_envs[1] -- or "local" if you prefer
                        kulala.set_selected_env(fallback)
                        vim.notify(
                            string.format("Kulala: '%s' not found → auto-selected '%s'", current_env, fallback),
                            vim.log.levels.INFO
                        )
                    end
                end,
            })
        end
    }
}

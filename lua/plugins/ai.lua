return {
  {
    "milanglacier/minuet-ai.nvim",
    enabled = true,
    config = function()
      require("minuet").setup({
        provider = "openai_compatible",

        request_timeout = 3,
        throttle = 1500,
        debounce = 1000,

        provider_options = {
          openai_compatible = {
            api_key = function()
              return os.getenv("NVIM_OPENCODE_KEY")
            end,
            end_point = "https://opencode.ai/zen/go/v1/chat/completions",
            model = "deepseek-v4-flash",
            name = "Opencode",

            optional = {
              max_tokens = 64,
              top_p = 0.9,
              temperature = 0.2,
              thinking = { type = "disabled" },
            },
          },
        },

        virtualtext = {
          auto_trigger_ft = { "*" },
          manual_trigger_ft = { "*" },

          keymap = {
            accept = "<Tab>",
            accept_line = "<C-a>",
            accept_n_lines = "<C-z>",
            prev = "<A-[>",
            next = "<A-]>",
            dismiss = "<C-x>",
          },
        },
      })

      -- === Reliable ESC that always works ===
      vim.keymap.set("i", "<Esc>", function()
        -- Safely dismiss using Lua API
        pcall(function()
          require("minuet.virtualtext").action.dismiss()
        end)
        -- Then actually exit insert mode
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, true, true), "n", false)
      end, { noremap = true, silent = true, desc = "Dismiss Minuet + ESC" })
    end,
  },
}

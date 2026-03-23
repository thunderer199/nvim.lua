return {
  {
    "dimaportenko/project-cli-commands.nvim",
    dependencies = {
      "akinsho/toggleterm.nvim",
      "nvim-telescope/telescope.nvim",
    },
    keys = {
      { "<leader>p", "<cmd>Telescope project_cli_commands open<cr>", desc = "Project Commands" },
      { "<leader>'", "<cmd>Telescope project_cli_commands running<cr>", desc = "Running Commands" },
    },
    opts = function()
      local open_actions = require("project_cli_commands.open_actions")
      local run_actions = require("project_cli_commands.actions")

      return {
        running_telescope_mapping = {
          ["<C-c>"] = run_actions.exit_terminal,
          ["<C-f>"] = run_actions.open_float,
          ["<C-v>"] = run_actions.open_vertical,
          ["<C-h>"] = run_actions.open_horizontal,
        },
        open_telescope_mapping = {
          { mode = "i", key = "<CR>", action = open_actions.execute_script_vertical },
          { mode = "n", key = "<CR>", action = open_actions.execute_script_vertical },
          { mode = "i", key = "<C-h>", action = open_actions.execute_script },
          { mode = "n", key = "<C-h>", action = open_actions.execute_script },
          { mode = "i", key = "<C-i>", action = open_actions.execute_script_with_input },
          { mode = "n", key = "<C-i>", action = open_actions.execute_script_with_input },
          { mode = "i", key = "<C-c>", action = open_actions.copy_command_clipboard },
          { mode = "n", key = "<C-c>", action = open_actions.copy_command_clipboard },
          { mode = "i", key = "<C-f>", action = open_actions.execute_script_float },
          { mode = "n", key = "<C-f>", action = open_actions.execute_script_float },
          { mode = "i", key = "<C-v>", action = open_actions.execute_script_vertical },
          { mode = "n", key = "<C-v>", action = open_actions.execute_script_vertical },
        },
      }
    end,
  },
}

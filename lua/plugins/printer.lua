return {
    {
        "andrewferrier/debugprint.nvim",
        opts = {
            keymaps = {
                normal = {
                    plain_below = "gpp",
                    plain_above = "gpP",
                    variable_below = "gpv",
                    variable_above = "gpV",
                    variable_below_alwaysprompt = nil,
                    variable_above_alwaysprompt = nil,
                    toggle_comment_debug_prints = nil,
                    delete_debug_prints = nil,
                },
                visual = {
                    variable_below = "gpv",
                    variable_above = "gpV",
                },
            },
            commands = {
                toggle_comment_debug_prints = "ToggleCommentDebugPrints",
                delete_debug_prints = "DeleteDebugPrints",
            },
        },
    }
}

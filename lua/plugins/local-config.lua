return {
    "klen/nvim-config-local",
    config = true,
    opts = {
        config_files = { ".nvim.lua", ".nvimrc", ".exrc" },
        hashfile = vim.fn.stdpath("data") .. "/config-local",
        lookup_parents = true,
    }
}

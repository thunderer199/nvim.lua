vim.filetype.add({
  -- extension = {
  --   conf = "conf",
  --   env = "dotenv",
  --   tiltfile = "tiltfile",
  --   Tiltfile = "tiltfile",
  -- },
  filename = {
    [".env"] = "sh",
  },
  pattern = {
    ["%.env%.[%w_.-]+"] = "sh",
  },
})

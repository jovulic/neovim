---@type LazySpec
return {
  {
    "ravitemer/mcphub.nvim",
    opts = {
      server_url = "http://localhost:3000",
      config = vim.fs.abspath "~/.config/mcphub/mcp_settings.json",
    },
  },
}

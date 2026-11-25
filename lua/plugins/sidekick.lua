---@type LazySpec
return {
  "folke/sidekick.nvim",
  opts = {
    nes = {
      enabled = false,
    },
    cli = {
      watch = true,
      tools = {
        antigravity = { cmd = { "agy" } },
      },
    },
  },
}

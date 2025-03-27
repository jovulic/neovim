return {
  "rebelot/heirline.nvim",
  opts = function(_, opts)
    local status = require "astroui.status"

    opts.statusline = { -- statusline
      hl = { fg = "fg", bg = "bg" },
      status.component.mode(),
      status.component.git_branch(),
      status.component.file_info(),
      status.component.git_diff(),
      status.component.diagnostics(),
      status.component.fill(),
      status.component.cmd_info(),
      status.component.fill(),
      status.component.builder {
        {
          static = {
            processing = false,
          },
          update = {
            "User",
            pattern = "CodeCompanionRequest*",
            callback = function(self, args)
              if args.match == "CodeCompanionRequestStarted" then
                self.processing = true
              elseif args.match == "CodeCompanionRequestFinished" then
                self.processing = false
              end
              vim.cmd "redrawstatus"
            end,
          },
          {
            condition = function(self) return self.processing end,
            provider = "",
            hl = { fg = "yellow" },
          },
        },
      },
      status.component.lsp(),
      status.component.virtual_env(),
      status.component.treesitter(),
      status.component.nav(),
      status.component.mode { surround = { separator = "right" } },
    }
  end,
}

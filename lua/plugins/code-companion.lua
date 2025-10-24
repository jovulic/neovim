---@type LazySpec
return {
  {
    "olimorris/codecompanion.nvim",
    event = "User AstroFile",
    cmd = {
      "CodeCompanion",
      "CodeCompanionActions",
      "CodeCompanionChat",
      "CodeCompanionCmd",
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      ---@type CodeCompanion.AdapterArgs
      adapters = {
        acp = {
          gemini_cli = function()
            return require("codecompanion.adapters").extend("gemini_cli", {
              defaults = {
                ---@type string
                oauth_credentials_path = vim.fs.abspath "~/.gemini/oauth_creds.json",
              },
              handlers = {
                auth = function(self)
                  ---@type string|nil
                  local oauth_credentials_path = self.defaults.oauth_credentials_path
                  return (oauth_credentials_path and vim.fn.filereadable(oauth_credentials_path)) == 1
                end,
              },
            })
          end,
        },
        http = {
          gemini = function()
            return require("codecompanion.adapters").extend("gemini", {
              env = {
                api_key = "cmd:gopass show -no google.com/jovulic@gmail.com/ai-api-key",
              },
              schema = {
                model = {
                  default = "gemini-2.5-flash-preview-05-20",
                  choices = {
                    "gemini-2.5-pro-exp-03-25",
                    "gemini-2.5-flash-preview-05-20",
                  },
                },
              },
            })
          end,
          gpt_oss = function()
            return require("codecompanion.adapters").extend("ollama", {
              schema = {
                name = "gps_oss",
                formatted_name = "GPT OSS",
                model = {
                  default = "gpt-oss:20b",
                  choices = {
                    "gpt-oss:20b",
                  },
                },
              },
            })
          end,
          codestral = function()
            return require("codecompanion.adapters").extend("ollama", {
              schema = {
                name = "codestral",
                formatted_name = "Codestral",
                model = {
                  default = "codestral",
                  choices = {
                    "codestral",
                  },
                },
              },
            })
          end,
          gemma = function()
            return require("codecompanion.adapters").extend("ollama", {
              schema = {
                name = "gemma",
                formatted_name = "Gemma",
                model = {
                  default = "gemma3:12b",
                  choices = {
                    "gemma3",
                    "gemma3:12b",
                  },
                },
              },
            })
          end,
        },
      },
      strategies = {
        chat = { adapter = "gemini_cli" },
        inline = { adapter = "codestral" },
      },
    },
  },
  {
    "rebelot/heirline.nvim",
    opts = function(_, opts)
      opts.statusline = opts.statusline or {}
      local spinner_symbols = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
      local astroui = require "astroui.status.hl"
      table.insert(opts.statusline, {
        static = {
          n_requests = 0,
          spinner_index = 0,
          spinner_symbols = spinner_symbols,
          done_symbol = "✓",
        },
        init = function(self)
          if self._cc_autocmds then return end
          self._cc_autocmds = true
          vim.api.nvim_create_autocmd("User", {
            pattern = "CodeCompanionRequestStarted",
            callback = function()
              self.n_requests = self.n_requests + 1
              vim.cmd "redrawstatus"
            end,
          })
          vim.api.nvim_create_autocmd("User", {
            pattern = "CodeCompanionRequestFinished",
            callback = function()
              self.n_requests = math.max(0, self.n_requests - 1)
              vim.cmd "redrawstatus"
            end,
          })
        end,
        provider = function(self)
          if not package.loaded["codecompanion"] then return nil end
          local symbol
          if self.n_requests > 0 then
            self.spinner_index = (self.spinner_index % #self.spinner_symbols) + 1
            symbol = self.spinner_symbols[self.spinner_index]
          else
            symbol = self.done_symbol
            self.spinner_index = 0
          end
          return ("%d %s"):format(self.n_requests, symbol)
        end,
        hl = function() return astroui.filetype_color() end,
      })
    end,
  },
  { "AstroNvim/astroui", opts = { icons = { CodeCompanion = "󱙺" } } },
  {
    "AstroNvim/astrocore",
    opts = function(_, opts)
      if not opts.mappings then opts.mappings = {} end
      opts.mappings.n = opts.mappings.n or {}
      opts.mappings.v = opts.mappings.v or {}
      opts.mappings.n["<Leader>a"] = { desc = require("astroui").get_icon("CodeCompanion", 1, true) .. "CodeCompanion" }
      opts.mappings.v["<Leader>a"] = { desc = require("astroui").get_icon("CodeCompanion", 1, true) .. "CodeCompanion" }
      opts.mappings.n["<Leader>ac"] = { "<cmd>CodeCompanionChat Toggle<cr>", desc = "Toggle chat" }
      opts.mappings.v["<Leader>ac"] = { "<cmd>CodeCompanionChat Toggle<cr>", desc = "Toggle chat" }
      opts.mappings.n["<Leader>ap"] = { "<cmd>CodeCompanionActions<cr>", desc = "Open action palette" }
      opts.mappings.v["<Leader>ap"] = { "<cmd>CodeCompanionActions<cr>", desc = "Open action palette" }
      opts.mappings.n["<Leader>aq"] = { "<cmd>CodeCompanion<cr>", desc = "Open inline assistant" }
      opts.mappings.v["<Leader>aq"] = { "<cmd>CodeCompanion<cr>", desc = "Open inline assistant" }
      opts.mappings.v["<Leader>aa"] = { "<cmd>CodeCompanionChat Add<cr>", desc = "Add selection to chat" }
    end,
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    optional = true,
    opts = function(_, opts)
      if not opts.file_types then opts.file_types = { "markdown" } end
      opts.file_types = require("astrocore").list_insert_unique(opts.file_types, { "codecompanion" })
    end,
  },
}

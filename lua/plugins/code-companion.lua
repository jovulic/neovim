-- local function create_cleanfn_inline_output()
--   local log = require "codecompanion.utils.log"
--   local markdown_detected = false
--   local markdown_filetype_newline_deleted = false
--   local count = 0
--
--   return function(_, data, context)
--     if data and data ~= "" then
--       local ok, json = pcall(vim.json.decode, data, { luanil = { object = true } })
--       if not ok then
--         log:error("Error malformed json: %s", json)
--         return
--       end
--
--       local content = json.message.content
--
--       if context then
--         print("filetype: " .. context.filetype .. " content: " .. content)
--       else
--         print "no context"
--       end
--
--       if content == "```" and count < 16 then
--         -- If we find a triple-tick early on, we have found markdown and want to
--         -- set the markdown mode and remove it.
--         markdown_detected = true
--         content = ""
--       elseif markdown_detected and content == "```" then
--         -- If we have detected markdown and then find a later triple-tick we know
--         -- we have finished the markdown snippet and want to reset all state.
--         markdown_detected = false
--         markdown_filetype_newline_deleted = false
--         count = 0
--         content = ""
--       elseif markdown_detected and not markdown_filetype_newline_deleted and content == "\n" and count < 16 then
--         -- We want to stop dropping token once we have detected the markdown
--         -- filetype newline.
--         markdown_filetype_newline_deleted = true
--         content = ""
--       elseif markdown_detected and not markdown_filetype_newline_deleted and count < 16 then
--         -- We want to drop content if we have detected markdown but have not
--         -- detected the filetype newline.
--         content = ""
--       end
--
--       count = count + 1
--
--       return content
--     end
--   end
-- end
-- quen_coder = function()
--   local cleanfn = create_cleanfn_inline_output()
--   return require("codecompanion.adapters").extend("ollama", {
--     schema = {
--       name = "qwen2.5-coder",
--       formatted_name = "Quen 2.5 Coder",
--       model = {
--         default = "qwen2.5-coder:14b",
--       },
--     },
--     handlers = {
--       inline_output = function(_, data, context) return cleanfn(_, data, context) end,
--     },
--   })
-- end

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
      adapters = {
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
        deepseek_coder = function()
          return require("codecompanion.adapters").extend("ollama", {
            schema = {
              name = "deepseek-coder",
              formatted_name = "DeepSeek Coder",
              model = {
                default = "deepseek-coder-v2",
                choices = {
                  "deepseek-coder-v2",
                },
              },
            },
          })
        end,
        deepseek = function()
          local state = ""
          local state_count = 0
          return require("codecompanion.adapters").extend("ollama", {
            name = "deepseek-r1",
            formatted_name = "DeepSeek r1",
            schema = {
              model = {
                default = "deepseek-r1:14b",
                choices = {
                  ["deepseek-r1:14b"] = { opts = { can_reason = true } },
                },
              },
            },
            handlers = {
              chat_output = function(_, data)
                local output = {}

                if data and data ~= "" then
                  local ok, json = pcall(vim.json.decode, data, { luanil = { object = true } })
                  if not ok then return { status = "error" } end

                  local message = json.message
                  if message.content then
                    local content = message.content

                    output.role = message.role or nil

                    -- We want to also ignore the newlines that follow the state
                    -- transitions.
                    if state == "REASON" and state_count == 1 then content = "" end
                    if state == "RESPONSE" and state_count == 1 then content = "" end

                    -- Look for <think> tag and switch to state "REASON".
                    -- We also clear the content here to ignore the tag.
                    if content == "<think>" then
                      state = "REASON"
                      state_count = 0
                      content = ""
                    end

                    -- Look for </think> tag and switch to state "RESPONSE".
                    -- We also clear the content here to ignore the tag.
                    if content == "</think>" then
                      state = "RESPONSE"
                      state_count = 0
                      content = ""
                    end

                    -- Set the reasoning or content output properties accordingly.
                    if state == "REASON" then
                      output.reasoning = content
                    else
                      output.content = content
                    end
                  end

                  state_count = state_count + 1

                  return {
                    status = "success",
                    output = output,
                  }
                end
              end,
            },
          })
        end,
      },
      strategies = {
        chat = { adapter = "deepseek_coder" },
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

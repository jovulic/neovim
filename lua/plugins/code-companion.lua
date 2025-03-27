local function create_cleanfn_inline_output()
  local log = require "codecompanion.utils.log"
  local markdown_detected = false
  local markdown_filetype_newline_deleted = false
  local count = 0

  return function(_, data, context)
    if data and data ~= "" then
      local ok, json = pcall(vim.json.decode, data, { luanil = { object = true } })
      if not ok then
        log:error("Error malformed json: %s", json)
        return
      end

      local content = json.message.content

      if context then
        print("filetype: " .. context.filetype .. " content: " .. content)
      else
        print "no context"
      end

      if content == "```" and count < 16 then
        -- If we find a triple-tick early on, we have found markdown and want to
        -- set the markdown mode and remove it.
        markdown_detected = true
        content = ""
      elseif markdown_detected and content == "```" then
        -- If we have detected markdown and then find a later triple-tick we know
        -- we have finished the markdown snippet and want to reset all state.
        markdown_detected = false
        markdown_filetype_newline_deleted = false
        count = 0
        content = ""
      elseif markdown_detected and not markdown_filetype_newline_deleted and content == "\n" and count < 16 then
        -- We want to stop dropping token once we have detected the markdown
        -- filetype newline.
        markdown_filetype_newline_deleted = true
        content = ""
      elseif markdown_detected and not markdown_filetype_newline_deleted and count < 16 then
        -- We want to drop content if we have detected markdown but have not
        -- detected the filetype newline.
        content = ""
      end

      count = count + 1

      return content
    end
  end
end

---@type LazySpec
return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  opts = {
    adapters = {
      codestral = function()
        return require("codecompanion.adapters").extend("ollama", {
          schema = {
            name = "codestral",
            formatted_name = "Codestral",
            model = {
              default = "codestral",
            },
          },
        })
      end,
      command = function()
        return require("codecompanion.adapters").extend("ollama", {
          schema = {
            name = "command-r7b",
            formatted_name = "Command R7B",
            model = {
              default = "command-r7b",
            },
          },
        })
      end,
      quen_coder = function()
        local cleanfn = create_cleanfn_inline_output()
        return require("codecompanion.adapters").extend("ollama", {
          schema = {
            name = "qwen2.5-coder",
            formatted_name = "Quen 2.5 Coder",
            model = {
              default = "qwen2.5-coder:14b",
            },
          },
          handlers = {
            inline_output = function(_, data, context) return cleanfn(_, data, context) end,
          },
        })
      end,
      deepseek_coder = function()
        local cleanfn = create_cleanfn_inline_output()
        return require("codecompanion.adapters").extend("ollama", {
          schema = {
            name = "deepseek-coder",
            formatted_name = "Deepseek Coder",
            model = {
              default = "deepseek-coder-v2:16b",
            },
          },
          handlers = {
            inline_output = function(_, data, context) return cleanfn(_, data, context) end,
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
              default = "deepseek-r1:14b-qwen-distill-q4_K_M",
              choices = {
                ["deepseek-r1:14b-qwen-distill-q4_K_M"] = { opts = { can_reason = true } },
                ["deepseek-r1:7b-qwen-distill-q8_0"] = { opts = { can_reason = true } },
                ["deepseek-r1:7b-llama-distill-q4_K_M"] = { opts = { can_reason = true } },
                ["deepseek-r1:8b-llama-distill-q8_0"] = { opts = { can_reason = true } },
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
      chat = { adapter = "deepseek" },
      inline = { adapter = "codestral" },
      cmd = { adapter = "command" },
    },
    specs = {
      { "AstroNvim/astroui", opts = { icons = { CodeCompanion = "" } } },
    },
  },
}

---@type LazySpec
return {
  {
    "milanglacier/minuet-ai.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {
      -- virtualtext = {
      --   auto_trigger_ft = {},
      --   keymap = {
      --     next = "<C-s>",
      --     accept = "<C-a>",
      --   },
      -- },
      provider = "openai_fim_compatible",
      n_completions = 1, -- recommend for local model for resource saving
      -- I recommend beginning with a small context window size and incrementally
      -- expanding it, depending on your local computing power. A context window
      -- of 512, serves as an good starting point to estimate your computing
      -- power. Once you have a reliable estimate of your local computing power,
      -- you should adjust the context window to a larger value.
      context_window = 512,
      context_ratio = 0.75,
      request_timeout = 10,
      notify = "warn",
      provider_options = {
        openai_fim_compatible = {
          api_key = "TERM",
          name = "Ollama",
          end_point = "http://localhost:11434/v1/completions",
          model = "codestral",
          optional = {
            max_tokens = 56,
            top_p = 0.9,
          },
        },
      },
    },
  },
  {
    "Saghen/blink.cmp",
    optional = true,
    opts = function(plugin, opts)
      -- Append the minuet source to the existing blink default source list.
      -- table.insert(opts.sources.default, "minuet")

      -- Merge the rest of the configuration as usual.
      return require("astrocore").extend_tbl(opts, {
        keymap = {
          ["<C-a>"] = {
            function(cmp) cmp.show { providers = { "minuet" } } end,
          },
        },
        sources = {
          providers = {
            minuet = {
              name = "minuet",
              module = "minuet.blink",
              score_offset = 100,
              timeout_ms = 10000,
            },
          },
        },
      })
    end,
  },
}

---@type LazySpec
return {
  "milanglacier/minuet-ai.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  opts = {
    virtualtext = {
      auto_trigger_ft = {},
      keymap = {
        next = "<C-s>",
        accept = "<C-a>",
      },
    },
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
          max_tokens = 256,
          top_p = 0.9,
        },
      },
    },
  },
}

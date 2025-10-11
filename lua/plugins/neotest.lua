return {
  {
    "nvim-neotest/neotest",
    opts = function(_, opts)
      -- This function receives the default AstroCommunity options for neotest
      -- We will modify them to remove the "-race" flag for the Go adapter.

      -- 1. Create a new Go adapter configured WITHOUT the -race flag
      local golang_adapter_without_race = require "neotest-golang" {
        go_test_args = { "-v", "-count=1" },
      }

      -- 2. Create a new, clean list of adapters
      local clean_adapters = {}
      for _, adapter in ipairs(opts.adapters) do
        -- Add all adapters EXCEPT the original Go one
        if adapter.name ~= "neotest-golang" then table.insert(clean_adapters, adapter) end
      end

      -- 3. Add our newly configured adapter to the clean list
      table.insert(clean_adapters, golang_adapter_without_race)

      -- 4. Replace the old adapter list with our corrected one
      opts.adapters = clean_adapters
    end,
  },
}

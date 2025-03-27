-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    -- Configure core features of AstroNvim
    features = {
      large_buf = { size = 1024 * 256, lines = 10000 }, -- set global limits for large files for disabling features like treesitter
      autopairs = true, -- enable autopairs at start
      cmp = true, -- enable completion at start
      diagnostics = { virtual_text = true, virtual_lines = false }, -- diagnostic settings on startup
      highlighturl = true, -- highlight URLs at start
      notifications = true, -- enable notifications at start
    },
    -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
    diagnostics = {
      virtual_text = true,
      underline = true,
    },
    -- vim options can be configured here
    options = {
      opt = { -- vim.opt.<key>
        relativenumber = true, -- sets vim.opt.relativenumber
        number = true, -- sets vim.opt.number
        spell = false, -- sets vim.opt.spell
        signcolumn = "yes", -- sets vim.opt.signcolumn to yes
        wrap = false, -- sets vim.opt.wrap
        guifont = { "NotoMono Nerd Font", ":h11" }, -- search with :set guifont=*
        listchars = { space = "·", nbsp = "c", precedes = "«", extends = "»", eol = "↲", tab = "▸-" },
        scrolloff = 999, -- keep cursor centered
      },
      g = { -- vim.g.<key>
        -- configure global vim variables (vim.g)
        -- NOTE: `mapleader` and `maplocalleader` must be set in the AstroNvim opts or before `lazy.setup`
        -- This can be found in the `lua/lazy_setup.lua` file
      },
    },
    -- Mappings can be configured through AstroCore as well.
    -- NOTE: keycodes follow the casing in the vimdocs. For example, `<Leader>` must be capitalized
    mappings = {
      -- first key is the mode
      n = {
        -- second key is the lefthand side of the map

        -- navigate buffer tabs
        -- ["]b"] = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" },
        -- ["[b"] = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" },
        -- navigate buffer tabs with `H` and `L`
        L = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" },
        H = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" },

        -- mappings seen under group name "Buffer"
        ["<Leader>b"] = { desc = " Buffers" },
        ["<Leader>bd"] = {
          function()
            require("astroui.status.heirline").buffer_picker(
              function(bufnr) require("astrocore.buffer").close(bufnr) end
            )
          end,
          desc = "Close buffer from tabline",
        },

        -- tables with just a `desc` key will be registered with which-key if it's installed
        -- this is useful for naming menus
        -- ["<Leader>b"] = { desc = "Buffers" },

        -- setting a mapping to false will disable it
        -- ["<C-S>"] = false,
        
        ["<Leader>a"] = { name = " Chat" },
        ["<Leader>aa"] = { ":CodeCompanionActions<CR>", desc = "Actions" },
        ["<Leader>ac"] = { ":CodeCompanionChat<CR>", desc = "Chat" },
        ["<Leader>ad"] = { ":CodeCompanion<CR>", desc = "Inline" },
        ["<Leader>af"] = { ":CodeCompanionCmd<CR>", desc = "Command" },

        ["<leader>n"] = { name = "󰙨 Tests" },
        ["<leader>nr"] = {
          function() require("neotest").run.run() end,
          desc = "Run nearest test",
        },
        ["<leader>nf"] = {
          function() require("neotest").run.run(vim.fn.expand "%") end,
          desc = "Run all tests in file",
        },
        ["<leader>ns"] = {
          function() require("neotest").run.stop() end,
          desc = "Stop nearest test",
        },
        ["<leader>na"] = {
          function() require("neotest").run.attach() end,
          desc = "Attach to nearest test",
        },
        ["<leader>no"] = { ":lua require('neotest').output.open({ enter = true })<CR>", desc = "Show test output" },
        ["<leader>nO"] = { ":lua require('neotest').summary.toggle()<CR>", desc = "Show test summary" },
        ["<leader>ng"] = { ":GoTestAdd<CR>", desc = "Generate tests for the current selection" },

        ["<leader>xo"] = { ":copen<CR>", desc = "Open the quickfix window" },
        ["<leader>xc"] = { ":cclose<CR>", desc = "Close the quickfix window" },
        ["<leader>xl"] = { ":cexpr<CR>", desc = "Clear (replace) the quickfix window" },
      },
      v = {
        ["<Leader>a"] = { name = " Chat" },
        ["<Leader>aa"] = { ":CodeCompanionActions<CR>", desc = "Actions" },
        ["<Leader>ac"] = { ":CodeCompanionChat<CR>", desc = "Chat" },
        ["<Leader>ad"] = { ":CodeCompanion<CR>", desc = "Inline" },
        ["<Leader>af"] = { ":CodeCompanionCmd<CR>", desc = "Command" },
      },
      t = {
        -- setting a mapping to false will disable it
        -- ["<esc>"] = false,
        ["<esc>"] = { "<C-\\><C-n>", desc = "Switch to normal mode" },
      },
      i = {
        ["<C-h>"] = { "<C-W>", desc = "Delete word with backspace" },
        ["<C-H>"] = { "<C-W>", desc = "Delete word with backspace" },
        ["<C-BS>"] = { "<C-W>", desc = "Delete word with backspace" },
      },
    },
  },
}

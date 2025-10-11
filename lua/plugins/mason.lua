-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- Customize Mason

---@type LazySpec
return {
  {
    "williamboman/mason.nvim",
    opts = {
      -- Mason builds the binaries to use and prepends the path to
      -- include its bin directory. However, some binaries will not
      -- work without being patched (for example, lua) and so we
      -- actually append and install the related packages where we
      -- can via nix, falling back on mason only when not present.
      PATH = "append",
    },
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    enabled = false,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    config = function(plugin, opts)
      -- print(vim.inspect(opts.ensure_installed))
      opts.ensure_installed = {
        -- astrovim pack=docker
        "docker_compose_language_service",
        "dockerls",
        "jsonls",
        "yamlls",
        "buf_ls",
        -- "volar",
      }
      require("mason-lspconfig").setup(opts)
    end,
  },
  {
    "jay-babu/mason-null-ls.nvim",
    config = function(plugin, opts)
      -- print(vim.inspect(opts.ensure_installed))
      opts.ensure_installed = {
        "stylua",
        "selene",
        "eslint",
        "prettierd",
        "black",
        "isort",
      }
      require("mason-null-ls").setup(opts)
    end,
  },
  -- use mason-tool-installer for automatically installing Mason packages
  -- {
  --   "WhoIsSethDaniel/mason-tool-installer.nvim",
  --   -- overrides `require("mason-tool-installer").setup(...)`
  --   enabled = false,
  --   opts = {
  --     -- Make sure to use the names found in `:Mason`
  --     ensure_installed = {
  --       -- install language servers
  --       "lua-language-server",
  --
  --       -- install formatters
  --       "stylua",
  --
  --       -- install debuggers
  --       "debugpy",
  --
  --       -- install any other package
  --       "tree-sitter-cli",
  --     },
  --   },
  -- },
}

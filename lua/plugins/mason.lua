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
  -- use mason-tool-installer for automatically installing Mason packages
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    -- overrides `require("mason-tool-installer").setup(...)`
    enabled = false,
    opts = {
      -- Make sure to use the names found in `:Mason`
      ensure_installed = {
        -- install language servers
        "lua-language-server",

        -- install formatters
        "stylua",

        -- install debuggers
        "debugpy",

        -- install any other package
        "tree-sitter-cli",
      },
    },
  },
}

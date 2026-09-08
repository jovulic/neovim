-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- AstroLSP allows you to customize the features in AstroNvim's LSP configuration engine
-- Configuration documentation can be found with `:h astrolsp`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  "AstroNvim/astrolsp",
  ---@type AstroLSPOpts
  opts = function(_, opts)
    local local_opts = {
      -- Configuration table of features provided by AstroLSP
      features = {
        codelens = true, -- enable/disable codelens refresh on start
        inlay_hints = false, -- enable/disable inlay hints on start
        semantic_tokens = true, -- enable/disable semantic token highlighting
      },
      -- customize lsp formatting options
      formatting = {
        -- control auto formatting on save
        format_on_save = {
          enabled = true, -- enable or disable format on save globally
          allow_filetypes = { -- enable format on save for specified filetypes only
            -- "go",
          },
          ignore_filetypes = { -- disable format on save for specified filetypes
            -- "python",
          },
        },
        disabled = { -- disable formatting capabilities for the listed language servers
          -- disable lua_ls formatting capability if you want to use StyLua to format your lua code
          -- "lua_ls",
          -- "volar",
          "vue_ls",
        },
        timeout_ms = 1000, -- default format timeout
        -- filter = function(client) -- fully override the default formatting function
        --   return true
        -- end
      },
      -- enable servers that you already have installed without mason
      servers = {
        -- "pyright"
        "lua_ls",
        "bashls",
        "taplo",
        "marksman",
        "sqls",
        "buf_ls",
        "nixd",
        "gopls",
        "vtsls",
        "vue_ls",
        "basedpyright",
        "clangd",
      },
      -- customize language server configuration options passed to `lspconfig`
      ---@diagnostic disable: missing-fields
      config = {
        -- clangd = { capabilities = { offsetEncoding = "utf-8" } },
        vtsls = {
          settings = {
            vtsls = {
              autoUseWorkspaceTsdk = true,
              tsserver = {
                globalPlugins = {
                  {
                    name = "typescript-svelte-plugin",
                    -- Point directly to the stable global Nix system path
                    location = "/run/current-system/sw/lib/node_modules/typescript-svelte-plugin",
                    enableForWorkspaceTypeScriptVersions = true,
                  },
                },
              },
            },
          },
        },
        clangd = {
          filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "hpp" },
        },
        gopls = {
          settings = {
            gopls = {
              analyses = {
                shadow = false,
              },
            },
          },
        },
        nixd = {
          settings = {
            nixd = {
              formatting = {
                command = { "nixfmt" },
              },
              nixpkgs = {
                expr = 'import (builtins.getFlake "/home/me/forge").inputs.nixpkgs { }',
              },
              options = {
                nixos = {
                  expr = '(builtins.getFlake "/home/me/forge").nixosConfigurations.licious.options',
                },
                ["home-manager"] = {
                  expr = '(builtins.getFlake "/home/me/forge").homeConfigurations."me@licious".options',
                },
              },
            },
          },
        },
      },
      -- customize how language servers are attached
      handlers = {
        -- a function without a key is simply the default handler, functions take two parameters, the server name and the configured options table for that server
        -- function(server, opts) require("lspconfig")[server].setup(opts) end

        -- the key is the server that is being setup with `lspconfig`
        -- rust_analyzer = false, -- setting a handler to false will disable the set up of that language server
        -- pyright = function(_, opts) require("lspconfig").pyright.setup(opts) end -- or a custom handler function can be passed
      },
      -- Configure buffer local auto commands to add when attaching a language server
      autocmds = {
        -- Disable eslint format on save.
        eslint_fix_on_save = false,
        -- first key is the `augroup` to add the auto commands to (:h augroup)
        lsp_codelens_refresh = {
          -- Optional condition to create/delete auto command group
          -- can either be a string of a client capability or a function of `fun(client, bufnr): boolean`
          -- condition will be resolved for each client on each execution and if it ever fails for all clients,
          -- the auto commands will be deleted for that buffer
          cond = "textDocument/codeLens",
          -- cond = function(client, bufnr) return client.name == "lua_ls" end,
          -- list of auto commands to set
          {
            -- events to trigger
            event = { "InsertLeave", "BufEnter" },
            -- the rest of the autocmd options (:h nvim_create_autocmd)
            desc = "Refresh codelens (buffer)",
            callback = function(args)
              if require("astrolsp").config.features.codelens then vim.lsp.codelens.refresh { bufnr = args.buf } end
            end,
          },
        },
      },
      -- mappings to be set up on attaching of a language server
      mappings = {
        n = {
          -- a `cond` key can provided as the string of a server capability to be required to attach, or a function with `client` and `bufnr` parameters from the `on_attach` that returns a boolean
          gD = {
            function() vim.lsp.buf.declaration() end,
            desc = "Declaration of current symbol",
            cond = "textDocument/declaration",
          },
          ["<Leader>uY"] = {
            function() require("astrolsp.toggles").buffer_semantic_tokens() end,
            desc = "Toggle LSP semantic highlight (buffer)",
            cond = function(client)
              return client.supports_method "textDocument/semanticTokens/full" and vim.lsp.semantic_tokens ~= nil
            end,
          },
        },
      },
      -- A custom `on_attach` function to be run after the default `on_attach` function
      -- takes two parameters `client` and `bufnr`  (`:h lspconfig-setup`)
      on_attach = function(client, bufnr)
        -- this would disable semanticTokensProvider for all clients
        -- client.server_capabilities.semanticTokensProvider = nil
      end,
    }

    -- 1. Extract any existing servers and disabled formatters from preceding specs (e.g. AstroCommunity packs)
    local community_servers = opts.servers or {}
    local community_disabled_formatters = (opts.formatting and opts.formatting.disabled) or {}

    -- 2. Deep merge local_opts into opts
    opts = vim.tbl_deep_extend("force", opts, local_opts)

    -- 3. Merge community servers into opts.servers (deduplicated)
    opts.servers = opts.servers or {}
    local seen_servers = {}
    for _, s in ipairs(local_opts.servers or {}) do
      if not seen_servers[s] then
        seen_servers[s] = true
        table.insert(opts.servers, s)
      end
    end
    for _, s in ipairs(community_servers) do
      if not seen_servers[s] then
        seen_servers[s] = true
        table.insert(opts.servers, s)
      end
    end

    -- 4. Merge community disabled formatters into opts.formatting.disabled (deduplicated)
    opts.formatting = opts.formatting or {}
    opts.formatting.disabled = opts.formatting.disabled or {}
    local seen_disabled = {}
    for _, d in ipairs(local_opts.formatting and local_opts.formatting.disabled or {}) do
      if not seen_disabled[d] then
        seen_disabled[d] = true
        table.insert(opts.formatting.disabled, d)
      end
    end
    for _, d in ipairs(community_disabled_formatters) do
      if not seen_disabled[d] then
        seen_disabled[d] = true
        table.insert(opts.formatting.disabled, d)
      end
    end

    -- 5. Dynamically auto-detect ANY installed LSP server on the system PATH
    -- and enable it! This is extremely powerful for NixOS, as it automatically
    -- configures any language server package you install via Nix.
    local status_ok, lspconfig_configs = pcall(require, "lspconfig.configs")
    if status_ok then
      -- Get all supported servers registered in lspconfig
      for server_name, config_spec in pairs(lspconfig_configs) do
        if not seen_servers[server_name] then
          local default_config = config_spec.document_config and config_spec.document_config.default_config
          local cmd = default_config and default_config.cmd
          if type(cmd) == "table" and #cmd > 0 then
            local binary = cmd[1]
            if vim.fn.executable(binary) == 1 then
              seen_servers[server_name] = true
              table.insert(opts.servers, server_name)
            end
          end
        end
      end
    end

    return opts
  end,
}

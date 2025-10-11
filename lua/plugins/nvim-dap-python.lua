-- We disable this plugin as it requires lua (5.1) and luarocks, which is
-- annoying to configure correctly, and not worth the time right now as I do
-- not use a python debugger currently anyway.
return {
  "mfussenegger/nvim-dap-python",
  enabled = false,
}

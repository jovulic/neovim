-- if true then return end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- This will run last in the setup process and is a good place to configure
-- things like custom filetypes. This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

-- Set up custom filetypes
vim.filetype.add {
  extension = {
    foo = "fooscript",
    zed = "authzed",
  },
}

-- Define a user command to view all past notifications in a new buffer
vim.api.nvim_create_user_command("Notifications", function()
  if _G.Snacks and _G.Snacks.notifier then
    _G.Snacks.notifier.show_history()
  else
    vim.cmd "messages"
  end
end, {})

-- Custom initialization file for personal configurations

-- Auto-trigger telescope on startup
vim.api.nvim_create_autocmd("VimEnter", {
  desc = "Open telescope when nvim starts with no arguments or with a directory",
  callback = function()
    -- Check if no arguments were passed or if a directory was opened
    local args = vim.fn.argv()
    local should_open_telescope = false
    
    if #args == 0 then
      -- No arguments passed
      should_open_telescope = true
    elseif #args == 1 then
      -- Check if the single argument is a directory
      local path = args[1]
      if vim.fn.isdirectory(path) == 1 then
        should_open_telescope = true
      end
    end
    
    if should_open_telescope then
      -- Defer the telescope command to ensure nvim is fully loaded
      vim.defer_fn(function()
        -- Use telescope find_files command
        vim.cmd("Telescope find_files")
      end, 100) -- 100ms delay to ensure everything is loaded
    end
  end,
})
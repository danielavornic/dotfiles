return {
  window = {
    width = function()
      return math.min(160, vim.o.columns * 0.7)
    end,
  },
  plugins = {
    options = {
      enabled = true,
      ruler = false,   -- disables the ruler text in the cmd line area
      showcmd = false, -- disables the command in the last line of the screen
      -- you may turn on/off statusline in zen mode by setting 'laststatus'
      -- statusline will be shown only if 'laststatus' == 3
      laststatus = 0,          -- turn off the statusline in zen mode
    },
    tmux = { enabled = true }, -- disables the tmux statusline
    gitsigns = { enable = true },
    -- this will change the font size on kitty when in zen mode
    -- to make this work, you need to set the following kitty options:
    -- - allow_remote_control socket-only
    -- - listen_on unix:/tmp/kitty
    kitty = {
      enabled = true,
      font = "+4", -- font size increment
    },
  },
}
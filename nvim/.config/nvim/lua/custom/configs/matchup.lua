return function()
  -- modify your configuration vars here
  vim.g.matchup_treesitter_stopline = 500

  -- or call the setup function provided as a helper. It defines the
  -- configuration vars for you
  require("match-up").setup {
    treesitter = {
      stopline = 500,
    },
  }
end
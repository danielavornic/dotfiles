local options = {
  -- Enable LaTeX math rendering
  latex = {
    enable = true,
  },

  -- Configure math rendering
  markdown = {
    headings = {
      enable = true,
      shift_width = 0,
    },
    code_blocks = {
      enable = true,
    },
    list_items = {
      enable = true,
    },
    links = {
      enable = true,
    },
    tables = {
      enable = true,
    },
  },

  -- Keep experimental settings
  experimental = {
    check_rtp = false,
  },
}

return options
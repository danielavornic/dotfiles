---@type ChadrcConfig
local M = {}
M.ui = {
  theme = "everforest",
  tabufline = { enabled = false },
  hl_override = {
    -- General syntax italics
    Comment = { italic = true },
    Keyword = { italic = true },
    Type = { italic = true },
    StorageClass = { italic = true },
    Function = { italic = true },
    Conditional = { italic = true },
    Repeat = { italic = true },

    -- Markdown specific italics
    ["@text.emphasis"] = { italic = true },            -- *italic text*
    ["@text.strong"] = { bold = true, italic = true }, -- **bold italic**
    markdownItalic = { italic = true },
    markdownBold = { bold = true },
    markdownBoldItalic = { bold = true, italic = true },

    -- Additional markdown elements
    ["@text.title"] = { bold = true, italic = true }, -- Headers
    ["@text.quote"] = { italic = true },              -- Block quotes
  },
}
M.plugins = "custom.plugins"

return M

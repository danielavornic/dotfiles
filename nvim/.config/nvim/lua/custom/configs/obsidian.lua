-- Vaults differ per machine. Each vault lists the paths it can live at; the first
-- one that exists locally is used, and vaults with none are skipped, because
-- obsidian.nvim errors on a workspace path that isn't on disk.
-- A path can be { path, overrides = {...} } for settings that only apply at that location.
local vaults = {
  {
    name = "personal",
    paths = {
      {
        "~/Library/Mobile Documents/iCloud~md~obsidian/Documents/DanaGardens",
        overrides = {
          daily_notes = {
            folder = "10-PERSONAL/daily",
            date_format = "%d-%m-%Y",
            alias_format = "%-d %B,  %Y",
            default_tags = { "dpn" },
            -- Relative to templates.folder.
            template = "DAILY-Template.md",
          },
        },
      },
      "~/obsidian",
    },
  },
  {
    name = "railpen",
    paths = { "~/lowcode-accelerator" },
    overrides = {
      attachments = { img_folder = "Obsidian attachments" },
      templates = { folder = vim.NIL },
    },
  },
}

local workspaces = {}
for _, vault in ipairs(vaults) do
  for _, entry in ipairs(vault.paths) do
    local path = type(entry) == "table" and entry[1] or entry
    if vim.fn.isdirectory(vim.fn.expand(path)) == 1 then
      local overrides = vim.tbl_deep_extend("force", vault.overrides or {}, type(entry) == "table" and entry.overrides or {})
      table.insert(workspaces, { name = vault.name, path = path, overrides = overrides })
      break
    end
  end
end

return {
  "epwalsh/obsidian.nvim",
  version = "*", -- recommended, use latest release instead of latest commit
  lazy = true,
  ft = "markdown",
  -- Skip the plugin on machines without any vault.
  cond = #workspaces > 0,
  dependencies = {
    -- Required.
    "nvim-lua/plenary.nvim",
  },
  opts = {
    ui = { enable = false },
    workspaces = workspaces,

    -- Defaults below match the personal vault layout. Vaults that differ override them above.
    attachments = {
      -- The default folder to place images in via `:ObsidianPasteImg`, relative to the vault root.
      img_folder = "_SYSTEM/_attachments",

      -- Prefix image names with timestamp.
      ---@return string
      img_name_func = function()
        return string.format("%s-", os.time())
      end,

      ---@param client obsidian.Client
      ---@param path obsidian.Path the absolute path to the image file
      ---@return string
      img_text_func = function(client, path)
        path = client:vault_relative_path(path) or path
        return string.format("![%s](%s)", path.name, path)
      end,
    },
    notes_subdir = "00-INBOX",
    new_notes_location = "00-INBOX",

    disable_frontmatter = true,
    templates = {
      folder = "_SYSTEM/_templates",
      date_format = "%d-%m-%Y",
      time_format = "%H:%M:%S",
    },
    ---@param url string
    follow_url_func = function(url)
      vim.ui.open(url) -- need Neovim 0.10.0+
    end,

    ---@param img string
    follow_img_func = function(img)
      vim.ui.open(img)
    end,
  },
}

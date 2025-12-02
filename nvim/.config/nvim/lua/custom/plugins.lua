local plugins = {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function()
      local opts = require "plugins.configs.treesitter"
      opts.ensure_installed = {
        "lua",
        "javascript",
        "typescript",
        "tsx",
        "svelte",
      }
      return opts
    end,
  },
  {
    "nvim-neotest/neotest",
    lazy = false,
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      "marilari88/neotest-vitest",
      "nvim-neotest/neotest-jest",
    },
    keys = {
      { "<leader>tr", "<cmd>Neotest run<cr>",      desc = "run nearest test" },
      { "<leader>tl", "<cmd>Neotest run last<cr>", desc = "run last test" },
      { "<leader>tf", "<cmd>Neotest run file<cr>", desc = "run test file" },
    },
    config = require "custom.configs.neotest",
  },
  {
    "maarutan/macro-notify.nvim",
    config = function()
      require("macro-notify").setup {
        message_start = "Macro started on register: ",
        message_end = "Macro ended on register: ",
        icon_start = "📼",
        icon_end = "✅",
      }
    end,
  },
  {
    "hedyhli/outline.nvim",
    lazy = false,
    config = function()
      -- Example mapping to toggle outline
      vim.keymap.set("n", "<leader>o", "<cmd>Outline<CR>", { desc = "Toggle Outline" })

      require("outline").setup {
        -- Your setup opts here (leave empty to use defaults)
        --
        symbol_folding = {
          -- Depth past which nodes will be folded by default. Set to false to unfold all on open.
          autofold_depth = 3,
          -- When to auto unfold nodes
          auto_unfold = {
            -- Auto unfold currently hovered symbol
            hovered = true,
            -- Auto fold when the root level only has this many nodes.
            -- Set true for 1 node, false for 0.
            only = true,
          },
          markers = { "", "" },
        },
      }
    end,
  },
  {
    "mgierada/lazydocker.nvim",
    dependencies = { "akinsho/toggleterm.nvim" },
    config = require "custom.configs.lazydocker",
    event = "BufRead",
    keys = {
      {
        "<leader>ld",
        function()
          require("lazydocker").open()
        end,
        desc = "Open Lazydocker floating window",
      },
    },
  },
  {
    "sylvanfranklin/omni-preview.nvim",
    dependencies = {
      { "chomosuke/typst-preview.nvim", lazy = true },
      { "hat0uma/csvview.nvim",         lazy = true },
    },
    keys = {
      { "<leader>po", "<cmd>OmniPreview start<CR>", desc = "OmniPreview Start" },
      { "<leader>pc", "<cmd>OmniPreview stop<CR>",  desc = "OmniPreview Stop" },
    },
    opts = {},
  },
  require "custom.configs.obsidian",
  {
    "OXY2DEV/markview.nvim",
    lazy = false,
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      experimental = {
        check_rtp = false,
      },
    },
  },
  {
    "folke/zen-mode.nvim",
    lazy = false,
    opts = require "custom.configs.zen-mode",
  },
  {
    "andymass/vim-matchup",
    init = require "custom.configs.matchup",
  },
  {
    "folke/ts-comments.nvim",
    opts = {},
    event = "VeryLazy",
    enabled = vim.fn.has "nvim-0.10.0" == 1,
  },
  {
    "razak17/tailwind-fold.nvim",
    opts = {
      symbol = "󱏿",
    },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    ft = { "html", "astro", "typescriptreact" },
  },
  {

    "kylechui/nvim-surround",
    version = "^3.0.0", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup {
        -- Configuration here, or leave empty to use defaults
      }
    end,
  },
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    lazy = false,
    dependencies = { "nvim-lua/plenary.nvim" },
    config = require "custom.configs.harpoon",
  },
  {
    "chentoast/marks.nvim",
    event = "VeryLazy",
    opts = {},
  },
  {
    "kdheepak/lazygit.nvim",
    cmd = {
      "LazyGit",
      "LazyGitConfig",
      "LazyGitCurrentFile",
      "LazyGitFilter",
      "LazyGitFilterCurrentFile",
    },
    -- optional for floating window border decoration
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    -- setting the keybinding for LazyGit with 'keys' is recommended in
    -- order to load the plugin when the command is run for the first time
    keys = {
      { "<leader>lg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
    },
    config = function()
      require("lazygit").setup {
        editor_action_callback = require "custom.configs.lazygit",
      }
    end,
  },
  {
    "MunifTanjim/nui.nvim",
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      -- add any options here
    },
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      "MunifTanjim/nui.nvim",
      -- OPTIONAL:
      --   `nvim-notify` is only needed, if you want to use the notification view.
      --   If not available, we use `mini` as the fallback
      "rcarriga/nvim-notify",
    },
  },

  {
    "zbirenbaum/copilot-cmp",
    lazy = false,
    dependencies = { "zbirenbaum/copilot.lua" },
    config = function()
      require("copilot_cmp").setup()
    end,
  },
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup(require "custom.configs.copilot")
    end,
  },
  {
    "folke/trouble.nvim",
    opts = {}, -- for default options, refer to the configuration section for custom setup.
    cmd = "Trouble",
    keys = {
      {
        "<leader>xx",
        "<cmd>Trouble diagnostics toggle<cr>",
        desc = "Diagnostics (Trouble)",
      },
      {
        "<leader>xX",
        "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
        desc = "Buffer Diagnostics (Trouble)",
      },
      {
        "<leader>cs",
        "<cmd>Trouble symbols toggle focus=false<cr>",
        desc = "Symbols (Trouble)",
      },
      {
        "<leader>cl",
        "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
        desc = "LSP Definitions / references / ... (Trouble)",
      },
      {
        "<leader>xL",
        "<cmd>Trouble loclist toggle<cr>",
        desc = "Location List (Trouble)",
      },
      {
        "<leader>xQ",
        "<cmd>Trouble qflist toggle<cr>",
        desc = "Quickfix List (Trouble)",
      },
    },
  },
  {
    "mikavilpas/yazi.nvim",
    event = "VeryLazy",
    dependencies = {
      { "nvim-lua/plenary.nvim", lazy = true },
    },
    keys = {
      {
        "<leader>-",
        mode = { "n", "v" },
        "<cmd>Yazi<cr>",
        desc = "Open yazi at the current file",
      },
      {
        -- Open in the current working directory
        "<leader>cw",
        "<cmd>Yazi cwd<cr>",
        desc = "Open the file manager in nvim's working directory",
      },
      {
        "<c-up>",
        "<cmd>Yazi toggle<cr>",
        desc = "Resume the last yazi session",
      },
    },
    opts = require("custom.configs.yazi").opts,
    init = require("custom.configs.yazi").init,
  },
  {
    "szymonwilczek/vim-be-better",
    lazy = false,
    config = function()
      -- Optional: Enable logging for debugging
      vim.g.vim_be_better_log_file = 1
    end,
  },
  {
    "OlegGulevskyy/better-ts-errors.nvim",
    dependencies = { "MunifTanjim/nui.nvim" },
    config = {
      keymaps = {
        toggle = "<leader>dd",           -- default '<leader>dd'
        go_to_definition = "<leader>dx", -- default '<leader>dx'
      },
    },
  },
  {
    "folke/todo-comments.nvim",
    lazy = false,
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      keywords = {
        FIX = {
          icon = " ", -- icon used for the sign, and in search results
          color = "error", -- can be a hex color, or a named color (see below)
          alt = { "FIXME", "BUG", "FIXIT", "ISSUE" }, -- a set of other keywords that all map to this FIX keywords
          -- signs = false, -- configure signs for some keywords individually
        },
        TODO = { icon = " ", color = "info" },
        HACK = { icon = " ", color = "warning" },
        WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
        PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
        NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
        TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
      },
    },
  },
  {
    "abecodes/tabout.nvim",
    event = "InsertCharPre",
    lazy = false,
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "hrsh7th/nvim-cmp",
    },
    config = function()
      require("tabout").setup {}
    end,
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "plugins.configs.lspconfig"
      require "custom.configs.lspconfig"
    end,
  },
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "eslint-lsp",
        "prettierd",
        "pyright", -- Python LSP
        "black",   -- Python formatter
        "ruff",    -- Python linter/formatter
        "isort",   -- Import sorter
        "tailwindcss-language-server",
        "typescript-language-server",
        "svelte-language-server",
      },
    },
  },
  {
    "nvimtools/none-ls.nvim",
    event = "VeryLazy",
    opts = function()
      return require "custom.configs.null-ls"
    end,
  },
  {
    "windwp/nvim-ts-autotag",
    ft = { "javascript", "javascriptreact", "typescript", "typescriptreact", "svelte" },
    config = function()
      require("nvim-ts-autotag").setup()
    end,
  },
}
return plugins

-- n, v, i, t = mode names

local M = {}

M.general = {
  i = {
    -- go to  beginning and end
    ["<C-b>"] = { "<ESC>^i", "Beginning of line" },
    ["<C-e>"] = { "<End>", "End of line" },

    -- navigate within insert mode
    ["<C-h>"] = { "<Left>", "Move left" },
    ["<C-l>"] = { "<Right>", "Move right" },
    ["<C-j>"] = { "<Down>", "Move down" },
    ["<C-k>"] = { "<Up>", "Move up" },

    -- ["<C-]"] = { "<Esc>", "Escape insert mode" },
  },

  n = {
    ["<Esc>"] = { "<cmd> noh <CR>", "Clear highlights" },
    -- switch between windows
    ["<C-h>"] = { "<C-w>h", "Window left" },
    ["<C-l>"] = { "<C-w>l", "Window right" },
    ["<C-j>"] = { "<C-w>j", "Window down" },
    ["<C-k>"] = { "<C-w>k", "Window up" },

    -- save
    ["<C-s>"] = { "<cmd> w <CR>", "Save file" },

    -- Copy all
    ["<C-c>"] = { "<cmd> %y+ <CR>", "Copy whole file" },

    -- line numbers
    ["<leader>n"] = { "<cmd> set nu! <CR>", "Toggle line number" },
    ["<leader>rn"] = { "<cmd> set rnu! <CR>", "Toggle relative number" },

    -- spell checking
    ["<leader>sp"] = { "<cmd> set spell! <CR>", "Toggle spell check" },

    -- Allow moving the cursor through wrapped lines with j, k, <Up> and <Down>
    -- http://www.reddit.com/r/vim/comments/2k4cbr/problem_with_gj_and_gk/
    -- empty mode is same as using <cmd> :map
    -- also don't use g[j|k] when in operator pending mode, so it doesn't alter d, y or c behaviour
    ["j"] = { 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', "Move down", opts = { expr = true } },
    ["k"] = { 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', "Move up", opts = { expr = true } },
    ["<Up>"] = { 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', "Move up", opts = { expr = true } },
    ["<Down>"] = { 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', "Move down", opts = { expr = true } },

    -- new buffer
    ["<leader>b"] = { "<cmd> enew <CR>", "New buffer" },
    ["<leader>ch"] = { "<cmd> NvCheatsheet <CR>", "Mapping cheatsheet" },

    ["<leader>fm"] = {
      function()
        vim.lsp.buf.format { async = true }
      end,
      "LSP formatting",
    },

    ["<C-d>"] = { "<C-d>zz", "Scroll down and center" },
    ["<C-u>"] = { "<C-u>zz", "Scroll up and center" },
    ["n"] = { "nzzzv", "Go to next result and center" },
    ["N"] = { "Nzzzv", "Go to previous result and center" },
    ["G"] = { "Gzz", "Go to end of file and center" },

    ["<leader>on"] = {
      function()
        vim.cmd "ObsidianTemplate Full Note"
        -- Wait for template to load, then clean up and enter ZenMode
        vim.defer_fn(function()
          pcall(function()
            vim.cmd [[1,/^\\S/s/^\\n\\{1,}//]]
          end)
          vim.cmd "ZenMode"
        end, 200)
      end,
      "Create Obsidian Full Note and enter ZenMode",
    },
    ["<leader>od"] = {
      ":ObsidianTemplate Daily Note<cr> :lua vim.cmd([[1,/^\\S/s/^\\n\\{1,}//]])<cr>",
      "Create Obsidian Daily Note",
    },
    ["<leader>ot"] = { ":ObsidianTags<cr>", "View Obsidian tags" },

    ["<leader>of"] = { ":s/\\(# \\)[^_]*_/\\1/ | s/-/ /g<cr>", "Strip date" },

    ["<leader>z"] = { "<cmd> ZenMode <CR>", "Toggle ZenMode" },

    ["<leader>mv"] = { "<cmd> Markview <CR>", "Toggle Markview" },
  },

  t = {
    ["<C-x>"] = { vim.api.nvim_replace_termcodes("<C-\\><C-N>", true, true, true), "Escape terminal mode" },
  },

  v = {
    ["<Up>"] = { 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', "Move up", opts = { expr = true } },
    ["<Down>"] = { 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', "Move down", opts = { expr = true } },
    ["<"] = { "<gv", "Indent line" },
    [">"] = { ">gv", "Indent line" },
  },

  x = {
    ["j"] = { 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', "Move down", opts = { expr = true } },
    ["k"] = { 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', "Move up", opts = { expr = true } },
    -- Don't copy the replaced text after pasting in visual mode
    -- https://vim.fandom.com/wiki/Replace_a_word_with_yanked_text#Alternative_mapping_for_paste
    ["p"] = { 'p:let @+=@0<CR>:let @"=@0<CR>', "Dont copy replaced text", opts = { silent = true } },
  },
}

M.tabufline = {
  plugin = true,

  n = {
    -- cycle through buffers
    ["<tab>"] = {
      function()
        require("nvchad.tabufline").tabuflineNext()
      end,
      "Goto next buffer",
    },

    ["<S-tab>"] = {
      function()
        require("nvchad.tabufline").tabuflinePrev()
      end,
      "Goto prev buffer",
    },

    -- close buffer + hide terminal buffer
    ["<leader>x"] = {
      function()
        require("nvchad.tabufline").close_buffer()
      end,
      "Close buffer",
    },
  },
}

M.comment = {
  plugin = true,

  -- toggle comment in both modes
  n = {
    ["<leader>/"] = {
      function()
        require("ts-comments").toggle()
      end,
      "Toggle comment",
    },
  },

  v = {
    ["<leader>/"] = {
      function()
        require("ts-comments").toggle()
      end,
      "Toggle comment",
    },
  },
}

M.lspconfig = {
  plugin = true,

  -- See `<cmd> :help vim.lsp.*` for documentation on any of the below functions

  n = {
    ["gD"] = {
      function()
        vim.lsp.buf.declaration()
      end,
      "LSP declaration",
    },

    ["gd"] = {
      function()
        vim.lsp.buf.definition()
      end,
      "LSP definition",
    },

    ["K"] = {
      function()
        vim.lsp.buf.hover()
      end,
      "LSP hover",
    },

    ["gi"] = {
      function()
        vim.lsp.buf.implementation()
      end,
      "LSP implementation",
    },

    ["<leader>ls"] = {
      function()
        vim.lsp.buf.signature_help()
      end,
      "LSP signature help",
    },

    ["<leader>D"] = {
      function()
        vim.lsp.buf.type_definition()
      end,
      "LSP definition type",
    },

    ["<leader>ra"] = {
      function()
        require("nvchad.renamer").open()
      end,
      "LSP rename",
    },

    ["<leader>ca"] = {
      function()
        vim.lsp.buf.code_action()
      end,
      "LSP code action",
    },

    ["gr"] = {
      function()
        vim.lsp.buf.references()
      end,
      "LSP references",
    },

    ["<leader>lf"] = {
      function()
        vim.diagnostic.open_float { border = "rounded" }
      end,
      "Floating diagnostic",
    },

    ["[d"] = {
      function()
        vim.diagnostic.goto_prev { float = { border = "rounded" } }
      end,
      "Goto prev",
    },

    ["]d"] = {
      function()
        vim.diagnostic.goto_next { float = { border = "rounded" } }
      end,
      "Goto next",
    },

    ["<leader>q"] = {
      function()
        vim.diagnostic.setloclist()
      end,
      "Diagnostic setloclist",
    },

    ["<leader>wa"] = {
      function()
        vim.lsp.buf.add_workspace_folder()
      end,
      "Add workspace folder",
    },

    ["<leader>wr"] = {
      function()
        vim.lsp.buf.remove_workspace_folder()
      end,
      "Remove workspace folder",
    },

    ["<leader>wl"] = {
      function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
      end,
      "List workspace folders",
    },
  },

  v = {
    ["<leader>ca"] = {
      function()
        vim.lsp.buf.code_action()
      end,
      "LSP code action",
    },
  },
}

M.nvimtree = {
  plugin = true,

  n = {
    -- toggle
    ["<C-n>"] = { "<cmd> NvimTreeToggle <CR>", "Toggle nvimtree" },

    -- focus
    ["<leader>e"] = { "<cmd> NvimTreeFocus <CR>", "Focus nvimtree" },
  },
}

M.telescope = {
  plugin = true,

  n = {
    -- find
    ["<leader>ff"] = { "<cmd> Telescope find_files <CR>", "Find files" },
    ["<leader>fa"] = { "<cmd> Telescope find_files follow=true no_ignore=true hidden=true <CR>", "Find all" },
    ["<leader>fw"] = { "<cmd> Telescope live_grep <CR>", "Live grep" },
    ["<leader>fb"] = { "<cmd> Telescope buffers <CR>", "Find buffers" },
    ["<leader>fh"] = { "<cmd> Telescope help_tags <CR>", "Help page" },
    ["<leader>fo"] = { "<cmd> Telescope oldfiles <CR>", "Find oldfiles" },
    ["<leader>fz"] = { "<cmd> Telescope current_buffer_fuzzy_find <CR>", "Find in current buffer" },

    -- git
    ["<leader>cm"] = { "<cmd> Telescope git_commits <CR>", "Git commits" },
    ["<leader>gt"] = { "<cmd> Telescope git_status <CR>", "Git status" },

    -- pick a hidden term
    ["<leader>pt"] = { "<cmd> Telescope terms <CR>", "Pick hidden term" },

    -- theme switcher
    ["<leader>th"] = { "<cmd> Telescope themes <CR>", "Nvchad themes" },

    ["<leader>ma"] = { "<cmd> Telescope marks <CR>", "telescope bookmarks" },

    ["<leader>tc"] = {
      function()
        -- Only works for Typst files
        if vim.bo.filetype ~= "typst" then
          vim.notify("This command only works with Typst files (.typ)", vim.log.levels.WARN, { title = "Typst" })
          return
        end

        local pickers = require "telescope.pickers"
        local finders = require "telescope.finders"
        local conf = require("telescope.config").values
        local actions = require "telescope.actions"
        local action_state = require "telescope.actions.state"

        local opts = {
          "Compile to PDF",
          "Compile to PNG",
          "Compile to SVG",
          "Watch and compile",
        }

        pickers
            .new({}, {
              prompt_title = "Typst Compile Options",
              finder = finders.new_table {
                results = opts,
              },
              sorter = conf.generic_sorter {},
              attach_mappings = function(prompt_bufnr, map)
                actions.select_default:replace(function()
                  actions.close(prompt_bufnr)
                  local selection = action_state.get_selected_entry()
                  local choice = selection[1]

                  local file = vim.fn.expand "%:p"
                  local basename = vim.fn.expand "%:p:r"
                  local cmd

                  if choice == "Compile to PDF" then
                    cmd = "typst compile " .. file .. " " .. basename .. ".pdf"
                  elseif choice == "Compile to PNG" then
                    cmd = "typst compile " .. file .. " --format png " .. basename .. ".png"
                  elseif choice == "Compile to SVG" then
                    cmd = "typst compile " .. file .. " --format svg " .. basename .. ".svg"
                  elseif choice == "Watch and compile" then
                    cmd = "typst watch " .. file .. " " .. basename .. ".pdf"
                  end

                  vim.fn.jobstart(cmd, {
                    on_exit = function(_, code)
                      if code == 0 then
                        vim.notify(
                          "✓ " .. choice .. " completed successfully",
                          vim.log.levels.INFO,
                          { title = "Typst" }
                        )
                      else
                        vim.notify("✗ " .. choice .. " failed", vim.log.levels.ERROR, { title = "Typst" })
                      end
                    end,
                    on_stderr = function(_, data)
                      if data and #data > 0 and data[1] ~= "" then
                        vim.notify("Error: " .. table.concat(data, "\n"), vim.log.levels.ERROR, { title = "Typst" })
                      end
                    end,
                  })
                end)
                return true
              end,
            })
            :find()
      end,
      "Typst compile options",
    },

    ["<leader>md"] = {
      function()
        -- Only works for Markdown files
        if vim.bo.filetype ~= "markdown" then
          vim.notify("This command only works with Markdown files (.md)", vim.log.levels.WARN, { title = "Markdown" })
          return
        end

        local pickers = require "telescope.pickers"
        local finders = require "telescope.finders"
        local conf = require("telescope.config").values
        local actions = require "telescope.actions"
        local action_state = require "telescope.actions.state"

        local opts = {
          "Convert to PDF (LaTeX engine)",
          "Convert to HTML (pandoc)",
          "Convert to DOCX (pandoc)",
          "Live preview in browser",
          "PDF preview (auto-open)",
        }

        pickers
            .new({}, {
              prompt_title = "Markdown Convert Options",
              finder = finders.new_table {
                results = opts,
              },
              sorter = conf.generic_sorter {},
              attach_mappings = function(prompt_bufnr, map)
                actions.select_default:replace(function()
                  actions.close(prompt_bufnr)
                  local selection = action_state.get_selected_entry()
                  local choice = selection[1]

                  local file = vim.fn.expand "%:p"
                  local basename = vim.fn.expand "%:p:r"
                  local cmd

                  if choice == "Convert to PDF (LaTeX engine)" then
                    -- Use LaTeX engine with math support and Obsidian image conversion
                    local temp_file = basename .. "_temp.md"
                    cmd = "sed 's/!\\?\\[\\[\\([^|]*\\)|[0-9]*\\]\\]/![](\\1)/g' '"
                        .. file
                        .. "' | sed 's/%20/ /g' > '"
                        .. temp_file
                        .. "' && pandoc '"
                        .. temp_file
                        .. "' --pdf-engine=pdflatex -V geometry:margin=0.5in --highlight-style=tango -o '"
                        .. basename
                        .. ".pdf' && rm '"
                        .. temp_file
                        .. "'"
                  elseif choice == "Convert to HTML (pandoc)" then
                    cmd = "pandoc '" .. file .. "' -o '" .. basename .. ".html'"
                  elseif choice == "Convert to DOCX (pandoc)" then
                    cmd = "pandoc '" .. file .. "' -o '" .. basename .. ".docx'"
                  elseif choice == "Live preview in browser" then
                    -- Start markdown preview server
                    local port = "8080"
                    vim.fn.jobstart("grip '" .. file .. "' " .. port .. " --browser", {
                      detach = true,
                      on_exit = function(_, code)
                        if code == 0 then
                          vim.notify(
                            "✓ Live preview started at http://localhost:" .. port,
                            vim.log.levels.INFO,
                            { title = "Markdown" }
                          )
                        else
                          vim.notify(
                            "✗ Failed to start preview. Check terminal for errors.",
                            vim.log.levels.ERROR,
                            { title = "Markdown" }
                          )
                        end
                      end,
                    })
                    return
                  elseif choice == "PDF preview (auto-open)" then
                    -- Convert to PDF and open automatically
                    local pdf_file = basename .. "_preview.pdf"
                    cmd = "pandoc '"
                        .. file
                        .. "' --pdf-engine=pdflatex --highlight-style=tango -o '"
                        .. pdf_file
                        .. "' && xdg-open '"
                        .. pdf_file
                        .. "'"
                  end

                  vim.fn.jobstart(cmd, {
                    on_exit = function(_, code)
                      if code == 0 then
                        vim.notify(
                          "✓ " .. choice .. " completed successfully",
                          vim.log.levels.INFO,
                          { title = "Markdown" }
                        )
                      else
                        vim.notify(
                          "✗ " .. choice .. " failed. Make sure you have the required tools installed (pandoc/glow).",
                          vim.log.levels.ERROR,
                          { title = "Markdown" }
                        )
                      end
                    end,
                    on_stderr = function(_, data)
                      if data and #data > 0 and data[1] ~= "" then
                        vim.notify("Error: " .. table.concat(data, "\n"), vim.log.levels.ERROR, { title = "Markdown" })
                      end
                    end,
                  })
                end)
                return true
              end,
            })
            :find()
      end,
      "Markdown convert options",
    },
  },
}

M.nvterm = {
  plugin = true,

  t = {
    -- toggle in terminal mode
    ["<A-i>"] = {
      function()
        require("nvterm.terminal").toggle "float"
      end,
      "Toggle floating term",
    },

    ["<A-h>"] = {
      function()
        require("nvterm.terminal").toggle "horizontal"
      end,
      "Toggle horizontal term",
    },

    ["<A-v>"] = {
      function()
        require("nvterm.terminal").toggle "vertical"
      end,
      "Toggle vertical term",
    },
  },

  n = {
    -- toggle in normal mode
    ["<A-i>"] = {
      function()
        require("nvterm.terminal").toggle "float"
      end,
      "Toggle floating term",
    },

    ["<A-h>"] = {
      function()
        require("nvterm.terminal").toggle "horizontal"
      end,
      "Toggle horizontal term",
    },

    ["<A-v>"] = {
      function()
        require("nvterm.terminal").toggle "vertical"
      end,
      "Toggle vertical term",
    },

    -- new
    ["<leader>h"] = {
      function()
        require("nvterm.terminal").new "horizontal"
      end,
      "New horizontal term",
    },

    ["<leader>v"] = {
      function()
        require("nvterm.terminal").new "vertical"
      end,
      "New vertical term",
    },
  },
}

M.whichkey = {
  plugin = true,

  n = {
    ["<leader>wK"] = {
      function()
        vim.cmd "WhichKey"
      end,
      "Which-key all keymaps",
    },
    ["<leader>wk"] = {
      function()
        local input = vim.fn.input "WhichKey: "
        vim.cmd("WhichKey " .. input)
      end,
      "Which-key query lookup",
    },
  },
}

M.blankline = {
  plugin = true,

  n = {
    ["<leader>cc"] = {
      function()
        local ok, start = require("indent_blankline.utils").get_current_context(
          vim.g.indent_blankline_context_patterns,
          vim.g.indent_blankline_use_treesitter_scope
        )

        if ok then
          vim.api.nvim_win_set_cursor(vim.api.nvim_get_current_win(), { start, 0 })
          vim.cmd [[normal! _]]
        end
      end,

      "Jump to current context",
    },
  },
}

M.gitsigns = {
  plugin = true,

  n = {
    -- Navigation through hunks
    ["]c"] = {
      function()
        if vim.wo.diff then
          return "]c"
        end
        vim.schedule(function()
          require("gitsigns").next_hunk()
        end)
        return "<Ignore>"
      end,
      "Jump to next hunk",
      opts = { expr = true },
    },

    ["[c"] = {
      function()
        if vim.wo.diff then
          return "[c"
        end
        vim.schedule(function()
          require("gitsigns").prev_hunk()
        end)
        return "<Ignore>"
      end,
      "Jump to prev hunk",
      opts = { expr = true },
    },

    -- Actions
    ["<leader>rh"] = {
      function()
        require("gitsigns").reset_hunk()
      end,
      "Reset hunk",
    },

    ["<leader>ph"] = {
      function()
        require("gitsigns").preview_hunk()
      end,
      "Preview hunk",
    },

    ["<leader>gb"] = {
      function()
        package.loaded.gitsigns.blame_line()
      end,
      "Blame line",
    },

    ["<leader>td"] = {
      function()
        require("gitsigns").toggle_deleted()
      end,
      "Toggle deleted",
    },
  },
}

return M

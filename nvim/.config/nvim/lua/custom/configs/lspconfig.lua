local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities

local lspconfig = require "lspconfig"

local servers = { "ts_ls", "tailwindcss", "eslint", "pyright", "svelte" }

for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
  }
end

-- Typst LSP setup
lspconfig.typst_lsp.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    exportPdf = "onType", -- Change to "onSave" or "never" as needed
  },
}

-- Harper LS setup for grammar checking (disabled by default, toggle with <leader>hg)
-- lspconfig.harper_ls.setup {
--   on_attach = on_attach,
--   capabilities = capabilities,
--   settings = {
--     ["harper-ls"] = {
--       linters = {
--         SpellCheck = true,
--         SentenceCapitalization = true,
--         UnclosedQuotes = true,
--         RepeatedWords = true,
--         Spaces = true,
--         Matcher = true,
--         CorrectNumberSuffix = true,
--       },
--       diagnosticSeverity = "hint",
--       isolateEnglish = false,
--     }
--   }
-- }

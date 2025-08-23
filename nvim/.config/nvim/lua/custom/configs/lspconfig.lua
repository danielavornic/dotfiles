local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities

local lspconfig = require("lspconfig")

local servers = {"ts_ls", "tailwindcss", "eslint"}

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
    exportPdf = "onType" -- Change to "onSave" or "never" as needed
  }
}

local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities

local lspconfig = require("lspconfig")
local configs = require("lspconfig.configs")
local util = require("lspconfig.util")

vim.filetype.add({
	extension = {
		hurl = "hurl",
	},
})

if not configs.hurl_lsp then
	configs.hurl_lsp = {
		default_config = {
			cmd = { "hurl-lsp" },
			filetypes = { "hurl" },
			root_dir = util.root_pattern(".git", "hurl.config", "hurl.config.json"),
			single_file_support = true,
		},
		docs = {
			description = "Language server for Hurl files.",
		},
	}
end

local utf8_capabilities = vim.tbl_deep_extend("force", capabilities, {
	general = { positionEncodings = { "utf-8" } },
})

local servers = { "ts_ls", "tailwindcss", "eslint", "pyright", "svelte", "prismals" }

lspconfig.biome.setup({
	on_new_config = function(config, root_dir)
		local local_bin = root_dir .. "/node_modules/.bin/biome"
		if vim.fn.executable(local_bin) == 1 then
			config.cmd = { local_bin, "lsp-proxy" }
		end
	end,
	on_attach = function(client, bufnr)
		on_attach(client, bufnr)
		vim.api.nvim_create_autocmd("BufWritePre", {
			buffer = bufnr,
			callback = function()
				local params = vim.lsp.util.make_range_params(0, client.offset_encoding)
				params.context = { only = { "source.organizeImports" }, diagnostics = {} }
				local resp = vim.lsp.buf_request_sync(bufnr, "textDocument/codeAction", params, 2000)
				if not resp then
					return
				end
				for _, res in pairs(resp) do
					for _, action in pairs(res.result or {}) do
						if action.edit then
							vim.lsp.util.apply_workspace_edit(action.edit, "utf-8")
						end
					end
				end
				vim.lsp.buf.format({ bufnr = bufnr, id = client.id })
			end,
		})
	end,
	capabilities = capabilities,
})

for _, lsp in ipairs(servers) do
	lspconfig[lsp].setup({
		on_attach = on_attach,
		capabilities = utf8_capabilities,
	})
end

-- C# LSP setup (OmniSharp via Mason)
local omnisharp_path = vim.fn.stdpath("data") .. "/mason/packages/omnisharp/libexec/OmniSharp.dll"
lspconfig.omnisharp.setup({
	on_attach = on_attach,
	capabilities = vim.tbl_deep_extend("force", capabilities, {
		workspace = { workspaceFolders = false },
	}),
	cmd = {
		"dotnet",
		omnisharp_path,
		"-z",
		"--hostPID",
		tostring(vim.fn.getpid()),
		"DotNet:enablePackageRestore=false",
		"--encoding",
		"utf-8",
		"--languageserver",
	},
})

lspconfig.mdx_analyzer.setup({
	on_attach = on_attach,
	capabilities = capabilities,
})

lspconfig.hurl_lsp.setup({
	on_attach = on_attach,
	capabilities = capabilities,
})

-- Typst LSP setup
lspconfig.tinymist.setup({
	on_attach = on_attach,
	capabilities = capabilities,
	settings = {
		exportPdf = "never",
	},
})

-- Harper LS setup for grammar checking (disabled by default, toggle with <leader>hg)
lspconfig.harper_ls.setup({
	on_attach = on_attach,
	capabilities = capabilities,
	filetypes = { "typst", "markdown" },
	autostart = false,
	settings = {
		["harper-ls"] = {
			linters = {
				SpellCheck = true,
				SentenceCapitalization = true,
				UnclosedQuotes = true,
				RepeatedWords = true,
				Spaces = true,
				Matcher = true,
				CorrectNumberSuffix = true,
			},
			diagnosticSeverity = "hint",
			isolateEnglish = false,
		},
	},
})

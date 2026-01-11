return function()
  local cwd = vim.fn.getcwd()

  require("neotest").setup {
    adapters = {
      require "neotest-jest" {
        jestCommand = "npx jest",
        jestConfigFile = "package.json",
        env = { CI = true },
        cwd = function(path)
          return vim.fn.getcwd()
        end,
      },
      require "neotest-vitest" {
        vitestConfigPath = cwd .. "/vitest.config.js",
      },
    },
  }
end

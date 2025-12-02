return function()
  local cwd = vim.fn.getcwd()

  require("neotest").setup {
    adapters = {
      -- require "neotest-jest" {
      --   jestCommand = "jest",
      -- },
      require "neotest-vitest" {
        vitestConfigPath = cwd .. "/vitest.config.js",
      },
    },
  }
end

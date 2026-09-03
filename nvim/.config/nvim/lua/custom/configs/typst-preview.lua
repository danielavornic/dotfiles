local M = {}

M.start = function()
  if vim.bo.filetype ~= "typst" then
    vim.notify("Not a Typst file", vim.log.levels.WARN, { title = "Typst Preview" })
    return
  end

  local file = vim.fn.expand "%:p"

  if _G.tinymist_preview_job then
    vim.notify("Preview already running", vim.log.levels.INFO, { title = "Typst Preview" })
    return
  end

  _G.tinymist_preview_job = vim.fn.jobstart({
    "tinymist",
    "preview",
    file,
    "--open",
    "--partial-rendering",
    "true",
  }, {
    detach = true,
    on_exit = function(_, code)
      _G.tinymist_preview_job = nil
      if code ~= 0 then
        vim.notify("Preview exited with code " .. code, vim.log.levels.WARN, { title = "Typst Preview" })
      end
    end,
    on_stderr = function(_, data)
      if data and #data > 0 and data[1] ~= "" then
        local msg = table.concat(data, "\n")
        -- suppress noisy info logs
        if not msg:match("INFO") then
          vim.notify(msg, vim.log.levels.ERROR, { title = "Typst Preview" })
        end
      end
    end,
  })

  vim.notify("Starting tinymist preview...", vim.log.levels.INFO, { title = "Typst Preview" })
end

M.stop = function()
  if not _G.tinymist_preview_job then
    vim.notify("No preview running", vim.log.levels.WARN, { title = "Typst Preview" })
    return
  end

  vim.fn.jobstop(_G.tinymist_preview_job)
  _G.tinymist_preview_job = nil
  vim.notify("Preview stopped", vim.log.levels.INFO, { title = "Typst Preview" })
end

M.toggle = function()
  if _G.tinymist_preview_job then
    M.stop()
  else
    M.start()
  end
end

return M

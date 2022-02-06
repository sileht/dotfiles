local M = {}

function M.cd()
  local buftype = vim.fn.getbufvar(vim.fn.bufnr(), "&buftype")
  if buftype == "quickfix" then
    -- vim.cmd("lcd " .. M.initial_dir)
    return
  else
    local current_file_dir = vim.fn.expand("%:p:h")
    if vim.fn.isdirectory(current_file_dir) ~= 0 then
      vim.cmd("lcd " .. current_file_dir)
    end
  end
  -- print("Change dir to: " .. vim.fn.getcwd())
end

function M.setup()
  M.initial_dir = vim.fn.getcwd()
  -- vim.cmd("autocmd BufReadPost * silent! lcd .")
  vim.cmd("autocmd BufEnter * lua require('cd_to_buffers').cd()")
end

return M

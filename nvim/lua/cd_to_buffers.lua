local M = {}

function M.cd()
  local current_file_dir = vim.fn.expand("%:p:h")
  if vim.fn.isdirectory(current_file_dir) ~= 0 then
      vim.cmd("lcd " .. current_file_dir)
  end
end

function M.setup()
    vim.cmd("autocmd BufEnter * lua require('cd_to_buffers').cd()")
end

return M

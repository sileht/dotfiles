local M = {}

local function indent_lines(lines, offset)
  return vim.tbl_map(
    function(val)
      return offset .. val
    end,
    lines
  )
end

function M.create(name, what)
  local buf_lines = {"Use [q] or [Esc] to quit the window", ""}
  what = vim.deepcopy(what)

  if type(what) == "string" then
    what = {what}
  else
    assert(type(what) == "table", '"what" must be a table')
  end

  local windows = require "lspconfig.ui.windows"
  local win_info = windows.percentage_range_window(0.8, 0.7, {wrap = true})
  local bufnr, win_id = win_info.bufnr, win_info.win_id

  what = vim.list_extend({"Use [q] or [Esc] to quit the window", ""}, what)
  local fmt_buf_lines = indent_lines(what, " ")
  fmt_buf_lines = vim.lsp.util._trim(fmt_buf_lines, {})

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, fmt_buf_lines)
  vim.api.nvim_buf_set_option(bufnr, "modifiable", false)
  vim.api.nvim_buf_set_option(bufnr, "filetype", "lspinfo")
  vim.api.nvim_buf_add_highlight(bufnr, 0, "LspInfoTip", 0, 0, -1)

  local augroup = vim.api.nvim_create_augroup(name, {clear = false})
  local function close()
    vim.api.nvim_clear_autocmds {group = augroup, buffer = bufnr}
    if vim.api.nvim_buf_is_valid(bufnr) then
      vim.api.nvim_buf_delete(bufnr, {force = true})
    end
    if vim.api.nvim_win_is_valid(win_id) then
      vim.api.nvim_win_close(win_id, true)
    end
  end
  vim.keymap.set("n", "<ESC>", close, {buffer = bufnr, nowait = true})
  vim.keymap.set("n", "q", close, {buffer = bufnr, nowait = true})
  vim.api.nvim_create_autocmd(
    {"BufDelete", "BufLeave", "BufHidden"},
    {
      once = true,
      buffer = bufnr,
      callback = close,
      group = augroup
    }
  )
end
return M

local M = {}
function M.dump(o)
  if type(o) == "table" then
    local s = "{ "
    for k, v in pairs(o) do
      if type(k) ~= "number" then
        k = '"' .. k .. '"'
      end
      s = s .. "[" .. k .. "] = " .. M.dump(v) .. ","
    end
    return s .. "} "
  else
    return tostring(o)
  end
end

function M.get_rootdir()
  local lspconfig = require("lspconfig")
  local folders = vim.lsp.buf.list_workspace_folders()
  local rootdir = folders[0] or folders[1]
  local rootdir2 =
    lspconfig.util.root_pattern(
    "pyproject.toml",
    "setup.py",
    "setup.cfg",
    "requirements.txt",
    "Pipfile",
    ".git",
    "package.json"
  )(vim.api.nvim_buf_get_name(0))
  -- print((rootdir or "") .. " vs " .. (rootdir2 or ""))
  return rootdir2
end

return M

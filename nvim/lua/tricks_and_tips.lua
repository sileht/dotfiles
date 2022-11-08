local M = {}

M.tricks_and_tips_selected = ""
M.tricks_and_tips =
  [[
<F5> -> lsp.rename
gcc -> line comment
gbc -> block comment
gD -> lsp.delaration
gd -> lsp.definition
gr -> lsp.refereances
K -> lsp.hover_doc
gi -> lsp.implementation
<C-k> -> lsp.signature
<leader>D -> lsp.typedef
<leader>ca -> lsp.codeaction
<leader>fp -> telescope.builtin
<leader>fc -> telescope.git_commits
<leader>fs -> telescope.lsp_symbols
<leader>ff -> telescope.find_files
<leader>fg -> telescope.live_grep
<leader>fb -> telescope.buffers
<leader>fh -> telescope.help_tags
<leader>gb -> git blame
<leader>gd -> git delete lines
<leader>gu -> github url
<leader>e -> ranger
<leader>x -> Trouble diagnostic
ga -> EasyAlign
]]

function M.change()
  local lines = {}
  for line in M.tricks_and_tips:gmatch("[^\r\n]+") do
    lines[#lines + 1] = line
  end
  local i = math.random(#lines)
  M.tricks_and_tips_selected = lines[i]
end

function M.setup()
  M.change()
  vim.defer_fn(M.setup, 30000)
end

function M.status()
  return "     " .. M.tricks_and_tips_selected .. " "
end

function M.show()
  local lines = {}
  for s in M.tricks_and_tips:gmatch("[^\r\n]+") do
    table.insert(lines, s)
  end
  require("utils").create_popup("tricks_and_tips", lines)
end

return M

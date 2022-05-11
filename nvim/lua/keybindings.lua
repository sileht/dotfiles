local M = {}

M.focus_mode = false

function M.toggle_focus()
  M.focus_mode = not M.focus_mode
  if M.focus_mode then
    --vim.cmd("cclose")
    print("focus layout")
    vim.opt.laststatus = 0
    vim.opt.number = false
    vim.opt.relativenumber = false
    vim.opt.signcolumn = "no"
    require("gitsigns.config").config.signcolumn = false
    require("gitsigns.actions").refresh()
    require("scrollview").scrollview_disable()
  else
    print("normal layout")
    --vim.cmd("copen")
    vim.cmd("wincmd p")
    require("scrollview").scrollview_enable()
    require("gitsigns.actions").refresh()
    require("gitsigns.config").config.signcolumn = true
    vim.opt.signcolumn = "yes"
    vim.opt.relativenumber = true
    vim.opt.number = true
    vim.opt.laststatus = 3
  end
end

function M.setup_which_key()
  local wk = require("which-key")
  wk.setup({})
  wk.register(
    {
      t = {"<cmd>lua require('tricks_and_tips').change()<cr>", "Tricks and Tips"},
      d = {"<cmd>lua require('telescope.builtin').diagnostics({bufnr=0})<cr>", "Telescope diagnostics"},
      fp = {"<cmd>lua require('telescope.builtin').builtin()<cr>", "Telescope builtin"},
      fc = {"<cmd>lua require('telescope.builtin').git_commits()<cr>", "Telescope git commit"},
      fs = {"<cmd>lua require('telescope.builtin').lsp_document_symbols()<cr>", "Telescope symbols"},
      fd = {"<cmd>lua require('telescope.builtin').lsp_type_definitions()<cr>", "Telescope type definitions"},
      fD = {"<cmd>lua require('telescope.builtin').lsp_definitions()<cr>", "Telescope definitions"},
      ff = {"<cmd>lua require('telescope.builtin').find_files()<cr>", "Telescope find"},
      fg = {"<cmd>lua require('telescope.builtin').live_grep()<cr>", "Telescope grep"},
      fb = {"<cmd>lua require('telescope.builtin').buffers()<cr>", "Telescope buffer"},
      fh = {"<cmd>lua require('telescope.builtin').help_tags()<cr>", "Telescope help tags"},
      D = {"<cmd>lua vim.lsp.buf.type_definition()<cr>", "Type definition"},
      ca = {"<cmd>lua vim.lsp.buf.code_action()<cr>", "Code action"},
      j = {":HopWord<cr>", "Hop"},
      e = {":RnvimrToggle<cr>", "Explorer"}
    },
    {prefix = "<leader>"}
  )
end

function M.setup_legacy_key()
  vim.cmd(
    [[
nnoremap P "0p                            " Paste last yank
nnoremap Y y$                             " Yank from the cursor to the end of the line, to be consistent with C and D.
command! R execute "source ~/.config/nvim/init.lua | PackerSync"
augroup packer_user_config
  autocmd!
  autocmd BufWritePost *.lua source <afile> | PackerCompile
augroup end

nnoremap <F12> <cmd>lua require("keybindings").toggle_focus()<cr>
nnoremap <F5> <cmd>lua vim.lsp.buf.rename()<cr>
nnoremap K <cmd>lua vim.lsp.buf.hover()<cr>
nnoremap gP <cmd>lua vim.diagnostic.goto_prev()<cr>
nnoremap gN <cmd>lua vim.diagnostic.goto_next()<cr>
nnoremap gD <cmd>lua vim.lsp.buf.declaration()<cr>
nnoremap gd <cmd>lua vim.lsp.buf.definition()<cr>
nnoremap gr <cmd>lua vim.lsp.buf.references()<cr>
nnoremap gi <cmd>lua vim.lsp.buf.implementation()<cr>
nnoremap <C-k> <cmd>lua vim.lsp.buf.signature_help()<cr>
nnoremap <silent> <F11> :set spell!<cr>

function! BSkipQuickFix(command)
  let start_buffer = bufnr('%')
  execute a:command
  while &buftype ==# 'quickfix' && bufnr('%') != start_buffer
    execute a:command
  endwhile
endfunction

" https://github.com/neovim/neovim/issues/13628
cnoremap bd silent! bd

nmap <silent> <S-left>  :call BSkipQuickFix("bp")<Enter>
nmap <silent> <S-right> :call BSkipQuickFix("bn")<Enter>
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)
cmap w!! :w suda://%<CR>:e!<CR>

]]
  )
end

return M

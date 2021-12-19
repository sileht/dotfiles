
vim.cmd([[
nnoremap P "0p                            " Paste last yank
nnoremap Y y$                             " Yank from the cursor to the end of the line, to be consistent with C and D.
command! R execute "source ~/.config/nvim/init.vim"

nnoremap <leader>x <cmd>TroubleToggle<cr>
nnoremap <silent> <leader>e :NERDTreeToggle<CR>
nnoremap <Leader>t <cmd>lua require('tricks_and_tips').change()<cr>
nnoremap <Leader>fp <cmd>lua require('telescope.builtin').builtin()<cr>
nnoremap <Leader>fc <cmd>lua require('telescope.builtin').git_commits()<cr>
nnoremap <leader>fs <cmd>lua require('telescope.builtin').lsp_document_symbols()<cr>
nnoremap <leader>ff <cmd>lua require('telescope.builtin').find_files()<cr>
nnoremap <leader>fg <cmd>lua require('telescope.builtin').live_grep()<cr>
nnoremap <leader>fb <cmd>lua require('telescope.builtin').buffers()<cr>
nnoremap <leader>fh <cmd>lua require('telescope.builtin').help_tags()<cr>
nnoremap <F5> <cmd>lua vim.lsp.buf.rename()<cr>
nnoremap K <cmd>lua vim.lsp.buf.hover()<cr>
nnoremap gD <cmd>lua vim.lsp.buf.declaration()<cr>
nnoremap gd <cmd>lua vim.lsp.buf.definition()<cr>
nnoremap gr <cmd>lua vim.lsp.buf.references()<cr>
nnoremap gi <cmd>lua vim.lsp.buf.implementation()<cr>
nnoremap <C-k> <cmd>lua vim.lsp.buf.signature_help()<cr>
nnoremap <leader>D <cmd>lua vim.lsp.buf.type_definition()<cr>
nnoremap <leader>ca <cmd>lua vim.lsp.buf.code_action()<cr>
nnoremap <silent> <F11> :set spell!<cr>

nmap <S-left>  :TablineBufferPrevious<Enter>
nmap <S-right> :TablineBufferNext<Enter>
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)
cmap w!! :w suda://%<CR>:e!<CR>

augroup packer_user_config
  autocmd!
  autocmd BufWritePost plugins.lua source <afile> | PackerSync
augroup end
]])

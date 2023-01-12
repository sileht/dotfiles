local M = {}

function M.buffer_delete_workaround()
  local buffer = vim.api.nvim_get_current_buf()
  vim.cmd("bn")
  vim.cmd("bdelete " .. buffer)
end

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
    require("trouble").close()
    vim.opt.cmdheight = 0
  else
    require("scrollview").scrollview_enable()
    require("gitsigns.actions").refresh()
    require("gitsigns.config").config.signcolumn = true
    vim.opt.signcolumn = "yes"
    vim.opt.relativenumber = true
    vim.opt.number = true
    vim.opt.laststatus = 3
    require("trouble").open()
    vim.opt.cmdheight = 1
    vim.cmd("wincmd p")
  end
end

function M.setup_which_key()
  local wk = require("which-key")
  wk.setup({})
  wk.register(
    {
      ["<C-k>"] = {"<cmd>lua vim.lsp.buf.signature_help()<cr>", "Show signature"},
      ["<F5>"] = {"<cmd>lua vim.lsp.buf.rename()<cr>", "Rename"},
      ["<F10>"] = {"<cmd>lua require('post_write_tools').toggle()<cr>", "Toggle FormatWrite"},
      ["<F11>"] = {":set spell!<cr>", "Toggle spell"},
      ["<F12>"] = {"<cmd>lua require('keybindings').toggle_focus()<cr>", "Show/Hide keybindings"},
      K = {"<cmd>lua vim.lsp.buf.hover()<cr>", "Documentation"},
      gP = {"<cmd>lua vim.diagnostic.goto_prev()<cr>", "Diagnostic previous"},
      gN = {"<cmd>lua vim.diagnostic.goto_next()<cr>", "Diagnostic next"},
      gD = {"<cmd>lua vim.lsp.buf.declaration()<cr>", "Go declaration"},
      gd = {"<cmd>lua vim.lsp.buf.definition()<cr>", "Go definition"},
      -- gr = {"<cmd>lua vim.lsp.buf.references()<cr>", "Go references"}
      gr = {"<cmd>lua require('telescope.builtin').lsp_references()<cr>", "Go references"},
      gi = {"<cmd>lua vim.lsp.buf.implementation()<cr>", "Go implementation"}
      -- n = {[[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]], "Search next"},
      -- N = {[[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]], "Search previous"}
    }
  )
  wk.register(
    {
      s = {"<cmd>SymbolsOutline<CR>", "Symbols sidebar"},
      gb = {"<cmd>lua require('gitsigns').blame_line({full=true})<cr>", "Git Blame"},
      gd = {"<cmd>lua require('gitsigns').toggle_deleted()<cr>", "Git show deleted"},
      gy = {
        "<cmd>lua require('gitlinker').get_buf_range_url('n', {action_callback = require('gitlinker.actions').open_in_browser})<cr>",
        "Open line in browser"
      },
      T = {"<cmd>lua require('tricks_and_tips').change()<cr>", "Tricks and Tips"},
      t = {"<cmd>lua require('tricks_and_tips').show()<cr>", "Tricks and Tips"},
      d = {"<cmd>lua require('telescope.builtin').diagnostics({bufnr=0})<cr>", "Telescope diagnostics"},
      fp = {"<cmd>lua require('telescope.builtin').builtin()<cr>", "Telescope builtin"},
      fc = {"<cmd>lua require('telescope.builtin').git_commits()<cr>", "Telescope git commit"},
      fs = {"<cmd>lua require('telescope.builtin').lsp_document_symbols()<cr>", "Telescope symbols"},
      fr = {"<cmd>lua require('telescope.builtin').lsp_references()<cr>", "Telescope references"},
      fd = {"<cmd>lua require('telescope.builtin').lsp_type_definitions()<cr>", "Telescope type definitions"},
      fD = {"<cmd>lua require('telescope.builtin').lsp_definitions()<cr>", "Telescope definitions"},
      ff = {"<cmd>lua require('telescope.builtin').find_files()<cr>", "Telescope find"},
      fg = {"<cmd>lua require('telescope.builtin').live_grep()<cr>", "Telescope grep"},
      fb = {"<cmd>lua require('telescope.builtin').buffers()<cr>", "Telescope buffer"},
      fh = {"<cmd>lua require('telescope.builtin').help_tags()<cr>", "Telescope help tags"},
      D = {"<cmd>lua vim.lsp.buf.type_definition()<cr>", "Type definition"},
      ca = {"<cmd>lua vim.lsp.buf.code_action()<cr>", "Code action"},
      -- ca = {"<cmd>CodeActionMenu<cr>", "Code action"},
      j = {":HopWord<cr>", "Hop"},
      k = {""},
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

function! BSkipQuickFix(command)
  let start_buffer = bufnr('%')
  execute a:command
  while &buftype ==# 'quickfix' && bufnr('%') != start_buffer
    execute a:command
  endwhile
endfunction

cnoreabbrev bd :lua require('keybindings').buffer_delete_workaround()

nmap <silent> <S-left>  :call BSkipQuickFix("bp")<Enter>
nmap <silent> <S-right> :call BSkipQuickFix("bn")<Enter>
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)
cmap w!! :w suda://%<CR>:e!<CR>

]]
  )
end

return M

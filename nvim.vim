set nocompatible

" Add some missing filetype extentions
autocmd BufNewFile,BufRead *.jsx set filetype=javascript.jsx
autocmd BufNewFile,BufRead *.yaml set filetype=yaml
autocmd BufNewFile,BufRead *.j2	  set filetype=jinja

call plug#begin('~/.local/share/nvim/plugged')

" Style
Plug 'chriskempson/base16-vim'

Plug 'nvim-lualine/lualine.nvim'
Plug 'kdheepak/tabline.nvim'
Plug 'kyazdani42/nvim-web-devicons'

Plug 'lambdalisue/suda.vim'
" Text navigation
Plug 'nacitar/terminalkeys.vim'
Plug 'junegunn/vim-easy-align'
"""
Plug 'nvim-treesitter/nvim-treesitter'  " syntax color
Plug 'romainl/vim-cool'                 " auto hlsearch
Plug 'nvim-lua/plenary.nvim'            " Job
Plug 'nvim-telescope/telescope.nvim'    " find <leader>pX
Plug 'folke/trouble.nvim'               " fancy diagnostic
Plug 'jose-elias-alvarez/null-ls.nvim'  " fixer and linter

Plug 'neovim/nvim-lspconfig'
Plug 'ms-jpq/coq_nvim', {'branch': 'coq'}            " complete
Plug 'ms-jpq/coq.artifacts', {'branch': 'artifacts'} " complete

Plug 'preservim/nerdtree'

""""Plug 'tpope/vim-rhubarb'        " GitHub ticket completion
""""Plug 'sileht/vim-linear'       " Linear ticket completion
Plug '~/workspace/sileht/vim-linear/'

"Plug 'tpope/vim-fugitive'
"Plug 'mhinz/vim-signify'
"""
""""Plug 'junegunn/vim-github-dashboard'
Plug 'lifepillar/vim-cheat40'
""""Plug 'github/copilot.vim'

call plug#end()

set encoding=utf8
scriptencoding utf-8
syntax on
filetype plugin indent on
set shell=/bin/sh

"set clipboard=unnamed,unnamedplus
set mouse=
set hidden                      " Allow buffer switching without saving
"set backup                      " Backups are nice ...
set nobackup
set nowritebackup

set undofile                    " So is persistent undo ...
set undolevels=1000             " Maximum number of changes that can be undone
set undoreload=10000            " Maximum number lines to save for undo on a buffer reload
set backspace=indent,eol,start  " Backspace for dummies
set linespace=0                 " No extra spaces between rows
"set number                      " Line numbers on
"set relativenumber              " 0 is current line
set showmatch                   " Show matching brackets/parenthesis
set incsearch                   " Find as you type search
"set hlsearch                    " Highlight search terms
set winminheight=0              " Windows can be 0 line high
"set ignorecase                  " Case insensitive search
set smartcase                   " Case sensitive when uc present
set wildmenu                    " Show list instead of just completing
set wildmode=list:longest,full  " Command <Tab> completion, list matches, then longest common part, then all.
set whichwrap=b,s,h,l,<,>,[,]   " Backspace and cursor keys wrap too
set scrolljump=5                " Lines to scroll when cursor leaves screen
set scrolloff=3                 " Minimum lines to keep above and below cursor
"set list
"set listchars=tab:›\ ,trail:•,extends:#,nbsp:. " Highlight problematic whitespace
set nowrap                      " Do not wrap long lines
set autoindent                  " Indent at the same level of the previous line
set shiftwidth=4                " Use indents of 4 spaces
set expandtab                   " Tabs are spaces, not tabs
set tabstop=4                   " An indentation every four columns
set softtabstop=4               " Let backspace delete indent
set nojoinspaces                " Prevents inserting two spaces after punctuation on a join (J)
set splitright                  " Puts new vsplit windows to the right of the current
set splitbelow                  " Puts new split windows to the bottom of the current
"set matchpairs+=<:>             " Match, to be used with %
set pastetoggle=<F12>           " pastetoggle (sane indentation on pastes)
set nofoldenable                " No fold
set scrolloff=10                " Again no fold
syn spell toplevel              " Spell rst issue https://github.com/Rykka/riv.vim/issues/8
set nohlsearch

set guioptions-=M  "remove menu bar
set guioptions-=m  "remove menu bar
set guioptions-=T  "remove toolbar

set ttimeout
set ttimeoutlen=50

let mapleader = ","
let g:mapleader = ","
let maplocalleader = ";"
let g:maplocalleader = ";"

" http://snk.tuxfamily.org/log/vim-256color-bce.html
" Disable Background Color Erase (BCE) so that color schemes
" work properly when Vim is used inside tmux and GNU screen.
if &term =~ '256color'
  set t_ut=
endif

nnoremap P "0p                            " Paste last yank
nnoremap Y y$                             " Yank from the cursor to the end of the line, to be consistent with C and D.
command! R execute "source ~/.config/nvim/init.vim"

" ###############
" ### ON LOAD ###
" ###############

autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
    \| exe "normal! g'\"" | endif


match ErrorMsg /\s\+$\| \+\ze\t/

" ##############
" ### Themes ###
" ##############
""set t_Co=256            " Enable 256 colors to stop the CSApprox warning and make xterm vim shine
let base16colorspace=256
if filereadable(expand("~/.vimrc_background"))
  source ~/.vimrc_background
else
  colorscheme base16-eighties
endif

set cursorline
set laststatus=2        " Show statusbar
set showtabline=1       " Show tabline

" ##################
" ### LSP CONFIG ###
" ##################

let g:cheat40_use_default = 0
let g:coq_settings = { 'auto_start': 'shut-up', 'clients': {} }
let g:coq_settings.clients.snippets = { 'enabled': v:false }

lua << EOF
local lspconfig = require('lspconfig')
local lspconfig_configs = require('lspconfig.configs')
local coq = require('coq')
local null_ls = require('null-ls')

require('tabline').setup({enable = false})
require('lualine').setup({
  tabline = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { require'tabline'.tabline_buffers },
    lualine_x = { require'tabline'.tabline_tabs },
    lualine_y = {},
    lualine_z = {},
  },
})
require('telescope').setup()
require("trouble").setup({
    auto_open = true,
    auto_close = true,
    use_diagnostic_signs = true,
    auto_preview = true,
})
require('nvim-treesitter.configs').setup({
  ensure_installed = "maintained",
  indent = {
    enable = true,
  },
  incremental_selection = {
    enable = true,
  },
  highlight = {
    additional_vim_regex_highlighting = true,
    enable = true,
  }
})

vim.diagnostic.config({virtual_text = false, sign = false, underline = false,})

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  -- vim.o.completeopt = 'menuone,noselect'

  -- Enable completion triggered by <c-x><c-o>
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { noremap=true, silent=true }

  buf_set_keymap('n', '<F5>', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', '<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)

  if client.resolved_capabilities.document_formatting then
    vim.cmd("autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()")
  end
end

local log_to_message = function(chan_id, data, name)
  for _, d in ipairs(data) do
    print(d);
  end
end

-- html: Enable (broadcasting) snippet capability for completion
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#html
local vscode_lsp_capabilities = vim.lsp.protocol.make_client_capabilities()
vscode_lsp_capabilities.textDocument.completion.completionItem.snippetSupport = true

local lsp_options = {
  common = {
    on_attach = on_attach,
    flags = {
      debounce_text_changes = 150,
    },
  },
  html = {
    capabilities = vscode_lsp_capabilities,
  },
  jsonls = {
    capabilities = vscode_lsp_capabilities,
  },
  eslint = {
    on_attach = function(client, bufnr)
      vim.cmd("autocmd BufWritePre <buffer> :EslintFixAll")
      return on_attach(client, bufnr)
    end
  },
  jedi_language_server = {
    on_new_config = function(new_config, new_root_dir)
      local venv = new_root_dir .. '/.tox/pep8';
      if vim.fn.isdirectory(venv) ~= 0 then
          local venv_jedi_bin = venv .. '/bin/jedi-language-server';
          if vim.fn.filereadable(venv_jedi_bin) == 0 then
            local pip_cmd = venv .. '/bin/pip'
            local full_pip_cmd = pip_cmd .. ' install jedi-language-server'
            vim.fn.jobstart(venv .. '/bin/pip install jedi-language-server', {
                on_stdout = log_to_message,
                on_stderr = log_to_message,
                on_exit = function()
                    for _, client in ipairs(vim.lsp.get_active_clients()) do
                        print(client.name)
                        if (client.name == "jedi_language_server") then
                            client.stop()
                        end
                    end
                    lspconfig_configs.jedi_language_server.launch()
                    --vim.api.nvim_command('LspStop python')
                    --vim.api.nvim_command('LspRestart python')
                end
            })
          else
            new_config.cmd = {venv_jedi_bin};
          end
      end
      return new_config;
    end
  }
}
local servers = { 'vimls', 'eslint', 'bashls', 'stylelint_lsp', 'yamlls', 'jedi_language_server', 'html', 'jsonls', 'taplo', 'yamlls' }
for _, lsp in ipairs(servers) do
  local options = vim.deepcopy(lsp_options.common)
  if (lsp_options[lsp] ~= nil) then
    options = vim.tbl_extend("force", options, lsp_options[lsp])
  end
  lspconfig[lsp].setup(coq.lsp_ensure_capabilities(options))
end

require("null-ls").setup({
    debug = false,
    on_attach = on_attach,
    sources = {
        null_ls.builtins.diagnostics.mypy.with({
           prefer_local = ".tox/pep8/bin",
        }),
        null_ls.builtins.diagnostics.flake8.with({
            prefer_local = ".tox/pep8/bin",
        }),
        null_ls.builtins.formatting.isort.with({
            prefer_local = ".tox/pep8/bin",
        }),
        null_ls.builtins.formatting.black.with({
            prefer_local = ".tox/pep8/bin",
        }),

        null_ls.builtins.diagnostics.yamllint,
        null_ls.builtins.formatting.fixjson,
        null_ls.builtins.formatting.stylelint,
        null_ls.builtins.formatting.eslint_d,
        null_ls.builtins.diagnostics.eslint,
        null_ls.builtins.diagnostics.vale,
        null_ls.builtins.diagnostics.yamllint,
        null_ls.builtins.diagnostics.shellcheck,

        null_ls.builtins.code_actions.eslint_d,
        null_ls.builtins.code_actions.refactoring,
        null_ls.builtins.code_actions.gitsigns,
        null_ls.builtins.code_actions.shellcheck,
        null_ls.builtins.code_actions.gitrebase,

        null_ls.builtins.formatting.trim_whitespace,
        null_ls.builtins.formatting.trim_newlines,
        null_ls.builtins.hover.dictionary,
    },
})

EOF

nnoremap <silent> <leader>e :NERDTreeToggle<CR>

nnoremap <Leader>fp <cmd>lua require('telescope.builtin').builtin()<cr>
nnoremap <Leader>fc <cmd>lua require('telescope.builtin').git_commits()<cr>
nnoremap <leader>fs <cmd>lua require('telescope.builtin').lsp_document_symbols()<cr>
nnoremap <leader>ff <cmd>lua require('telescope.builtin').find_files()<cr>
nnoremap <leader>fg <cmd>lua require('telescope.builtin').live_grep()<cr>
nnoremap <leader>fb <cmd>lua require('telescope.builtin').buffers()<cr>
nnoremap <leader>fh <cmd>lua require('telescope.builtin').help_tags()<cr>

nmap <S-left>  :TablineBufferPrevious<Enter>
nmap <S-right> :TablineBufferNext<Enter>

" ##################
" ### EASY ALIGN ###
" ##################

xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)

" #####################
" ### OTHER PLUGINS ###
" #####################

cmap w!! :w suda://%<CR>:e!<CR>

source ~/.creds.vimrc
"let g:LINEAR_STATE_IDS = ["22f2b6eb-f794-4cc7-8212-ad0094d16a2a"]
"let g:LINEAR_STATE_IDS = ["cdd327d2-7875-4636-ba9d-adccf335d888"]

let g:github_dashboard = { 'username': 'sileht', 'password': g:GITHUB_TOKEN }

function! MyOmni(findstart, base) abort
    let s:linear_items = linear#Complete(a:findstart, a:base)
    return s:linear_items
    "let s:gh_items = rhubarb#Complete(a:findstart, a:base)
    return s:linear_items + s:gh_items
endfunction
autocmd FileType gitcommit setlocal omnifunc=MyOmni

" #########################
" ### VARIOUS FUNCTIONS ###
" #########################
function! InitializeDirectories()
    let parent = $HOME
    let prefix = 'vim'
    let dir_list = {'backup': 'backupdir','views': 'viewdir', 'swap': 'directory' }
    let common_dir = parent . '/.' . prefix

    for [dirname, settingname] in items(dir_list)
        let directory = common_dir . dirname . '/'
        if exists("*mkdir")
            if !isdirectory(directory)
                call mkdir(directory)
            endif
        endif
        if !isdirectory(directory)
            echo "Warning: Unable to create backup directory: " . directory
            echo "Try: mkdir -p " . directory
        else
            let directory = substitute(directory, " ", "\\\\ ", "g")
            exec "set " . settingname . "=" . directory
        endif
    endfor
endfunction
call InitializeDirectories()

function! SetProjectRoot()
  let current_file_dir = expand("%:p:h")
  if empty(current_file_dir) || !isdirectory(current_file_dir)
      return
  endif
  exe "lcd " . current_file_dir
endfunction

" follow symlink and set working directory
autocmd BufEnter * call SetProjectRoot()


packloadall
silent! helptags ALL

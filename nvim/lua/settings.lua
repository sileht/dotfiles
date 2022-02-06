


vim.opt.termguicolors = true
vim.opt.shell = "/bin/sh"
vim.opt.cursorline = true
vim.opt.laststatus = 2                    -- Show statusbar
vim.opt.mouse = ""
vim.opt.hidden = true                     -- Allow buffer switching without saving
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.undofile = true                   -- So is persistent undo ...
vim.opt.undolevels = 1000                 -- Maximum number of changes that can be undone
vim.opt.undoreload = 10000                -- Maximum number lines to save for undo on a buffer reload
vim.opt.backspace = "indent,eol,start"    -- Backspace for dummies
vim.opt.linespace = 0                     -- No extra spaces between rows
vim.opt.number = true                     -- Line numbers on
vim.opt.relativenumber = true             -- 0 is current line
vim.opt.showmatch = true                  -- Show matching brackets/parenthesis
vim.opt.incsearch = true                  -- Find as you type search
vim.opt.winminheight = 0                  -- Windows can be 0 line high
vim.opt.smartcase = true                  -- Case sensitive when uc present
vim.opt.wildmenu = true                   -- Show list instead of just completing
vim.opt.wildmode = "list:longest,full"    -- Command <Tab> completion, list matches, then longest common part, then all.
vim.opt.whichwrap = "b,s,h,l,<,>,[,]"     -- Backspace and cursor keys wrap too
vim.opt.scrolljump = 5                    -- Lines to scroll when cursor leaves screen
vim.opt.scrolloff = 3                     -- Minimum lines to keep above and below cursor
-- vim.opt.clipboard = unnamed,unnamedplus
-- vim.opt.list
-- vim.opt.listchars = "tab:›\ ,trail:•,extends:#,nbsp:." -- Highlight problematic whitespace
vim.opt.wrap = false                      -- Do not wrap long lines
vim.opt.autoindent = true                 -- Indent at the same level of the previous line
vim.opt.smartindent = true
vim.opt.shiftwidth = 4                    -- Use indents of 4 spaces
vim.opt.expandtab = true                  -- Tabs are spaces, not tabs
vim.opt.tabstop = 4                       -- An indentation every four columns
vim.opt.softtabstop = 4                   -- Let backspace delete indent
vim.opt.joinspaces = false                -- Prevents inserting two spaces after punctuation on a join (J)
vim.opt.splitright = true                 -- Puts new vsplit windows to the right of the current
vim.opt.splitbelow = true                 -- Puts new split windows to the bottom of the current
-- vim.opt.matchpairs+ = "<:>"              -- Match, to be used with %
vim.opt.pastetoggle = "<F12>"             -- pastetoggle (sane indentation on pastes)
vim.opt.foldenable = false                -- No fold
vim.opt.foldmethod = "manual"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"

vim.opt.linebreak = true                  --  Don't word wrap in the middle of words
vim.opt.breakindent = true                -- Keep indentation aligned when line wrapping


vim.opt.scrolloff = 10                    -- Again no fold
vim.opt.spelllang = "en,fr"
vim.opt.spellsuggest = "best,9"

-- vim.opt.ttimeout = true
-- vim.opt.ttimeoutlen = 50

vim.opt.completeopt = "menu,menuone,noselect"

vim.g.mapleader = ","
vim.g.maplocalleader = ";"

vim.opt.updatetime = 1500

-- Highlight on yank
vim.cmd [[
  augroup YankHighlight
    autocmd!
    autocmd TextYankPost * silent! lua vim.highlight.on_yank()
  augroup end
]]

-- Restore cursor position
vim.cmd([[autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
    \| exe "normal! g'\"" | endif]])

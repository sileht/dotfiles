-- Automatically generated packer.nvim plugin loader code

if vim.api.nvim_call_function('has', {'nvim-0.5'}) ~= 1 then
  vim.api.nvim_command('echohl WarningMsg | echom "Invalid Neovim version for packer.nvim! | echohl None"')
  return
end

vim.api.nvim_command('packadd packer.nvim')

local no_errors, error_msg = pcall(function()

  local time
  local profile_info
  local should_profile = false
  if should_profile then
    local hrtime = vim.loop.hrtime
    profile_info = {}
    time = function(chunk, start)
      if start then
        profile_info[chunk] = hrtime()
      else
        profile_info[chunk] = (hrtime() - profile_info[chunk]) / 1e6
      end
    end
  else
    time = function(chunk, start) end
  end
  
local function save_profiles(threshold)
  local sorted_times = {}
  for chunk_name, time_taken in pairs(profile_info) do
    sorted_times[#sorted_times + 1] = {chunk_name, time_taken}
  end
  table.sort(sorted_times, function(a, b) return a[2] > b[2] end)
  local results = {}
  for i, elem in ipairs(sorted_times) do
    if not threshold or threshold and elem[2] > threshold then
      results[i] = elem[1] .. ' took ' .. elem[2] .. 'ms'
    end
  end

  _G._packer = _G._packer or {}
  _G._packer.profile_output = results
end

time([[Luarocks path setup]], true)
local package_path_str = "/home/sileht/.cache/nvim/packer_hererocks/2.0.5/share/lua/5.1/?.lua;/home/sileht/.cache/nvim/packer_hererocks/2.0.5/share/lua/5.1/?/init.lua;/home/sileht/.cache/nvim/packer_hererocks/2.0.5/lib/luarocks/rocks-5.1/?.lua;/home/sileht/.cache/nvim/packer_hererocks/2.0.5/lib/luarocks/rocks-5.1/?/init.lua"
local install_cpath_pattern = "/home/sileht/.cache/nvim/packer_hererocks/2.0.5/lib/lua/5.1/?.so"
if not string.find(package.path, package_path_str, 1, true) then
  package.path = package.path .. ';' .. package_path_str
end

if not string.find(package.cpath, install_cpath_pattern, 1, true) then
  package.cpath = package.cpath .. ';' .. install_cpath_pattern
end

time([[Luarocks path setup]], false)
time([[try_loadstring definition]], true)
local function try_loadstring(s, component, name)
  local success, result = pcall(loadstring(s), name, _G.packer_plugins[name])
  if not success then
    vim.schedule(function()
      vim.api.nvim_notify('packer.nvim: Error running ' .. component .. ' for ' .. name .. ': ' .. result, vim.log.levels.ERROR, {})
    end)
  end
  return result
end

time([[try_loadstring definition]], false)
time([[Defining packer_plugins]], true)
_G.packer_plugins = {
  ["base16-vim"] = {
    config = { "\27LJ\1\2”\2\0\0\3\0\v\1\0294\0\0\0007\0\1\0'\1\0\1:\1\2\0004\0\0\0007\0\3\0007\0\4\0004\1\0\0007\1\3\0017\1\5\1%\2\6\0>\1\2\0=\0\0\2\b\0\0\0T\0\5€4\0\0\0007\0\a\0%\1\b\0>\0\2\1T\0\4€4\0\0\0007\0\a\0%\1\t\0>\0\2\0014\0\0\0007\0\a\0%\1\n\0>\0\2\1G\0\1\0\31hi cursorlinenr cterm=none colorscheme base16-eighties\31source ~/.vimrc_background\bcmd\24~/.vimrc_background\vexpand\17filereadable\afn\21base16colorspace\6g\bvim\0\0" },
    loaded = true,
    path = "/home/sileht/.local/share/nvim/site/pack/packer/start/base16-vim",
    url = "https://github.com/chriskempson/base16-vim"
  },
  ["cmp-buffer"] = {
    loaded = true,
    path = "/home/sileht/.local/share/nvim/site/pack/packer/start/cmp-buffer",
    url = "https://github.com/hrsh7th/cmp-buffer"
  },
  ["cmp-cmdline"] = {
    loaded = true,
    path = "/home/sileht/.local/share/nvim/site/pack/packer/start/cmp-cmdline",
    url = "https://github.com/hrsh7th/cmp-cmdline"
  },
  ["cmp-nvim-lsp"] = {
    loaded = true,
    path = "/home/sileht/.local/share/nvim/site/pack/packer/start/cmp-nvim-lsp",
    url = "https://github.com/hrsh7th/cmp-nvim-lsp"
  },
  ["cmp-path"] = {
    loaded = true,
    path = "/home/sileht/.local/share/nvim/site/pack/packer/start/cmp-path",
    url = "https://github.com/hrsh7th/cmp-path"
  },
  ["gitsigns.nvim"] = {
    config = { "\27LJ\1\0026\0\0\2\0\3\0\0064\0\0\0%\1\1\0>\0\2\0027\0\2\0>\0\1\1G\0\1\0\nsetup\rgitsigns\frequire\0" },
    loaded = true,
    path = "/home/sileht/.local/share/nvim/site/pack/packer/start/gitsigns.nvim",
    url = "https://github.com/lewis6991/gitsigns.nvim"
  },
  ["lsp-colors.nvim"] = {
    loaded = true,
    path = "/home/sileht/.local/share/nvim/site/pack/packer/start/lsp-colors.nvim",
    url = "https://github.com/folke/lsp-colors.nvim"
  },
  ["lualine.nvim"] = {
    loaded = true,
    path = "/home/sileht/.local/share/nvim/site/pack/packer/start/lualine.nvim",
    url = "https://github.com/nvim-lualine/lualine.nvim"
  },
  nerdtree = {
    loaded = true,
    path = "/home/sileht/.local/share/nvim/site/pack/packer/start/nerdtree",
    url = "https://github.com/preservim/nerdtree"
  },
  ["null-ls.nvim"] = {
    loaded = true,
    path = "/home/sileht/.local/share/nvim/site/pack/packer/start/null-ls.nvim",
    url = "https://github.com/jose-elias-alvarez/null-ls.nvim"
  },
  ["nvim-cmp"] = {
    loaded = true,
    path = "/home/sileht/.local/share/nvim/site/pack/packer/start/nvim-cmp",
    url = "https://github.com/hrsh7th/nvim-cmp"
  },
  ["nvim-lspconfig"] = {
    config = { "\27LJ\1\2›\3\0\0\b\0\21\00044\0\0\0%\1\1\0>\0\2\0014\0\0\0%\1\2\0>\0\2\0014\0\0\0%\1\3\0>\0\2\0027\1\4\0003\2\f\0007\3\5\0007\3\6\0032\4\6\0003\5\a\0;\5\1\0043\5\b\0;\5\2\0043\5\t\0;\5\3\0043\5\n\0;\5\4\0043\5\v\0;\5\5\4>\3\2\2:\3\6\2>\1\2\0017\1\4\0007\1\r\1%\2\14\0003\3\16\0002\4\3\0003\5\15\0;\5\1\4:\4\6\3>\1\3\0017\1\4\0007\1\r\1%\2\17\0003\3\20\0007\4\5\0007\4\6\0042\5\3\0003\6\18\0;\6\1\0052\6\3\0003\a\19\0;\a\1\6>\4\3\2:\4\6\3>\1\3\1G\0\1\0\1\0\0\1\0\1\tname\fcmdline\1\0\1\tname\tpath\6:\1\0\0\1\0\1\tname\vbuffer\6/\fcmdline\1\0\0\1\0\1\tname\fcmdline\1\0\1\tname\vlinear\1\0\1\tname\tpath\1\0\1\tname\vbuffer\1\0\1\tname\rnvim_lsp\fsources\vconfig\nsetup\bcmp\22linear_cmp_source\blsp\frequire\0" },
    loaded = true,
    path = "/home/sileht/.local/share/nvim/site/pack/packer/start/nvim-lspconfig",
    url = "https://github.com/neovim/nvim-lspconfig"
  },
  ["nvim-scrollview"] = {
    loaded = true,
    path = "/home/sileht/.local/share/nvim/site/pack/packer/start/nvim-scrollview",
    url = "https://github.com/dstein64/nvim-scrollview"
  },
  ["nvim-treesitter"] = {
    config = { "\27LJ\1\2†\2\0\0\4\0\f\0\0154\0\0\0%\1\1\0>\0\2\0027\0\2\0003\1\3\0003\2\4\0003\3\5\0:\3\6\2:\2\a\0013\2\b\0:\2\t\0013\2\n\0:\2\v\1>\0\2\1G\0\1\0\14highlight\1\0\2&additional_vim_regex_highlighting\2\venable\2\26incremental_selection\1\0\1\venable\2\vindent\fdisable\1\2\0\0\vpython\1\0\1\venable\2\1\0\1\21ensure_installed\15maintained\nsetup\28nvim-treesitter.configs\frequire\0" },
    loaded = true,
    path = "/home/sileht/.local/share/nvim/site/pack/packer/start/nvim-treesitter",
    url = "https://github.com/nvim-treesitter/nvim-treesitter"
  },
  ["nvim-treesitter-textobjects"] = {
    loaded = true,
    path = "/home/sileht/.local/share/nvim/site/pack/packer/start/nvim-treesitter-textobjects",
    url = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects"
  },
  ["nvim-web-devicons"] = {
    loaded = true,
    path = "/home/sileht/.local/share/nvim/site/pack/packer/start/nvim-web-devicons",
    url = "https://github.com/kyazdani42/nvim-web-devicons"
  },
  ["packer.nvim"] = {
    loaded = true,
    path = "/home/sileht/.local/share/nvim/site/pack/packer/start/packer.nvim",
    url = "https://github.com/wbthomason/packer.nvim"
  },
  ["plenary.nvim"] = {
    loaded = true,
    path = "/home/sileht/.local/share/nvim/site/pack/packer/start/plenary.nvim",
    url = "https://github.com/nvim-lua/plenary.nvim"
  },
  ["spellsitter.nvim"] = {
    config = { "\27LJ\1\0029\0\0\2\0\3\0\0064\0\0\0%\1\1\0>\0\2\0027\0\2\0>\0\1\1G\0\1\0\nsetup\16spellsitter\frequire\0" },
    loaded = true,
    path = "/home/sileht/.local/share/nvim/site/pack/packer/start/spellsitter.nvim",
    url = "https://github.com/lewis6991/spellsitter.nvim"
  },
  ["stabilize.nvim"] = {
    config = { "\27LJ\1\0027\0\0\2\0\3\0\0064\0\0\0%\1\1\0>\0\2\0027\0\2\0>\0\1\1G\0\1\0\nsetup\14stabilize\frequire\0" },
    loaded = true,
    path = "/home/sileht/.local/share/nvim/site/pack/packer/start/stabilize.nvim",
    url = "https://github.com/luukvbaal/stabilize.nvim"
  },
  ["suda.vim"] = {
    loaded = true,
    path = "/home/sileht/.local/share/nvim/site/pack/packer/start/suda.vim",
    url = "https://github.com/lambdalisue/suda.vim"
  },
  ["tabline.nvim"] = {
    config = { "\27LJ\1\2ã\3\0\0\6\0\24\00034\0\0\0%\1\1\0>\0\2\0027\0\2\0003\1\3\0>\0\2\0014\0\0\0%\1\4\0>\0\2\0027\0\2\0003\1\n\0003\2\b\0002\3\3\0004\4\0\0%\5\1\0>\4\2\0027\4\5\4;\4\1\0034\4\0\0%\5\6\0>\4\2\0027\4\a\4;\4\2\3:\3\t\2:\2\v\0013\2\r\0003\3\f\0:\3\14\0023\3\15\0:\3\16\0022\3\3\0004\4\0\0%\5\1\0>\4\2\0027\4\5\4;\4\1\0034\4\0\0%\5\6\0>\4\2\0027\4\a\4;\4\2\3:\3\t\0023\3\17\0:\3\18\0023\3\19\0:\3\20\0023\3\21\0:\3\22\2:\2\23\1>\0\2\1G\0\1\0\22inactive_sections\14lualine_z\1\2\0\0\rlocation\14lualine_y\1\2\0\0\rprogress\14lualine_x\1\4\0\0\rencoding\15fileformat\rfiletype\14lualine_b\1\4\0\0\vbranch\tdiff\16diagnostics\14lualine_a\1\0\0\1\2\0\0\tmode\rsections\1\0\0\14lualine_c\1\0\0\vstatus\20tricks_and_tips\20tabline_buffers\flualine\1\0\1\venable\1\nsetup\ftabline\frequire\0" },
    loaded = true,
    path = "/home/sileht/.local/share/nvim/site/pack/packer/start/tabline.nvim",
    url = "https://github.com/kdheepak/tabline.nvim"
  },
  ["telescope.nvim"] = {
    config = { "\27LJ\1\0027\0\0\2\0\3\0\0064\0\0\0%\1\1\0>\0\2\0027\0\2\0>\0\1\1G\0\1\0\nsetup\14telescope\frequire\0" },
    loaded = true,
    path = "/home/sileht/.local/share/nvim/site/pack/packer/start/telescope.nvim",
    url = "https://github.com/nvim-telescope/telescope.nvim"
  },
  ["terminalkeys.vim"] = {
    loaded = true,
    path = "/home/sileht/.local/share/nvim/site/pack/packer/start/terminalkeys.vim",
    url = "https://github.com/nacitar/terminalkeys.vim"
  },
  ["trouble.nvim"] = {
    config = { "\27LJ\1\2ª\1\0\0\2\0\4\0\a4\0\0\0%\1\1\0>\0\2\0027\0\2\0003\1\3\0>\0\2\1G\0\1\0\1\0\b\14auto_open\2\25use_diagnostic_signs\2\vheight\3\6\15auto_close\2\ngroup\1\17indent_lines\1\tmode\25document_diagnostics\fpadding\1\nsetup\ftrouble\frequire\0" },
    loaded = true,
    path = "/home/sileht/.local/share/nvim/site/pack/packer/start/trouble.nvim",
    url = "https://github.com/folke/trouble.nvim"
  },
  ["vim-cool"] = {
    loaded = true,
    path = "/home/sileht/.local/share/nvim/site/pack/packer/start/vim-cool",
    url = "https://github.com/romainl/vim-cool"
  },
  ["vim-easy-align"] = {
    loaded = true,
    path = "/home/sileht/.local/share/nvim/site/pack/packer/start/vim-easy-align",
    url = "https://github.com/junegunn/vim-easy-align"
  }
}

time([[Defining packer_plugins]], false)
-- Config for: nvim-lspconfig
time([[Config for nvim-lspconfig]], true)
try_loadstring("\27LJ\1\2›\3\0\0\b\0\21\00044\0\0\0%\1\1\0>\0\2\0014\0\0\0%\1\2\0>\0\2\0014\0\0\0%\1\3\0>\0\2\0027\1\4\0003\2\f\0007\3\5\0007\3\6\0032\4\6\0003\5\a\0;\5\1\0043\5\b\0;\5\2\0043\5\t\0;\5\3\0043\5\n\0;\5\4\0043\5\v\0;\5\5\4>\3\2\2:\3\6\2>\1\2\0017\1\4\0007\1\r\1%\2\14\0003\3\16\0002\4\3\0003\5\15\0;\5\1\4:\4\6\3>\1\3\0017\1\4\0007\1\r\1%\2\17\0003\3\20\0007\4\5\0007\4\6\0042\5\3\0003\6\18\0;\6\1\0052\6\3\0003\a\19\0;\a\1\6>\4\3\2:\4\6\3>\1\3\1G\0\1\0\1\0\0\1\0\1\tname\fcmdline\1\0\1\tname\tpath\6:\1\0\0\1\0\1\tname\vbuffer\6/\fcmdline\1\0\0\1\0\1\tname\fcmdline\1\0\1\tname\vlinear\1\0\1\tname\tpath\1\0\1\tname\vbuffer\1\0\1\tname\rnvim_lsp\fsources\vconfig\nsetup\bcmp\22linear_cmp_source\blsp\frequire\0", "config", "nvim-lspconfig")
time([[Config for nvim-lspconfig]], false)
-- Config for: tabline.nvim
time([[Config for tabline.nvim]], true)
try_loadstring("\27LJ\1\2ã\3\0\0\6\0\24\00034\0\0\0%\1\1\0>\0\2\0027\0\2\0003\1\3\0>\0\2\0014\0\0\0%\1\4\0>\0\2\0027\0\2\0003\1\n\0003\2\b\0002\3\3\0004\4\0\0%\5\1\0>\4\2\0027\4\5\4;\4\1\0034\4\0\0%\5\6\0>\4\2\0027\4\a\4;\4\2\3:\3\t\2:\2\v\0013\2\r\0003\3\f\0:\3\14\0023\3\15\0:\3\16\0022\3\3\0004\4\0\0%\5\1\0>\4\2\0027\4\5\4;\4\1\0034\4\0\0%\5\6\0>\4\2\0027\4\a\4;\4\2\3:\3\t\0023\3\17\0:\3\18\0023\3\19\0:\3\20\0023\3\21\0:\3\22\2:\2\23\1>\0\2\1G\0\1\0\22inactive_sections\14lualine_z\1\2\0\0\rlocation\14lualine_y\1\2\0\0\rprogress\14lualine_x\1\4\0\0\rencoding\15fileformat\rfiletype\14lualine_b\1\4\0\0\vbranch\tdiff\16diagnostics\14lualine_a\1\0\0\1\2\0\0\tmode\rsections\1\0\0\14lualine_c\1\0\0\vstatus\20tricks_and_tips\20tabline_buffers\flualine\1\0\1\venable\1\nsetup\ftabline\frequire\0", "config", "tabline.nvim")
time([[Config for tabline.nvim]], false)
-- Config for: base16-vim
time([[Config for base16-vim]], true)
try_loadstring("\27LJ\1\2”\2\0\0\3\0\v\1\0294\0\0\0007\0\1\0'\1\0\1:\1\2\0004\0\0\0007\0\3\0007\0\4\0004\1\0\0007\1\3\0017\1\5\1%\2\6\0>\1\2\0=\0\0\2\b\0\0\0T\0\5€4\0\0\0007\0\a\0%\1\b\0>\0\2\1T\0\4€4\0\0\0007\0\a\0%\1\t\0>\0\2\0014\0\0\0007\0\a\0%\1\n\0>\0\2\1G\0\1\0\31hi cursorlinenr cterm=none colorscheme base16-eighties\31source ~/.vimrc_background\bcmd\24~/.vimrc_background\vexpand\17filereadable\afn\21base16colorspace\6g\bvim\0\0", "config", "base16-vim")
time([[Config for base16-vim]], false)
-- Config for: spellsitter.nvim
time([[Config for spellsitter.nvim]], true)
try_loadstring("\27LJ\1\0029\0\0\2\0\3\0\0064\0\0\0%\1\1\0>\0\2\0027\0\2\0>\0\1\1G\0\1\0\nsetup\16spellsitter\frequire\0", "config", "spellsitter.nvim")
time([[Config for spellsitter.nvim]], false)
-- Config for: trouble.nvim
time([[Config for trouble.nvim]], true)
try_loadstring("\27LJ\1\2ª\1\0\0\2\0\4\0\a4\0\0\0%\1\1\0>\0\2\0027\0\2\0003\1\3\0>\0\2\1G\0\1\0\1\0\b\14auto_open\2\25use_diagnostic_signs\2\vheight\3\6\15auto_close\2\ngroup\1\17indent_lines\1\tmode\25document_diagnostics\fpadding\1\nsetup\ftrouble\frequire\0", "config", "trouble.nvim")
time([[Config for trouble.nvim]], false)
-- Config for: gitsigns.nvim
time([[Config for gitsigns.nvim]], true)
try_loadstring("\27LJ\1\0026\0\0\2\0\3\0\0064\0\0\0%\1\1\0>\0\2\0027\0\2\0>\0\1\1G\0\1\0\nsetup\rgitsigns\frequire\0", "config", "gitsigns.nvim")
time([[Config for gitsigns.nvim]], false)
-- Config for: stabilize.nvim
time([[Config for stabilize.nvim]], true)
try_loadstring("\27LJ\1\0027\0\0\2\0\3\0\0064\0\0\0%\1\1\0>\0\2\0027\0\2\0>\0\1\1G\0\1\0\nsetup\14stabilize\frequire\0", "config", "stabilize.nvim")
time([[Config for stabilize.nvim]], false)
-- Config for: telescope.nvim
time([[Config for telescope.nvim]], true)
try_loadstring("\27LJ\1\0027\0\0\2\0\3\0\0064\0\0\0%\1\1\0>\0\2\0027\0\2\0>\0\1\1G\0\1\0\nsetup\14telescope\frequire\0", "config", "telescope.nvim")
time([[Config for telescope.nvim]], false)
-- Config for: nvim-treesitter
time([[Config for nvim-treesitter]], true)
try_loadstring("\27LJ\1\2†\2\0\0\4\0\f\0\0154\0\0\0%\1\1\0>\0\2\0027\0\2\0003\1\3\0003\2\4\0003\3\5\0:\3\6\2:\2\a\0013\2\b\0:\2\t\0013\2\n\0:\2\v\1>\0\2\1G\0\1\0\14highlight\1\0\2&additional_vim_regex_highlighting\2\venable\2\26incremental_selection\1\0\1\venable\2\vindent\fdisable\1\2\0\0\vpython\1\0\1\venable\2\1\0\1\21ensure_installed\15maintained\nsetup\28nvim-treesitter.configs\frequire\0", "config", "nvim-treesitter")
time([[Config for nvim-treesitter]], false)
if should_profile then save_profiles() end

end)

if not no_errors then
  vim.api.nvim_command('echohl ErrorMsg | echom "Error in packer_compiled: '..error_msg..'" | echom "Please check your config for correctness" | echohl None')
end

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
    config = { "\27LJ\1\2é\1\0\0\3\0\n\1\0254\0\0\0007\0\1\0'\1\0\1:\1\2\0004\0\0\0007\0\3\0007\0\4\0004\1\0\0007\1\3\0017\1\5\1%\2\6\0>\1\2\0=\0\0\2\b\0\0\0T\0\5€4\0\0\0007\0\a\0%\1\b\0>\0\2\1T\0\4€4\0\0\0007\0\a\0%\1\t\0>\0\2\1G\0\1\0 colorscheme base16-eighties\31source ~/.vimrc_background\bcmd\24~/.vimrc_background\vexpand\17filereadable\afn\21base16colorspace\6g\bvim\0\0" },
    loaded = true,
    path = "/home/sileht/.local/share/nvim/site/pack/packer/start/base16-vim",
    url = "https://github.com/chriskempson/base16-vim"
  },
  ["coq.artifacts"] = {
    loaded = true,
    path = "/home/sileht/.local/share/nvim/site/pack/packer/start/coq.artifacts",
    url = "https://github.com/ms-jpq/coq.artifacts"
  },
  ["coq.thirdparty"] = {
    config = { "\27LJ\1\2\1\0\0\3\0\4\0\n4\0\0\0%\1\1\0>\0\2\0022\1\3\0003\2\2\0;\2\1\0013\2\3\0;\2\2\1>\0\2\1G\0\1\0\1\0\3\bsrc\fcopilot\15short_name\bCOP\19tmp_accept_key\n<c-r>\1\0\2\bsrc\fnvimlua\15short_name\tnLUA\vcoq_3p\frequire\0" },
    loaded = true,
    path = "/home/sileht/.local/share/nvim/site/pack/packer/start/coq.thirdparty",
    url = "https://github.com/ms-jpq/coq.thirdparty"
  },
  coq_nvim = {
    loaded = true,
    path = "/home/sileht/.local/share/nvim/site/pack/packer/start/coq_nvim",
    url = "https://github.com/ms-jpq/coq_nvim"
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
    config = { "\27LJ\1\2À\3\0\0\6\0\23\0-4\0\0\0%\1\1\0>\0\2\0027\0\2\0003\1\t\0003\2\a\0002\3\3\0004\4\0\0%\5\3\0>\4\2\0027\4\4\4;\4\1\0034\4\0\0%\5\5\0>\4\2\0027\4\6\4;\4\2\3:\3\b\2:\2\n\0013\2\f\0003\3\v\0:\3\r\0023\3\14\0:\3\15\0022\3\3\0004\4\0\0%\5\3\0>\4\2\0027\4\4\4;\4\1\0034\4\0\0%\5\5\0>\4\2\0027\4\6\4;\4\2\3:\3\b\0023\3\16\0:\3\17\0023\3\18\0:\3\19\0023\3\20\0:\3\21\2:\2\22\1>\0\2\1G\0\1\0\22inactive_sections\14lualine_z\1\2\0\0\rlocation\14lualine_y\1\2\0\0\rprogress\14lualine_x\1\4\0\0\rencoding\15fileformat\rfiletype\14lualine_b\1\4\0\0\vbranch\tdiff\16diagnostics\14lualine_a\1\0\0\1\2\0\0\tmode\rsections\1\0\0\14lualine_c\1\0\0\vstatus\20tricks_and_tips\20tabline_buffers\ftabline\nsetup\flualine\frequire\0" },
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
  ["nvim-lspconfig"] = {
    config = { "\27LJ\1\2#\0\0\2\0\2\0\0044\0\0\0%\1\1\0>\0\2\1G\0\1\0\blsp\frequire\0" },
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
  ["suda.vim"] = {
    loaded = true,
    path = "/home/sileht/.local/share/nvim/site/pack/packer/start/suda.vim",
    url = "https://github.com/lambdalisue/suda.vim"
  },
  ["tabline.nvim"] = {
    config = { "\27LJ\1\2D\0\0\2\0\4\0\a4\0\0\0%\1\1\0>\0\2\0027\0\2\0003\1\3\0>\0\2\1G\0\1\0\1\0\1\venable\1\nsetup\ftabline\frequire\0" },
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
    config = { "\27LJ\1\2è\1\0\0\2\0\b\0\f4\0\0\0007\0\1\0007\0\2\0003\1\3\0>\0\2\0014\0\4\0%\1\5\0>\0\2\0027\0\6\0003\1\a\0>\0\2\1G\0\1\0\1\0\a\14auto_open\2\25use_diagnostic_signs\2\vheight\3\6\15auto_close\2\ngroup\1\tmode\25document_diagnostics\fpadding\1\nsetup\ftrouble\frequire\1\0\3\17virtual_text\2\14underline\1\tsign\2\vconfig\15diagnostic\bvim\0" },
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
  },
  ["vim-linear"] = {
    loaded = true,
    path = "/home/sileht/.local/share/nvim/site/pack/packer/start/vim-linear",
    url = "/home/sileht/workspace/sileht/vim-linear/"
  },
  ["vim-smoothie"] = {
    loaded = true,
    path = "/home/sileht/.local/share/nvim/site/pack/packer/start/vim-smoothie",
    url = "https://github.com/psliwka/vim-smoothie"
  }
}

time([[Defining packer_plugins]], false)
-- Config for: nvim-lspconfig
time([[Config for nvim-lspconfig]], true)
try_loadstring("\27LJ\1\2#\0\0\2\0\2\0\0044\0\0\0%\1\1\0>\0\2\1G\0\1\0\blsp\frequire\0", "config", "nvim-lspconfig")
time([[Config for nvim-lspconfig]], false)
-- Config for: tabline.nvim
time([[Config for tabline.nvim]], true)
try_loadstring("\27LJ\1\2D\0\0\2\0\4\0\a4\0\0\0%\1\1\0>\0\2\0027\0\2\0003\1\3\0>\0\2\1G\0\1\0\1\0\1\venable\1\nsetup\ftabline\frequire\0", "config", "tabline.nvim")
time([[Config for tabline.nvim]], false)
-- Config for: base16-vim
time([[Config for base16-vim]], true)
try_loadstring("\27LJ\1\2é\1\0\0\3\0\n\1\0254\0\0\0007\0\1\0'\1\0\1:\1\2\0004\0\0\0007\0\3\0007\0\4\0004\1\0\0007\1\3\0017\1\5\1%\2\6\0>\1\2\0=\0\0\2\b\0\0\0T\0\5€4\0\0\0007\0\a\0%\1\b\0>\0\2\1T\0\4€4\0\0\0007\0\a\0%\1\t\0>\0\2\1G\0\1\0 colorscheme base16-eighties\31source ~/.vimrc_background\bcmd\24~/.vimrc_background\vexpand\17filereadable\afn\21base16colorspace\6g\bvim\0\0", "config", "base16-vim")
time([[Config for base16-vim]], false)
-- Config for: spellsitter.nvim
time([[Config for spellsitter.nvim]], true)
try_loadstring("\27LJ\1\0029\0\0\2\0\3\0\0064\0\0\0%\1\1\0>\0\2\0027\0\2\0>\0\1\1G\0\1\0\nsetup\16spellsitter\frequire\0", "config", "spellsitter.nvim")
time([[Config for spellsitter.nvim]], false)
-- Config for: trouble.nvim
time([[Config for trouble.nvim]], true)
try_loadstring("\27LJ\1\2è\1\0\0\2\0\b\0\f4\0\0\0007\0\1\0007\0\2\0003\1\3\0>\0\2\0014\0\4\0%\1\5\0>\0\2\0027\0\6\0003\1\a\0>\0\2\1G\0\1\0\1\0\a\14auto_open\2\25use_diagnostic_signs\2\vheight\3\6\15auto_close\2\ngroup\1\tmode\25document_diagnostics\fpadding\1\nsetup\ftrouble\frequire\1\0\3\17virtual_text\2\14underline\1\tsign\2\vconfig\15diagnostic\bvim\0", "config", "trouble.nvim")
time([[Config for trouble.nvim]], false)
-- Config for: lualine.nvim
time([[Config for lualine.nvim]], true)
try_loadstring("\27LJ\1\2À\3\0\0\6\0\23\0-4\0\0\0%\1\1\0>\0\2\0027\0\2\0003\1\t\0003\2\a\0002\3\3\0004\4\0\0%\5\3\0>\4\2\0027\4\4\4;\4\1\0034\4\0\0%\5\5\0>\4\2\0027\4\6\4;\4\2\3:\3\b\2:\2\n\0013\2\f\0003\3\v\0:\3\r\0023\3\14\0:\3\15\0022\3\3\0004\4\0\0%\5\3\0>\4\2\0027\4\4\4;\4\1\0034\4\0\0%\5\5\0>\4\2\0027\4\6\4;\4\2\3:\3\b\0023\3\16\0:\3\17\0023\3\18\0:\3\19\0023\3\20\0:\3\21\2:\2\22\1>\0\2\1G\0\1\0\22inactive_sections\14lualine_z\1\2\0\0\rlocation\14lualine_y\1\2\0\0\rprogress\14lualine_x\1\4\0\0\rencoding\15fileformat\rfiletype\14lualine_b\1\4\0\0\vbranch\tdiff\16diagnostics\14lualine_a\1\0\0\1\2\0\0\tmode\rsections\1\0\0\14lualine_c\1\0\0\vstatus\20tricks_and_tips\20tabline_buffers\ftabline\nsetup\flualine\frequire\0", "config", "lualine.nvim")
time([[Config for lualine.nvim]], false)
-- Config for: nvim-treesitter
time([[Config for nvim-treesitter]], true)
try_loadstring("\27LJ\1\2†\2\0\0\4\0\f\0\0154\0\0\0%\1\1\0>\0\2\0027\0\2\0003\1\3\0003\2\4\0003\3\5\0:\3\6\2:\2\a\0013\2\b\0:\2\t\0013\2\n\0:\2\v\1>\0\2\1G\0\1\0\14highlight\1\0\2&additional_vim_regex_highlighting\2\venable\2\26incremental_selection\1\0\1\venable\2\vindent\fdisable\1\2\0\0\vpython\1\0\1\venable\2\1\0\1\21ensure_installed\15maintained\nsetup\28nvim-treesitter.configs\frequire\0", "config", "nvim-treesitter")
time([[Config for nvim-treesitter]], false)
-- Config for: gitsigns.nvim
time([[Config for gitsigns.nvim]], true)
try_loadstring("\27LJ\1\0026\0\0\2\0\3\0\0064\0\0\0%\1\1\0>\0\2\0027\0\2\0>\0\1\1G\0\1\0\nsetup\rgitsigns\frequire\0", "config", "gitsigns.nvim")
time([[Config for gitsigns.nvim]], false)
-- Config for: telescope.nvim
time([[Config for telescope.nvim]], true)
try_loadstring("\27LJ\1\0027\0\0\2\0\3\0\0064\0\0\0%\1\1\0>\0\2\0027\0\2\0>\0\1\1G\0\1\0\nsetup\14telescope\frequire\0", "config", "telescope.nvim")
time([[Config for telescope.nvim]], false)
-- Config for: coq.thirdparty
time([[Config for coq.thirdparty]], true)
try_loadstring("\27LJ\1\2\1\0\0\3\0\4\0\n4\0\0\0%\1\1\0>\0\2\0022\1\3\0003\2\2\0;\2\1\0013\2\3\0;\2\2\1>\0\2\1G\0\1\0\1\0\3\bsrc\fcopilot\15short_name\bCOP\19tmp_accept_key\n<c-r>\1\0\2\bsrc\fnvimlua\15short_name\tnLUA\vcoq_3p\frequire\0", "config", "coq.thirdparty")
time([[Config for coq.thirdparty]], false)
if should_profile then save_profiles() end

end)

if not no_errors then
  vim.api.nvim_command('echohl ErrorMsg | echom "Error in packer_compiled: '..error_msg..'" | echom "Please check your config for correctness" | echohl None')
end

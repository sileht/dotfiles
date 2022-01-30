local M = {}

M.signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
M.qfsigns = { E = " ", W = " ", H = " ", N = " ", I = " " }

local errlist_type_map = {
  [vim.diagnostic.severity.ERROR] = 'E',
  [vim.diagnostic.severity.WARN] = 'W',
  [vim.diagnostic.severity.INFO] = 'I',
  [vim.diagnostic.severity.HINT] = 'N',
}


function M.toqflist(diagnostics)
  vim.validate {
    diagnostics = {
      diagnostics,
      vim.tbl_islist,
      "a list of diagnostics",
    },
  }

  local list = {}
  for _, v in ipairs(diagnostics) do
    local item = {
      bufnr = v.bufnr,
      lnum = v.lnum + 1,
      col = v.col and (v.col + 1) or nil,
      end_lnum = v.end_lnum and (v.end_lnum + 1) or nil,
      end_col = v.end_col and (v.end_col + 1) or nil,
      -- copy of toqflist with only this line changed
      text = v.message .. ' (' .. v.source .. ')',
      type = errlist_type_map[v.severity] or 'E',
    }
    table.insert(list, item)
  end
  table.sort(list, function(a, b)
    if a.bufnr == b.bufnr then
      return a.lnum < b.lnum
    else
      return a.bufnr < b.bufnr
    end
  end)
  return list
end

function M.setqflist()
  local opts = {}
  local title = "Diagnostics"
  local bufnr = 0
  -- Don't clamp line numbers since the quickfix list can already handle line
  -- numbers beyond the end of the buffer
  local diagnostics = vim.diagnostic.get(bufnr, opts, false)
  local items = M.toqflist(diagnostics)
  vim.fn.setqflist({}, ' ', { title = title, items = items })
end

function M.setup()
    vim.diagnostic.config({
        virtual_text = { spacing = 4, prefix = "●" },
        sign = true,
        underline = false,
        update_in_insert = false,
        severity_sort = true,
    })
    --vim.cmd("autocmd CursorHold <buffer> lua vim.diagnostic.open_float({focusable=false})")
    vim.cmd("copen")
    vim.cmd("autocmd DiagnosticChanged * lua require('diagnostics').setqflist()")

    for type, icon in pairs(M.signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
    end
    vim.o.quickfixtextfunc = "{info -> v:lua.require('diagnostics').qftf(info)}"
end

function M.qftf(info)
    local items
    local ret = {}
    if info.quickfix == 1 then
        items = vim.fn.getqflist({id = info.id, items = 0}).items
    else
        items = vim.fn.getloclist(info.winid, {id = info.id, items = 0}).items
    end
    --local limit = 15
    --local fname_fmt1, fname_fmt2 = '%-' .. limit .. 's', '…%.' .. (limit - 1) .. 's'
    local valid_fmt = '%s | %s%s [%d:%d]'
    for i = info.start_idx, info.end_idx do
        local e = items[i]
        local fname = ''
        local str
        if e.valid == 1 then
            if e.bufnr > 0 then
                fname = vim.fn.bufname(e.bufnr)
                if fname == '' then
                    fname = '[No Name]'
                else
                    fname = fname:gsub('^' .. vim.env.HOME, '~')
                end
                -- char in fname may occur more than 1 width, ignore this issue in order to keep performance
                --[[--
                if #fname <= limit then
                    fname = fname_fmt1:format(fname)
                else
                    fname = fname_fmt2:format(fname:sub(1 - limit))
                end
                --]]--
            end
            local lnum = e.lnum > 99999 and -1 or e.lnum
            local col = e.col > 999 and -1 or e.col
            local qtype = e.type:sub(1, 1):upper()
            local qtype_icon = M.qfsigns[qtype]
            local qtype_text = qtype or ' '
            local qtype_ui = (qtype_icon or qtype_text)
            str = valid_fmt:format(fname, qtype_ui, e.text, lnum, col)
        else
            str = e.text
        end
        table.insert(ret, str)
    end
    return ret
end
return M

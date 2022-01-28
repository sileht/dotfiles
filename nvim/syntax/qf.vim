if exists("b:current_syntax")
    finish
endif

syn match qfFileName /^[^|]*/ nextgroup=qfSeparator
syn match qfSeparator /|/ contained nextgroup=qfError,qfWarning,qfInfo,qfHint
syn match qfError / [E] [^\[]*/ contained nextgroup=qfLineNr
syn match qfWarning / [W] [^\[]*/ contained nextgroup=qfLineNr
syn match qfInfo / [I] [^\[]*/ contained nextgroup=qfLineNr
syn match qfHint / [NH] [^\[]*/ contained nextgroup=qfLineNr
syn match qfLineNr /\[\d\+:\d\+\]$/ contained

hi def link qfFileName Directory
hi def link qfSeparator Delimiter
hi def link qfError DiagnosticError
hi def link qfWarning DiagnosticWarn
hi def link qfInfo DiagnosticInfo
hi def link qfHint DiagnosticHint
hi def link qfLineNr Comment

let b:current_syntax = 'qf'

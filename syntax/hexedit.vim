if exists("b:current_syntax")
    finish
endif

syn match hexeditAddress "^\x\+\ze:"
syn match hexeditSeparator ":"
syn match hexeditHex "\x\+\ze "
syn match hexeditAscii "  .\+$" contains=hexeditDot
syn match hexeditDot "\." contained

hi link hexeditAddress Statement
hi link hexeditSeparator Delimiter
hi link hexeditHex Constant
hi link hexeditAscii String
hi link hexeditDot SpecialChar

let b:current_syntax = "hexedit"

" File: contextcomplete.vim
" Description: Decide which completion type to use based on context
" Maintainer: Evergreen
" Version: 1.2.1
" Last Change: May 30th, 2015
" License: Vim License

" BOILERPLATE {{{
if exists("g:contextcomplete_loaded") || &cp || v:version < 700
    finish
endif

let g:contextcomplete_loaded = 1
" }}}

" SETTINGS/SCRIPT VARIABLES {{{
" Key to initiate context completion.
let g:contextcomplete_trigger = get(g:, 'contextcomplete_trigger', '\<Tab>')

" Dictionary of completion types and the regexes used to detect them.
" Possible dictionary keys:
" lines, keywords, dictionary, thesaurus, keywords-included, tags, file-names,
" macros, cmdline, user, omnicomplete, spelling, complete-keywords, ignore
let g:contextcomplete_detect_regexes = get(g:,
\ 'contextcomplete_detect_regexes', {
    \ 'keywords': '\v\w{-1,}$', 'file-names': '\v\/(\w|\-){-}$',
    \ 'omnicomplete': '\v\.\w{-}$', 'ignore': '\v^\s*$'
\ })

" Order of precedence for each type of completion.  (first one to match is used)
let g:contextcomplete_key_order = get(g:, 'contextcomplete_key_order', [
    \ 'file-names', 'omnicomplete', 'keywords',
\ ])

" The readable name of the completion, and the associated key press to initiate
" that completion mode.
let s:contextcomplete_type_with_keypress = {
    \ 'lines': "\<C-x>\<C-l>", 'keywords': "\<C-x>\<C-n>",
    \ 'dictionary': "\<C-x>\<C-k>", 'thesaurus': "\<C-x>\<C-t>",
    \ 'keywords-included': "\<C-x>\<C-i>", 'tags': "\<C-x>\<C-]>",
    \ 'file-names': "\<C-x>\<C-f>", 'macros': "\<C-x>\<C-d>",
    \ 'cmdline': "\<C-x>\<C-v>", 'user': "\<C-x>\<C-u>",
    \ 'omnicomplete': "\<C-x>\<C-o>", 'spelling': "\<C-x>s",
    \ 'complete-keywords': "\<C-n>"
\ }
" }}}

" FUNCTIONS {{{
" This function returns the keypress for the detected completion mode, and if it
" is not found or matches ignore, returns a the trigger's normal keypress
function! s:ContextComplete()
    let current_line = getline(".")
    " This gets all the text that is behind the cursor using string slices.
    let line_before_col = current_line[0:col(".")-2]

    if line_before_col =~# get(g:contextcomplete_detect_regexes, 'ignore', '')
        return eval('"' . g:contextcomplete_trigger . '"')
    endif

    let completion_type = -1

    for type in g:contextcomplete_key_order
        if has_key(g:contextcomplete_detect_regexes, type) != 0
            let detect_regex = g:contextcomplete_detect_regexes[type]
        else
            continue
        endif

        if line_before_col =~# detect_regex
            let completion_type = type
            break
        endif
    endfor

    if completion_type == -1
        return eval('"' . g:contextcomplete_trigger . '"')
    endif

    " This makes the trigger key cycle through completion options
    exe 'inoremap ' . substitute(g:contextcomplete_trigger, "\\", "", "g") .
                \ " <c-n>"

    return s:contextcomplete_type_with_keypress[completion_type]
endfunction
" }}}

" MAPPINGS {{{
" Run the result of ContextComplete when the trigger key is pressed
exe 'inoremap <expr> ' . substitute(g:contextcomplete_trigger, "\\", "", "g") .
        \ ' <SID>ContextComplete()'

" When completion mode is exited, make trigger key behave like before it was
" mapped to <c-n>.
autocmd CompleteDone * exe 'inoremap <expr> ' . substitute(
        \ g:contextcomplete_trigger, "\\", "", "g") . ' <SID>ContextComplete()'
" }}}

" vim: set sw=4 sts=4 et fmr={{{,}}} fdm=marker:

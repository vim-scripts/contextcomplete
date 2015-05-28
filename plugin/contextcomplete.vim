" File: contextcomplete.vim
" Description: Decide which completion type to use based on context
" Maintainer: Evergreen
" Version: 1.0.0
" Last Change: May 28th, 2015
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

" The possible dictionary keys reference a kind of insert completion, which can
" be found in the 'ins-completion' help topic.  If a dictionary key is not used,
" it is ignored.  The default value is the last item in the dictionary that
" matches.  Will fall back to the previous one if the specified regex doesn't
" match.  The regex associated with the key is the regex that is used to figure
" out whether to start using that completion mode.

" Possible dictionary keys:
" lines, keywords, dictionary, thesaurus, keywords-included, tags, file-names,
" macros, cmdline, user, omnicomplete, spelling, complete-keywords, ignore
let g:contextcomplete_detect_regexes = get(g:,
\ 'contextcomplete_detect_regexes', {
    \ 'keywords': '\v<\w+>$', 'omnicomplete': '\v\.$',
    \ 'ignore': '\v^\s*$'
\ })

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
" is not found or matches ignore, returns a tab keypress.
function! s:ContextComplete()
    let current_line = getline(".")
    " This gets all the text that is behind the cursor using string slices.
    let line_before_col = current_line[0:col(".")-2]

    let completion_type = -1

    for type in keys(g:contextcomplete_detect_regexes)
        let detect_regex = g:contextcomplete_detect_regexes[type]
        if line_before_col =~# detect_regex
            let completion_type = type
        endif
    endfor

    if completion_type == -1
        return eval('"' . g:contextcomplete_trigger . '"')
    elseif line_before_col =~# g:contextcomplete_detect_regexes['ignore']
        return eval('"' . g:contextcomplete_trigger . '"')
    endif

    " This makes tab cycle through completion options
    exe 'inoremap ' . substitute(g:contextcomplete_trigger, "\\", "", "g") .
                \ " <c-n>"

    return s:contextcomplete_type_with_keypress[completion_type]
endfunction
" }}}

" MAPPINGS {{{
" Run the result of ContextComplete when tab key is pressed
exe 'inoremap <expr> ' . substitute(g:contextcomplete_trigger, "\\", "", "g") .
        \ ' <SID>ContextComplete()'

" When completion mode is exited, make tab behave like before it was mapped to
" <c-n>.
autocmd CompleteDone * exe 'inoremap <expr> ' . substitute(
        \ g:contextcomplete_trigger, "\\", "", "g") . ' <SID>ContextComplete()'
" }}}

" vim: set sw=4 sts=4 et fmr={{{,}}} fdm=marker:

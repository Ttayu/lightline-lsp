let s:indicator = {
      \ 'hint': get(g:, 'lightline#lsp#indicator_hints', 'H: '),
      \ 'info': get(g:, 'lightline#lsp#indicator_infos', 'I: '),
      \ 'warn': get(g:, 'lightline#lsp#indicator_warnings', 'W: '),
      \ 'error': get(g:, 'lightline#lsp#indicator_errors', 'E: '),
      \ 'ok': get(g:, 'lightline#lsp#indicator_ok', 'OK'),
      \ }
let s:update_in_insert = get(g:, 'lightline#lsp#update_in_insert', v:true)

if !exists('s:message')
  let s:message = {}
  for level in ['hint', 'info', 'warn', 'error', 'ok']
    let s:message[level] = ''
  endfor
endif
""""""""""""""""""""""
" Lightline components

function! lightline#lsp#hints() abort
  return s:status('hint')
endfunction

function! lightline#lsp#infos() abort
  return s:status('info')
endfunction

function! lightline#lsp#warnings() abort
  return s:status('warn')
endfunction

function! lightline#lsp#errors() abort
  return s:status('error')
endfunction

function! lightline#lsp#ok() abort
  if !s:linted()
    return ''
  endif
  if s:skip_update_in_insert()
    return s:message['ok']
  endif
  let l:hint_counts = s:counts('hint')
  let l:info_counts = s:counts('info')
  let l:warn_counts = s:counts('warn')
  let l:error_counts = s:counts('error')
  let l:counts = l:hint_counts+l:info_counts+l:warn_counts+l:error_counts
  let s:message['ok'] = l:counts == 0 ? s:indicator['ok'] : ''
  return s:message['ok']
endfunction

""""""""""""""""""
" Helper functions

function! s:linted() abort
  return !!luaeval('not vim.tbl_isempty(vim.lsp.buf_get_clients('.bufnr().'))')
endfunction

function! s:skip_update_in_insert() abort
  return !s:update_in_insert && mode() == 'i'
endfunction

function! s:counts(level) abort
  let l:counts = luaeval("require('lightline-lsp')._get_diagnostic_count('" . a:level . "')")
  return l:counts
endfunction

function! s:get_message(level) abort
  let l:counts = s:counts(a:level)
  let l:message = l:counts == 0 ? '' : printf('%s%d', s:indicator[a:level], l:counts)
  return l:message
endfunction

function! s:status(level) abort
  if !s:linted()
    return ''
  endif
  if s:skip_update_in_insert()
    return s:message[a:level]
  endif
  let s:message[a:level] = s:get_message(a:level)
  return s:message[a:level]
endfunction

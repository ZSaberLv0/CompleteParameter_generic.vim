
" ============================================================
function! cmp#new_ftfunc(filetype) abort "{{{
  if get(get(g:, 'CMGeneric_blacklist', {}), a:filetype, 0)
        \ || !get(g:, 'CMGeneric_enable', 1)
        \ || !get(b:, 'CMGeneric_enable', 1)
    return s:new_ftfunc(a:filetype)
  endif

  if !get(g:, 'CMGeneric_enable_all', 0)
    if empty(a:filetype)
      throw 'filetype is empty'
    endif
  endif

  let ftfunc = deepcopy(s:ftfunc)
  let ftfunc['ft'] = a:filetype
  for name in [
        \ 'parameters',
        \ 'parameter_delim',
        \ 'parameter_begin',
        \ 'parameter_end',
        \ 'echos',
        \ ]
    let ftfunc[name] = function('CMGeneric_impl_' . name)
  endfor

  return ftfunc
endfunction "}}}

let s:ftfunc_prefix = 'cm_parser#'
let s:ftfunc = {'ft': ''}
function! s:new_ftfunc(filetype) abort "{{{
  if empty(a:filetype)
    throw 'filetype is empty'
  endif

  let ftfunc = deepcopy(s:ftfunc)
  let ftfunc['ft'] = a:filetype
  try
    let ftfunc['parameters'] = function(s:ftfunc_prefix . a:filetype .'#parameters')
    let ftfunc['parameter_delim'] = function(s:ftfunc_prefix . a:filetype . '#parameter_delim')
    let ftfunc['parameter_begin'] = function(s:ftfunc_prefix. a:filetype . '#parameter_begin')
    let ftfunc['parameter_end'] = function(s:ftfunc_prefix . a:filetype . '#parameter_end')
    if exists('*'.s:ftfunc_prefix.a:filetype.'#echos')
      let ftfunc['echos'] = function(s:ftfunc_prefix.a:filetype.'#echos')
    else
      let ftfunc['echos'] = function('cmp#default_echos')
    endif
  catch /^E700/
    throw 'the function should be defined: ' . v:exception
  endtry

  return ftfunc
endfunction "}}}

function! cmp#filetype_func_check(ftfunc) abort "{{{
  " if !<SID>filetype_func_exist(a:ftfunc['ft'])
  "   return 0
  " endif

  " let parameters = a:ftfunc.parameters(v:completed_item)
  " if type(parameters) != 3
  "     return 0
  " endif

  if !exists('*'.string(a:ftfunc.parameter_delim))
    return 0
  endif
  let delim = a:ftfunc.parameter_delim()
  if type(delim) != 1 || empty(delim)
    return 0
  endif

  if !exists('*'.string(a:ftfunc.parameter_begin))
    return 0
  endif
  let begin = a:ftfunc.parameter_begin()
  if type(begin) != 1 || empty(begin)
    return 0
  endif

  if !exists('*'.string(a:ftfunc.parameter_end))
    return 0
  endif
  let end = a:ftfunc.parameter_end()
  if type(end) != 1 || empty(end)
    return 0
  endif
  return 1
endfunction "}}}


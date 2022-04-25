
" ============================================================
function! s:CMGeneric_new_ftfunc(filetype) abort
    if get(get(g:, 'CMGeneric_blacklist', {}), a:filetype, 0)
                \ || !get(g:, 'CMGeneric_enable', 1)
                \ || !get(b:, 'CMGeneric_enable', 1)
        return {}
    endif

    if !get(g:, 'CMGeneric_enable_all', 0)
        if empty(a:filetype)
            return {}
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
endfunction

" ============================================================
if !exists('s:new_ftfunc_orig')
    let s:new_ftfunc_orig = function('cmp#new_ftfunc')
endif

let s:ftfunc = {'ft': ''}
function! cmp#new_ftfunc(filetype) abort
    let CMGeneric_ftfunc = s:CMGeneric_new_ftfunc(a:filetype)
    if !empty(CMGeneric_ftfunc)
        return CMGeneric_ftfunc
    endif

    return s:new_ftfunc_orig(a:filetype)
endfunction



execute 'source ' . substitute(expand('<sfile>:h:h'), '\', '/', 'g') . '/autoload/cmp.vim'

" ============================================================
function! CMGeneric_impl_parameters(completed_item)
    return CMGeneric_parser(a:completed_item)
endfunction
function! CMGeneric_impl_parameter_delim()
    return ','
endfunction
function! CMGeneric_impl_parameter_begin()
    return '(<'
endfunction
function! CMGeneric_impl_parameter_end()
    return ')>'
endfunction
function! CMGeneric_impl_echos(completed_item)
    return []
endfunction

" ============================================================
function! CMGeneric_parser(completed_item)
    for key in [
                \   'abbr',
                \   'menu',
                \   'info',
                \ ]
        let ret = CMGeneric_parser_string(get(a:completed_item, key, ''))
        if !empty(ret)
            return ret
        endif
    endfor
    return []
endfunction

" ============================================================
" func()
" func(int)
" func(const char *)
" func(const char *a, int b)
" func(std::vector<int> const &a)
function! CMGeneric_parser_string(text)
    let datas = []
    let iMaxLen = 0

    let i = 0
    while 1
        let data = CMGeneric_parser_splitPair(a:text, i)
        if empty(data)
            break
        endif
        let i = data['end'] + 1
        call add(datas, data)
        if len(datas) == 1
            continue
        endif
        if data['end'] - data['begin'] > datas[iMaxLen]['end'] - datas[iMaxLen]['begin']
            let iMaxLen = len(datas) - 1
        endif
    endwhile
    if empty(datas)
        return []
    endif

    let data = datas[iMaxLen]
    return [CMGeneric_parser_normalize(strpart(a:text, data['begin'], data['end'] + 1 - data['begin']))]
endfunction

function! CMGeneric_parser_normalize(text)
    let text = a:text
    for t in get(g:, 'CMGeneric_translate', [
                \   ['…', '...'],
                \ ])
        let text = substitute(text, t[0], t[1], 'g')
    endfor
    return text
endfunction

" params:
"   start
"   beginTokens: '(<'
"   endTokens: ')>'
"   separators: ','
" return: {
"   'begin' : pos,
"   'end' : pos,
"   'separators' : [pos, ...],
" }
" func(int a, T<int, int> b, int c)
"     ^ begin
"           ^ separator0
"                          ^ separator1
"                                 ^ end
function! CMGeneric_parser_splitPair(text, ...)
    if empty(a:text)
        return {}
    endif

    let start = get(a:, 1, 0)
    let beginTokens = get(a:, 2, '(<')
    let endTokens = get(a:, 3, ')>')
    let separators = get(a:, 4, ',')

    let beginTokensLen = len(beginTokens)
    let endTokensLen = len(endTokens)
    let separatorsLen = len(separators)
    let textLen = len(a:text)

    let ret = {
                \   'begin' : -1,
                \   'end' : -1,
                \   'separators' : [],
                \ }

    let tokenStack = []
    let i = start

    " find beginTokens
    while i < textLen
        let iToken = s:tokenIndex(a:text[i], beginTokens, beginTokensLen)
        if iToken >= 0
            call add(tokenStack, iToken)
            let ret['begin'] = i
            let i += 1
            break
        endif
        let i += 1
    endwhile
    if empty(tokenStack)
        return {}
    endif

    " find each
    while i < textLen
        let c = a:text[i]
        let i += 1

        let iBeginToken = s:tokenIndex(c, beginTokens, beginTokensLen)
        if iBeginToken >= 0
            call add(tokenStack, iBeginToken)
            continue
        endif

        let iEndToken = s:tokenIndex(c, endTokens, endTokensLen)
        if iEndToken >= 0
            if iEndToken != remove(tokenStack, -1)
                return
            endif
            if empty(tokenStack)
                let ret['end'] = i - 1
                return ret
            endif
        endif

        if len(tokenStack) > 1
            continue
        endif
        let iSeparator = s:tokenIndex(c, separators, separatorsLen)
        if iSeparator >= 0
            call add(ret['separators'], i - 1)
        endif
    endwhile

    return {}
endfunction

function! s:tokenIndex(c, tokens, tokensLen)
    let i = 0
    while i < a:tokensLen
        if a:c == a:tokens[i]
            return i
        endif
        let i += 1
    endwhile
    return -1
endfunction



# Intro

generic verion of [CompleteParameter.vim](https://github.com/tenfyzhong/CompleteParameter.vim)

this plugin would try to "guess" parameter info from `v:completed_item`,
ignore the original [cm_parser](https://github.com/tenfyzhong/CompleteParameter.vim/tree/master/cm_parser),
so no filetype needs to be configured

# Usage

simply install this plugin, but must after `CompleteParameter.vim`

```
Plug 'tenfyzhong/CompleteParameter.vim'
Plug 'ZSaberLv0/CompleteParameter_generic.vim'
```

# Options

* add filetype to black list, to use original `cm_parser` logic

    ```
    let g:CMGeneric_blacklist = {
            \   'cpp' : 1,
            \ }
    ```

* `g:CMGeneric_enable` or `b:CMGeneric_enable` : enable or disable at runtime
* `let g:CMGeneric_enable_all = 0` : whether enable for empty `filetype`


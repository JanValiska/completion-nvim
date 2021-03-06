[![Gitter](https://badges.gitter.im/completion-nvim/community.svg)](https://gitter.im/completion-nvim/community?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)
# completion-nvim

completion-nvim is an auto completion framework that aims to provide a better
completion experience with neovim's built-in LSP.  Other LSP functionality is not
supported.

## Features

- Asynchronous completion using the `libuv` api.
- Automatically open hover windows when popupmenu is available.
- Automatically open signature help if it's available.
- Snippets integration with UltiSnips and Neosnippet.
- Chain completion support inspired by ![vim-mucomplete](https://github.com/lifepillar/vim-mucomplete)

## Demo

Demo using `sumneko_lua`
![](https://user-images.githubusercontent.com/35623968/76489411-3ca1d480-6463-11ea-8c3a-7f0e3c521cdb.gif)

## Prerequisites
- Neovim nightly
- You should set up your language server of choice with the help of [nvim-lsp](https://github.com/neovim/nvim-lsp)

## Install

- Install with any plugin manager by using the path on GitHub.

```vim
Plug 'haorenW1025/completion-nvim'
```

## Setup

- completion-nvim requires several autocommands set up to work properly. You should
  set it up using the `on_attach` function like this.

```vim
lua require'nvim_lsp'.pyls.setup{on_attach=require'completion'.on_attach}
```
- Change `pyls` to whichever language server you're using.
- If you want completion-nvim to be set up for all buffers instead of only being
  used when lsp is enabled, call the `on_attach` function directly:

```vim
" Use completion-nvim in every buffer
autocmd BufEnter * lua require'completion'.on_attach()
```

*NOTE* It's okay to set up completion-nvim without lsp. It will simply use
another completion source instead(Ex: snippets).

## Configuration

### Recommended Setting

```vim
" Use <Tab> and <S-Tab> to navigate through popup menu
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" Set completeopt to have a better completion experience
set completeopt=menuone,noinsert,noselect

" Avoid showing message extra message when using completion
set shortmess+=c
```

### Enable/Disable auto popup

- By default auto popup is enabled, turn it off by

```vim
let g:completion_enable_auto_popup = 0
```
- Or you can toggle auto popup on the fly by using command `CompletionToggle`
- You can manually trigger completion with mapping key by

```vim
inoremap <silent><expr> <c-p> completion#trigger_completion() "map <c-p> to manually trigger completion
```

- Or you want to use `<Tab>` as trigger keys

```vim
function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~ '\s'
endfunction

inoremap <silent><expr> <TAB>
  \ pumvisible() ? "\<C-n>" :
  \ <SID>check_back_space() ? "\<TAB>" :
  \ completion#trigger_completion()
```

### Enable Snippets Support

- By default other snippets source support are disabled, turn them on by

```vim
let g:completion_enable_snippet = 'UltiSnips'
```
- Support `UltiSnips` and `Neosnippet`

### Chain Completion Support

- completion-nvim supports chain completion, which use other completion sources
  and `ins-completion` as a fallback for lsp completion.

- See ![wiki](https://github.com/haorenW1025/completion-nvim/wiki/chain-complete-support) for
  details on how to set this up.

### Changing Completion Confirm key

- By default `<CR>` is used to confirm completion and expand snippets, change it by

```vim
let g:completion_confirm_key = "\<C-y>"
```

- Make sure to use `" "` and add escape key `\` to avoid parsing issues.
- If the confirm key has a fallback mapping, for example when using the auto
  pairs plugin, it maps to `<CR>`. Provide it like this:

```.vim
"Fallback for https://github.com/Raimondi/delimitMate expanding on enter
let g:completion_confirm_key_rhs = "\<Plug>delimitMateCR"
```

### Enable/Disable auto hover

- By default when navigating through completion items, LSP's hover is automatically
  called and displays in a floating window. Disable it by

```vim
let g:completion_enable_auto_hover = 0
```

### Enable/Disable auto signature

- By default signature help opens automatically whenever it's available. Disable
  it by

```vim
let g:completion_enable_auto_signature = 0
```

### Max Items for completion

- You can set a number limit for the maximum completion items. For example, if you
just want at most 10 items in your popup menu, set it by

```vim
let g:completion_max_items = 10
```

*NOTE* that this only works for non `ins-complete` completion source.

### Trigger Characters

- By default, `completion-nvim` respect the trigger character of your language server, if you
want more trigger characters, add it by

```vim
let g:completion_trigger_character = ['.', '::']
```

*NOTE* use `:lua print(vim.inspect(vim.lsp.buf_get_clients()[1].server_capabilities.completionProvider.triggerCharacters))`
to see the trigger character of your language server.

- If you want different trigger character for different languages, wrap it in an autocommand like

```vim
augroup CompleteionTriggerCharacter
    autocmd!
    autocmd BufEnter * let g:completion_trigger_character = ['.']
    autocmd BufEnter *.c,*.cpp let g:completion_trigger_character = ['.', '::']
augroup end
```

### Timer Adjustment

- completion-nvim uses a timer to control the rate of completion. You can adjust the timer rate by

```vim
let g:completion_timer_cycle = 200 "default value is 80
```

## Trouble Shooting

- This plugin is in the early stages and might have unexpected issues.
  Please follow ![wiki](https://github.com/haorenW1025/completion-nvim/wiki/trouble-shooting)
  for trouble shooting.
- Feel free to post issues on any unexpected behavior or open a feature request!

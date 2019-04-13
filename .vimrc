set t_Co=256
set nocompatible
filetype off
set backupdir=~/.vim/bckup//
set directory=~/.vim/swap//

set rtp+=~/.vim/bundle/Vundle.vim
" call vundle#rc()
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'

Plugin 'ctrlpvim/ctrlp.vim'

Plugin 'scrooloose/syntastic'

Plugin 'scrooloose/nerdtree'

Plugin 'vim-ruby/vim-ruby'
Plugin 'scrooloose/nerdcommenter'
"Plugin 'terryma/vim-multiple-cursors'
Plugin 'nvie/vim-flake8'
Plugin 'vim-scripts/django.vim'
Plugin 'kien/rainbow_parentheses.vim'
Plugin 'Valloric/YouCompleteMe'
Plugin 'avakhov/vim-yaml'
Plugin 'elixir-lang/vim-elixir'
"Plugin 'saltstack/salt-vim'
"Plugin 'hdima/python-syntax'
Plugin 'ntpeters/vim-better-whitespace'
"Plugin 'isRuslan/vim-es6'
Plugin 'xolox/vim-misc'  " dependency of vim-easytags
Plugin 'xolox/vim-easytags'
Plugin 'majutsushi/tagbar'
Plugin 'morhetz/gruvbox'
Plugin 'editorconfig/editorconfig-vim'
Plugin 'adelarsq/vim-matchit'
call vundle#end()
filetype plugin indent on

set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4
set autoindent
set laststatus=2

"color calmar256-dark
"color twilight256
color gruvbox
set background=dark
set encoding=utf8
set smarttab
set number
set ignorecase smartcase
set cursorline

augroup vimrcEx
  " Clear all autocmds in the group
  autocmd!
  autocmd FileType text setlocal textwidth=78
  " Jump to last cursor position unless it's invalid or in an event handler
  autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif

  "for ruby, autoindent with two spaces, always expand tabs
  autocmd FileType ruby,haml,eruby,yaml,javascript,sass,cucumber,scss set ai sw=2 sts=2 et
  autocmd FileType python set sw=4 sts=4 et
  autocmd FileType html setl sw=2 sts=2 et
  autocmd FileType sls setl sw=3 sts=3 et
  autocmd FileType less setl sw=2 sts=2 et
  autocmd FileType c setl sw=4 sts=4 et
  autocmd FileType go setlocal noet ts=4 sw=4 sts=4

  autocmd! BufRead,BufNewFile *.sass setfiletype sass
  autocmd! BufRead,BufNewFile *.ngt setfiletype html

  autocmd BufRead *.mkd  set ai formatoptions=tcroqn2 comments=n:&gt;
  autocmd BufRead *.markdown  set ai formatoptions=tcroqn2 comments=n:&gt;

  " Indent p tags
"  autocmd FileType html,eruby if g:html_indent_tags !~ '\\|p\>' | let g:html_indent_tags .= '\|p\|li\|dt\|dd' | endif

  " Don't syntax highlight markdown because it's often wrong
  autocmd! FileType mkd setlocal syn=off
augroup END


"function! RunTests(filename)
    "" Write the file and run tests for the given filename
    ":w
    ":silent !echo;echo;echo;echo;echo;echo;echo;echo;echo;echo
    ":silent !echo;echo;echo;echo;echo;echo;echo;echo;echo;echo
    ":silent !echo;echo;echo;echo;echo;echo;echo;echo;echo;echo
    ":silent !echo;echo;echo;echo;echo;echo;echo;echo;echo;echo
    ":silent !echo;echo;echo;echo;echo;echo;echo;echo;echo;echo
    ":silent !echo;echo;echo;echo;echo;echo;echo;echo;echo;echo
    "if match(a:filename, '\.feature$') != -1
        "exec ":!script/features " . a:filename
    "else
        "if filereadable("script/test")
            "exec ":!script/test " . a:filename
        "elseif filereadable("config/spring.rb")
            "exec ":!spring rspec --color " . a:filename
        "elseif filereadable("Gemfile")
            "exec ":!bundle exec rspec --color " . a:filename
        "else
            "exec ":!rspec --color " . a:filename
        "end
    "end
"endfunction

"function! SetTestFile()
    "" Set the spec file that tests will be run for.
    "let t:grb_test_file=@%
"endfunction

"function! RunTestFile(...)
    "if a:0
        "let command_suffix = a:1
    "else
        "let command_suffix = ""
    "endif

    "" Run the tests for the previously-marked file.
    "let in_test_file = match(expand("%"), '\(.feature\|_spec.rb\)$') != -1
    "if in_test_file
        "call SetTestFile()
    "elseif !exists("t:grb_test_file")
        "return
    "end
    "call RunTests(t:grb_test_file . command_suffix)
"endfunction

"function! RunNearestTest()
    "let spec_line_number = line('.')
    "call RunTestFile(":" . spec_line_number . " -b")
"endfunction

"function! SpringStop()
    "if filereadable("config/spring.rb")
        "exec ":!spring stop"
    "end
"endfunction

"function! RakeRoutesDo(path)
    "if filereadable("config/spring.rb")
        "exec ":!spring rake routes | grep " . a:path
    "else
        "exec ":!bundle exec rake routes | grep " . a:path
    "end
"endfunction

function! GoRun()
    exec "w !go run %"
endfunction

function! GoFmt()
    exec "!go fmt %"
endfunction

"function! LeinTest()
    "exec "!lein test"
"endfunction

"function! Trim()
  "%s/[ \t]+$//
"endfunction

function! WhitespaceToggle()
  set list!
endfunc

function! NumberToggle()
  if(&relativenumber == 1)
    set norelativenumber
    set number
  else
    set relativenumber
  endif
endfunc

function! YapfDiff()
  exec "!yapf --style google -d %"
endfunc

"map <leader>t :call RunTestFile()<cr>
"map <leader>T :call RunNearestTest()<cr>
"map <leader>a :call RunTests('')<cr>
"map <leader>s :call SpringStop()<cr>
"map <leader>l :call LeinTest()<cr>
map <leader>m :call NumberToggle()<cr>
map <leader>s :call WhitespaceToggle()<cr>
map <leader>a :call yapf#YAPF()<cr>
map <leader>q :call YapfDiff()<cr>
nnoremap <Leader>b :TagbarToggle<CR>

":command -nargs=1 RakeRoutes call RakeRoutesDo("<args>")
":command -nargs=0 GO call GoRun()
":command -nargs=0 TRIM call Trim()

set synmaxcol=180
set lazyredraw

set pastetoggle=<F4>
map <F3> :RainbowParenthesesToggle<CR>
set switchbuf+=newtab
set pastetoggle=<F2>
" CtrlP Stuff
let g:ctrlp_custom_ignore = 'node_modules\|.git$\|.*.pyc\|_build\|deps\|vendor'
let g:ctrlp_root_markers = ['setup.py', 'LICENSE', 'README.md', '.git', 'Gopkg.lock']
nnoremap <leader>o :CtrlPTag<cr>

set wildignore+=**/node_modules/**
set wildignore+=**/.git/**
set wildignore+=**/bower_components/**
set wildignore+=**/deps/**
set wildignore+=**/_build/**

" Easytags stuff
let g:easytags_file = '~/.vim/tags'
let g:easytags_syntax_keyword = 'always'
let g:easytags_python_enabled = 1
let g:easytags_async = 1
let g:easytags_auto_highlight = 0
let g:easytags_opts = ['--fields=+l']
set regexpengine=0

let g:tagbar_type_go = {
    \ 'ctagstype': 'go',
    \ 'kinds' : [
        \'p:package',
        \'f:function',
        \'v:variables',
        \'t:type',
        \'c:const'
    \]
\}

highlight Pmenu ctermfg=white ctermbg=darkgreen guifg=#000000 guibg=#0000ff

" Spelling related
map <F4> :set spell!<CR><Bar>:echo "Spell Check: " . strpart("OffOn", 3 * &spell, 3)<CR>
highlight SpellBad ctermfg=White ctermbg=Green

" Syntastic Checkers
let g:syntastic_c_checkers = ['gcc']

" Macros and small scripts
"

let @p = "Oimport pdb; pdb.set_trace()  # noqa E702"

set path+=$BIOSERVO
set diffopt+=iwhite

set fileencodings=ucs-bom,utf-8,latin1

set backspace=indent,eol,start
set nobk
set nocompatible
set ruler		" show the cursor position all the time

"highlight normal guibg=#D0D0D0
if has('gui_running')
	colorscheme desert
	" set lsp=1
	set guifont=Liberation\ Mono\ 10,Liberation_Mono:h8:cANSI,Consolas:h11
	set guioptions-=T
else
	colorscheme elflord
endif

" Do incremental searching when it's possible to timeout.
if has('reltime')
  set incsearch
endif

if &term =~ "xterm\\|rxvt"
  " use an orange cursor in insert mode
  let &t_SI = "\<Esc>]12;orange\x7"
  " use a red cursor otherwise
  let &t_EI = "\<Esc>]12;red\x7"
  silent !echo -ne "\033]12;red\007"
  " reset cursor when vim exits
  autocmd VimLeave * silent !echo -ne "\033]112\007"
  " use \003]12;gray\007 for gnome-terminal and rxvt up to version 9.21
endif

"set modeline
function! BigTodoEnter()
	if !exists("*InsertTODO")
		function InsertTODO()
			s/^\s*/    TODO: /
			"let l=getline(".")
			"let c=col(".")
			"return l[1: c -1] . "TODO:" . l[c :]
		endfunction

		function ChangeTODO()
			s/^ \{4}TODO:/    DONE:/
			exe "s/\\s*$/ \\/" . strftime("%Y-%m-%d") . "/"
		endfunction
		function ChangeDONE()
			s/^ \{4}DONE:/    IGNORE:/
		endfunction
		function ChangeIGONRE()
			s/^ \{4}IGNORE:/    DONE:/
		endfunction
		function FindTODO()
			if  getline(".") =~ "TODO:"
				return 1
			else
				return 0
			endif
		endfunction

		function FindDONE()
			if  getline(".") =~ "DONE:"
				return 1
			else
				return 0
			endif
		endfunction

		function FindIGNORE()
			if  getline(".") =~ "IGNORE:"
				return 1
			else
				return 0
			endif
		endfunction

		function FindNextTODO()
			let [line,column]= searchpos("\\C^\\s*TODO:","b")
			call setpos(".",[0,line,column,0])
		endfunction
		function FindPreviousTODO()
			let [line,column]= searchpos("\\C^\\s*TODO:","")
			call setpos(".",[0,line,column,0])
		endfunction

		function HandleTODO()
			let lastsearch=@/
			if FindTODO()
				call ChangeTODO()
			else
				if FindDONE()
					call ChangeDONE()
				else
					if FindIGNORE()
						call ChangeIGONRE()
					else
						call InsertTODO()
					endif
				endif
			endif
			let @/=lastsearch
		endfunction


		function InsertDate()
			let l=getline(".")
			if l =~ "^\\s*$" 
				let l=""
			endif
			let l=l . strftime("%Y-%m-%d")
			call setline(".",l)
			normal $
		endfunction
	endif


	 highlight BigTodoDONE gui=bold guifg=green term=bold ctermfg=green
	 highlight BigTodoTODO gui=bold guifg=red cterm=bold ctermfg=red
	 highlight BigTodoIGNORE gui=bold guifg=green cterm=bold ctermfg=green
	 highlight BigTodoDATE gui=bold guifg=goldenrod cterm=bold ctermfg=6
	 highlight BigTodoPhone guifg=springgreen ctermfg=10
	 highlight BigTodoFilename gui=bold guifg=black cterm=bold cterm=bold
	 map <buffer> <F5> :call InsertDate()<CR>
	 inoremap <expr> <buffer> <F5> strftime("%Y-%m-%d")
	 map  <buffer> LK :call HandleTODO()<CR>
	 imap  <buffer> <C-l> <Esc>:call HandleTODO()<CR>A
	 map  <buffer> LL :call FindNextTODO()<CR>
	 map  <buffer> Ll :call FindPreviousTODO()<CR>
	 syn keyword BigTodoDONE DONE
	 syn keyword BigTodoTODO TODO
	 syn keyword BigTodoIGNORE IGNORE
	 syn match BigTodoDATE /[12][09]\d\d-[01]\d-[0-3]\d/
	 syn match BigTodoPhone /\s(\=+\=\d\+\s*[\/-]\(\s*\d\)\{3,14\}/
	 syn match BigTodoFilename /\f\+\(\/\f*\)\+\.\f\{3\}/

endfunction

map <C-Right> :set columns+=5<Esc>
map <C-Left> :set columns-=5<Esc>
map <C-Down> :set lines+=5<Esc>
map <C-Up> :set lines-=5<Esc>
map <C-S-Down> :set lines=1000<Esc>
map <C-A> :cs find 0 <cword><cr>

nmap Ö :

map qq :Explore<CR>

if has("autocmd")

	filetype plugin indent on

	autocmd! BufEnter BigTodo.txt call BigTodoEnter()
	autocmd! BufEnter diary.txt call BigTodoEnter()

	autocmd BufReadPost *.txt set textwidth=78

	autocmd BufReadPost *ipe.tex set textwidth=120 columns=121 encoding=utf8 syntax=tex

	autocmd BufReadPost *.r,*.r3,*.red runtime indent/rebol.vim
	autocmd BufReadPost *.r,*.r3,*.red set sw=4 sts=4 syntax=rebol

	autocmd BufReadPost *.{c,h} set sw=4 sts=4 expandtab
	autocmd BufReadPost *.{c,h} map <F5> :update \| make -j8<Enter>
	autocmd BufReadPost Makefile map <F5> :update \| make -j8<Enter>

	autocmd BufReadPost *.py set sts=4 sw=4 expandtab

endif

"Function for go to specific character (in opposition to specific byte (:go)
"Taken from webpage http://superuser.com/questions/767504/how-to-go-to-the-nth-character-not-byte-of-a-file
" Written by Ingo Karat.  Thanks.
function! s:GoToCharacter( count )
    let l:save_view = winsaveview()
    " We need to include the newline position in the searches, too. The
    " newline is a character, too, and should be counted.
    let l:save_virtualedit = &virtualedit
    try
        let [l:fixPointMotion, l:searchExpr, l:searchFlags] = ['gg0', '\%#\_.\{' . (a:count + 1) . '}', 'ceW']
        silent! execute 'normal!' l:fixPointMotion

        if search(l:searchExpr, l:searchFlags) == 0
            " We couldn't reach the final destination.
            execute "normal! \<C-\>\<C-n>\<Esc>" | " Beep.
            call winrestview(l:save_view)
            return 0
        else
            return 1
        endif
    finally
        let &virtualedit = l:save_virtualedit
    endtry
endfunction
" We start at the beginning, on character number 1.
nnoremap <silent> gco :<C-u>if ! <SID>GoToCharacter(v:count1 - 1)<Bar>echoerr 'No such position'<Bar>endif<Bar><CR>


if has('mouse')
  set mouse=a
endif
" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  " I like highlighting strings inside C comments.
  " Revert with ":unlet c_comment_strings".
  let c_comment_strings=1
  set hlsearch
endif

if filereadable( $VIMRUNTIME . "/defaults.vim" )
	so $VIMRUNTIME/defaults.vim
endif

execute pathogen#infect()

au VimEnter * RainbowParenthesesToggle
au Syntax * RainbowParenthesesLoadRound
au Syntax * RainbowParenthesesLoadSquare
"au Syntax * RainbowParenthesesLoadBraces

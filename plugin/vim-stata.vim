
" Vim to Stata  
"==============================================================================
"Script Description: Run selected do-file in Stata from Vim
"Script Platform: OS X and Stata 12,13,14
"Script Version: 1.0.2 Beta
"Last Edited: 2nd December 2015
"Authors: Zizhong Yan (coding) & Chuhong Wang (testing & debugging)
"Contributors: Isaac M. E. Dodd (Linux compatibility)
"Contacts: helloyzz@gmail.com
"Configurations:
"		1, Installation
"               1.1. Option 1: Put "vim-stata.vim"(this file) to dir vimfiles/plugin or vim74/plugin
"               2.2. Option 2: Use the plugins Pathogen, Vim-Plug, or Vundle to install 
"               it from this git repository. 
"       2, To ensure that the do-files are opened in Stata by default, and hence are executed
"          directly, we need to make the following two changes.
"               2.1. Uncheck the "Edit do-files opened from the Finder in Do-file Editor"
"                       in Preference>General Preference>Windows>Do-file Editor>Advanced
"                       (Stata 13/14), or Preferences > Do-file Editor > Advanced (Stata 12).
"               2.2. Ensure the do-files are opened in Stata by default. If it is not,
"               please:
"                        Right click on any do-file under Finder > Open With > Select Stata from
"                        Applications folder > check "Always Open With" > Open.
"       3, Hotkey binding (optional)
"          The hotkey for executing selected codes is set to be F9.
"          Please note that you could customise your hotkey by adding a sentence to your .vimrc
"          or vimrc, for example:
"               :vmap <C-S-x> :<C-U>call RunDoLines()<CR><CR>
"          Then the hotkey would be changed to Ctrl+Shift+X
"       4, Restart Vim. Select a line with Visual mode (v or V), then hit F9 or the customised 
"          hotkey to run the selected codes.
"Background information: 
"       1, This plugin is motivated by the article "Some notes on text editors for Stata
"          users"  (http://fmwww.bc.edu/repec/bocode/t/textEditors.html#vim).
"          This plugin basically creates a temporary do-file, which is then sent to the 
"		   Stata to execute.
"          The Stata13+ has introduced AppleScript commands (i.e. DoCommand and 
"		   DoCommandAsync) which allow script commands to directly enter Stata without
"		   creating any temporary files. However, we did not consider this option for two 
"		   reasons:
"			i) AppleScript commands will go through all selected commands anyways even if 
"			Stata has already reported an error message. This behaves quite differently
"			from the Stata in-built do-file editor and could probably cause mistakes.
"			ii) AppleScript commands sometimes do not work properly based on our own experience 
"			and tests, though we have not figured out the reason why so far. Therefore we believe that 
"			creating a temporary do-file would be safer and more reliable, and it behaves exactly 
"			the same as what the in-built do-file editor does. The temp file is harmless since it 
"			would just be temporarily saved in a cache folder in OS X and the /tmp/ cache folder in Linux.
"       2, For Windows users, please follow the instructions in the webpage above.
"       3, This plugin has been tested on Mac OS X Yosemite and El Capitan and supports 
"          Stata 11-14SE/MP/IC. (It should also work well with Stata 11, but has not been formally 
"          tested)
"==============================================================================


" === VIM-STATA
" Default settings
	if !exists("g:vimforstata_set_column")
		let g:vimforstata_set_column = 1		" Turn on the 80th column line for .do files as in the Stata do file editor.
	endif
	
" RunDoLines() -- Takes selected lines from a do file in Vim and opens Stata to run them.
function! RunDoLines()
	
	" Determine lines selected
	let selectedLines = getbufline('%', line("'<"), line("'>"))
	
	if col("'>") < strlen(getline(line("'>")))
		let selectedLines[-1] = strpart(selectedLines[-1], 0, col("'>"))
	endif
	
	if col("'<") != 1
		let selectedLines[0] = strpart(selectedLines[0], col("'<")-1)
	endif
	
	" Create a temporary do file in the OS's temporary directory
	let temp_dofile = tempname() . ".do"  
	
	call writefile(selectedLines, temp_dofile)
	
	let path = temp_dofile

	if has("gui_running")
		let args = shellescape(path,1)." &"
	else
		let args = shellescape(path,1)." > /dev/null"
	endif

py3 << EOF
import vim
import sys
import os  
def run_yan(): 
    temp_dofile = vim.eval("temp_dofile")
    print(temp_dofile)  
    cmd = """osascript<< END
                 tell application id "{}"
                    {}
                    DoCommandAsync "do \\\"{}\\\"" with addToReview
                 end tell
                 END""".format("com.stata.stata16", "", temp_dofile)
    os.system(cmd) 
run_yan()
EOF
endfunction


 
" Map the default keys to Crl-Shift-U and F9 as a shortcut
noremap  <Plug>(RunDoLines)            :<C-U>call RunDoLines()<CR><CR>
map  <buffer> <silent> <F9>          <Plug>(RunDoLines)
"command! Vim2StataToggle call RunDoLines()<CR><CR>
 
" Credits:
"	Z Yan and C Wang - https://github.com/zizhongyan/vim-stata
"	Jeff Pitblado <jpitblado at stata.com> - Syntax Highlighting - https://github.com/jpitblado/vim-stata 
"	NERDTree Code - https://github.com/ivalkeen/nerdtree-execute/blob/master/nerdtree_plugin/execute_menuitem.vim
"	Nicholas J. Cox, et. al - http://fmwww.bc.edu/repec/bocode/t/textEditors.html#vim
" Contributors:
" 	Isaac M. E. Dodd - https://github.com/IsaacDodd/

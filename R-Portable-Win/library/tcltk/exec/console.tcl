menu .menu
toplevel .tk-R -menu .menu
wm protocol .tk-R WM_DELETE_WINDOW {}
pack [frame .tk-R.toolbar] -anchor n -fill x
pack [text .tk-R.term -bg white -font [list Courier 14]] -expand true -fill both

## Implements a "stop button" which sends SIGINT to the R process.
## Unfortunately, SIGINTs are not handled gracefully...
# pack [frame .tk-R.toolbar.stop -container true] -side right
# set stopscript $env(R_HOME)/library/tcltk/exec/stopit.tcl 
# update
# exec wish -use [winfo id .tk-R.toolbar.stop] < $stopscript [pid] &

.tk-R.term mark set insert-mark "end - 1 chars"
focus .tk-R.term

set hist {}
set nhist 0
set saved {}

bind .tk-R.term <Return> {
    .tk-R.term see end
    .tk-R.term insert end "\n"
    .tk-R.term mark set insert-mark "end - 1 chars"
    .tk-R.term mark gravity insert-mark right
    set terminput [.tk-R.term get process-mark "end - 1 chars"]
    break
}

bind .tk-R.term <Up> {
    global hist phist nhist saved
    if ($phist<=0) break
    if ($phist==$nhist) {
        set saved  [.tk-R.term get process-mark "end - 1 chars"]
    }
    .tk-R.term delete process-mark "end - 1 chars"
    incr phist -1
    .tk-R.term insert process-mark [lindex $hist $phist]
    break
}

bind .tk-R.term <Down> {
    global hist phist nhist saved
    if ($phist>=$nhist) break
    .tk-R.term delete process-mark "end - 1 chars"
    incr phist 
    if ($phist<$nhist) {
	.tk-R.term insert process-mark [lindex $hist $phist]
    } else {
	.tk-R.term insert process-mark $saved
    }
    break
}

proc Rc_read { prompt addtohistory } {
    global terminput hist nhist phist
    .tk-R.term mark set insert-mark "end - 1 chars"
    .tk-R.term mark gravity insert-mark left
    .tk-R.term insert insert-mark $prompt
    .tk-R.term mark gravity insert-mark right
    .tk-R.term mark set process-mark "end - 1 chars"
    .tk-R.term mark gravity process-mark left
    .tk-R.term see end
    set phist $nhist
    tkwait variable terminput
    .tk-R.term mark set insert end
    if ($addtohistory) then {
	lappend hist [string trimright $terminput]
	incr nhist
    }
    return $terminput
}

proc Rc_write { buf } {
    .tk-R.term insert insert-mark $buf
    .tk-R.term see end
    #.tk-R.term mark set insert end
    #update
}

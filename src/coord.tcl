############################################################################
# coord.tcl: Implements the coordinator window functions
# Author: Abhijit Das (Barda) [ad_rab@yahoo.com]
# Last updated: July 06 2002
############################################################################

############################################################################
# Copyright (C) 1998-2002 by Abhijit Das [ad_rab@yahoo.com]
#
# This file is part of BWEDIT.
#
# BWEDIT is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# BWEDIT is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with BWEDIT; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
############################################################################

. config -bg $appbg

frame .toolfr -bg $appbg -relief raised -borderwidth 2

menubutton .toolfr.file -text "File" -height 1 -relief flat \
   -menu .toolfr.file.m -bg $appbg -fg $appfg \
   -activeforeground $appfg -activebackground $appbg \
   -highlightthickness 0
menu .toolfr.file.m -tearoff false -bg $appbg -fg $appfg
.toolfr.file.m add command -label "New main window" -accelerator "Alt+1" -command "newMain" -underline 0
.toolfr.file.m add command -label "Load file in main window" -accelerator "Alt+3" -command "loadMain" -underline 0
.toolfr.file.m add separator
.toolfr.file.m add command -label "New transliterator window" -accelerator "Alt+2" -command "newRoman" -underline 4
.toolfr.file.m add command -label "Load file in transliterator window" -accelerator "Alt+4" -command "loadRoman" -underline 1
.toolfr.file.m add separator
.toolfr.file.m add command -label "Read bwencoded file" -accelerator "Alt+5" -command "readBW 0" -underline 5
.toolfr.file.m add command -label "Read MIME encoded file" -accelerator "Alt+6" -command "readMIME 0" -underline 5
.toolfr.file.m add command -label "Read uuencoded file" -accelerator "Alt+7" -command "readUU 0" -underline 5
.toolfr.file.m add separator
.toolfr.file.m add command -label "Read mail" -accelerator "F9" -command "readMail" -underline 0
.toolfr.file.m add command -label "Send mail" -accelerator "Shift+F9" -command "sendMail 0" -underline 0
.toolfr.file.m add separator
.toolfr.file.m add command -label "Quit bwedit" -accelerator "Alt+Q" -command quitEditor -underline 0

menubutton .toolfr.option -text "Option" -height 1 -relief flat \
   -menu .toolfr.option.m -bg $appbg -fg $appfg \
   -activeforeground $appfg -activebackground $appbg \
   -highlightthickness 0
menu .toolfr.option.m -tearoff false -bg $appbg -fg $appfg
.toolfr.option.m add command -label "Select document font" -accelerator "Alt+D" -command "chooseBaseFont" -underline 7
.toolfr.option.m add separator
.toolfr.option.m add command -label "Edit main window options" -command "set opttype 1 ; editOptions 0" -underline 0
.toolfr.option.m add command -label "Edit transliterator window options" -command "set opttype 2 ; editOptions 0" -underline 5
.toolfr.option.m add command -label "Edit mail options" -command "set opttype 3 ; editOptions 0" -underline 5
.toolfr.option.m add separator
.toolfr.option.m add command -label "Save options" -command "saveOptions 0" -underline 0

menubutton .toolfr.help -text "Help" -height 1 -relief flat \
   -menu .toolfr.help.m -bg $appbg -fg $appfg \
   -activeforeground $appfg -activebackground $appbg \
   -highlightthickness 0
menu .toolfr.help.m -tearoff false -bg $appbg -fg $appfg
.toolfr.help.m add command -label "View keyboard map" -accelerator "Alt+K" -command "viewKbdMap" -underline 5
.toolfr.help.m add command -label "View Bengali wordlist" -command "viewWordList" -underline 5
.toolfr.help.m add separator
.toolfr.help.m add command -label "About bwedit" -accelerator "F1" -command "helpWin" -underline 0
.toolfr.help.m add command -label "Roman-to-Bengali transliteration rules" -accelerator "Shift+F1" -command "helpWinRoman" -underline 0
.toolfr.help.m add command -label "Copyright notice" -command "copyInfo" -underline 0

label .toolfr.space -text "" -relief flat -borderwidth 0 -bg $appbg -fg $appfg

pack .toolfr.file -side left -padx 0 -pady 0
pack .toolfr.option -side left -padx 0 -pady 0
pack .toolfr.help -side left -padx 0 -pady 0
pack .toolfr.space -side left -expand yes -fill both

label .logo -image "bweditlogo" -relief flat -bg $appbg -fg $appfg -cursor hand2
bind .logo <Button-1> { copyInfo }

frame .btnfr -bg $appbg -relief flat
frame .btnfr.row1 -bg $appbg -relief flat
frame .btnfr.row2 -bg $appbg -relief flat
frame .btnfr.row3 -bg $appbg -relief flat
frame .btnfr.row4 -bg $appbg -relief flat
frame .btnfr.row5 -bg $appbg -relief flat

image create photo btnimg11 -file "$installdir/images/new1.ppm"
button .btnfr.row1.b1 -image "btnimg11" -relief raised -bg $btnbg \
   -borderwidth 3 -activebackground $btnbg -highlightthickness 0 \
   -command "newMain"
image create photo btnimg12 -file "$installdir/images/load1.ppm"
button .btnfr.row1.b2 -image "btnimg12" -relief raised -bg $btnbg \
   -borderwidth 3 -activebackground $btnbg -highlightthickness 0 \
   -command "loadMain"
image create photo btnimg13 -file "$installdir/images/option1.ppm"
button .btnfr.row1.b3 -image "btnimg13" -relief raised -bg $btnbg \
   -borderwidth 3 -activebackground $btnbg -highlightthickness 0 \
   -command "set opttype 1 ; editOptions 0"

image create photo btnimg21 -file "$installdir/images/new2.ppm"
button .btnfr.row2.b1 -image "btnimg21" -relief raised -bg $btnbg \
   -borderwidth 3 -activebackground $btnbg -highlightthickness 0 \
   -command "newRoman"
image create photo btnimg22 -file "$installdir/images/load2.ppm"
button .btnfr.row2.b2 -image "btnimg22" -relief raised -bg $btnbg \
   -borderwidth 3 -activebackground $btnbg -highlightthickness 0 \
   -command "loadRoman"
image create photo btnimg23 -file "$installdir/images/option2.ppm"
button .btnfr.row2.b3 -image "btnimg23" -relief raised -bg $btnbg \
   -borderwidth 3 -activebackground $btnbg -highlightthickness 0 \
   -command "set opttype 2 ; editOptions 0"

image create photo btnimg31 -file "$installdir/images/readBW.ppm"
button .btnfr.row3.b1 -image "btnimg31" -relief raised -bg $btnbg \
   -borderwidth 3 -activebackground $btnbg -highlightthickness 0 \
   -command "readBW 0"
image create photo btnimg32 -file "$installdir/images/readMIME.ppm"
button .btnfr.row3.b2 -image "btnimg32" -relief raised -bg $btnbg \
   -borderwidth 3 -activebackground $btnbg -highlightthickness 0 \
   -command "readMIME 0"
image create photo btnimg33 -file "$installdir/images/readUU.ppm"
button .btnfr.row3.b3 -image "btnimg33" -relief raised -bg $btnbg \
   -borderwidth 3 -activebackground $btnbg -highlightthickness 0 \
   -command "readUU 0"

image create photo btnimg41 -file "$installdir/images/mail.ppm"
button .btnfr.row4.b1 -image "btnimg41" -relief raised -bg $btnbg \
   -borderwidth 3 -activebackground $btnbg -highlightthickness 0 \
   -command "readMail"
image create photo btnimg42 -file "$installdir/images/option3.ppm"
button .btnfr.row4.b2 -image "btnimg42" -relief raised -bg $btnbg \
   -borderwidth 3 -activebackground $btnbg -highlightthickness 0 \
   -command "set opttype 3 ; editOptions 0"
image create photo btnimg43 -file "$installdir/images/dict.ppm"
button .btnfr.row4.b3 -image "btnimg43" -relief raised -bg $btnbg \
   -borderwidth 3 -activebackground $btnbg -highlightthickness 0 \
   -command "viewWordList"

image create photo btnimg51 -file "$installdir/images/kbdmap.ppm"
button .btnfr.row5.b1 -image "btnimg51" -relief raised -bg $btnbg \
   -borderwidth 3 -activebackground $btnbg -highlightthickness 0 \
   -command "viewKbdMap"
image create photo btnimg52 -file "$installdir/images/help1.ppm"
button .btnfr.row5.b2 -image "btnimg52" -relief raised -bg $btnbg \
   -borderwidth 3 -activebackground $btnbg -highlightthickness 0 \
   -command "helpWin"
image create photo btnimg53 -file "$installdir/images/help2.ppm"
button .btnfr.row5.b3 -image "btnimg53" -relief raised -bg $btnbg \
   -borderwidth 3 -activebackground $btnbg -highlightthickness 0 \
   -command "helpWinRoman"

pack .btnfr.row1.b1 .btnfr.row1.b2 .btnfr.row1.b3 -side left -padx 6 -pady 0
pack .btnfr.row2.b1 .btnfr.row2.b2 .btnfr.row2.b3 -side left -padx 6 -pady 0
pack .btnfr.row3.b1 .btnfr.row3.b2 .btnfr.row3.b3 -side left -padx 6 -pady 0
pack .btnfr.row4.b1 .btnfr.row4.b2 .btnfr.row4.b3 -side left -padx 6 -pady 0
pack .btnfr.row5.b1 .btnfr.row5.b2 .btnfr.row5.b3 -side left -padx 6 -pady 0
pack .btnfr.row1 .btnfr.row2 .btnfr.row3 .btnfr.row4 .btnfr.row5 -side top -padx 0 -pady 6
pack .toolfr -side top -padx 0 -pady 0 -fill x
pack .logo -side top -padx 0 -pady 2
pack .btnfr -side top -padx 6 -pady 6

proc quitEditor {} {
   global mavail ravail dirtybit rdirtybit

   for {set i 1} {$i < $mavail} {incr i 1} {
      if { [winfo exists .main$i] } {
         saveConfirm $i
         if {$dirtybit($i) != 0} { return } else { destroy .main$i }
         refreshAllWinList
      }
   }

   for {set i 1} {$i < $ravail} {incr i 1} {
      if { [winfo exists .roman$i] } {
         saveRomanConfirm $i
         if {$rdirtybit($i) != 0} { return } else { destroy .roman$i }
         refreshAllWinList
      }
   }

   if {[winfo exists .kbdmap]} { destroy .kbdmap }
   if {[winfo exists .help]} { destroy .help }
   if {[winfo exists .rhelp]} { destroy .rhelp }
   if {[winfo exists .copyright]} { destroy .copyright }
   if {[winfo exists .option]} { destroy .option }
   if {[winfo exists .readmail]} { destroy .readmail }
   if {[winfo exists .sendmail]} { destroy .sendmail }

   destroy .
   exit 0
}

bind . <Alt-Key-1> {newMain}
bind . <Alt-Key-2> {newRoman}
bind . <Alt-Key-3> {loadMain}
bind . <Alt-Key-4> {loadRoman}
bind . <Alt-Key-5> {readBW 0}
bind . <Alt-Key-6> {readMIME 0}
bind . <Alt-Key-7> {readUU 0}
bind . <Alt-d> {chooseBaseFont}
bind . <Alt-D> {chooseBaseFont}
bind . <Alt-k> {viewKbdMap}
bind . <Alt-K> {viewKbdMap}
bind . <Alt-q> {quitEditor; break}
bind . <Alt-Q> {quitEditor; break}
bind . <F1> {helpWin}
bind . <Shift-F1> {helpWinRoman}
bind . <F9> {readMail}
bind . <Shift-F9> {sendMail 0}
bind . <F10> {postFileMenu; break}

proc postFileMenu { } {
   set posx [winfo x .]
   incr posx [winfo x .toolfr.file]
   set posy [winfo y .]
   incr posy [winfo y .toolfr.file]
   incr posy [winfo height .toolfr.file]
   .toolfr.file.m post $posx $posy
   .toolfr.file.m activate 0
   focus .toolfr.file.m
   grab set -global .toolfr.file.m
}

proc postOptionMenu { } {
   set posx [winfo x .]
   incr posx [winfo x .toolfr.option]
   set posy [winfo y .]
   incr posy [winfo y .toolfr.option]
   incr posy [winfo height .toolfr.option]
   .toolfr.option.m post $posx $posy
   .toolfr.option.m activate 0
   focus .toolfr.option.m
   grab set -global .toolfr.option.m
}

proc postHelpMenu { } {
   set posx [winfo x .]
   incr posx [winfo x .toolfr.help]
   set posy [winfo y .]
   incr posy [winfo y .toolfr.help]
   incr posy [winfo height .toolfr.help]
   .toolfr.help.m post $posx $posy
   .toolfr.help.m activate 0
   focus .toolfr.help.m
   grab set -global .toolfr.help.m
}

bind .toolfr.file.m <Right> { grab release .toolfr.file.m; .toolfr.file.m unpost; postOptionMenu; break}
bind .toolfr.option.m <Right> { grab release .toolfr.option.m; .toolfr.option.m unpost; postHelpMenu; break}
bind .toolfr.help.m <Right> { grab release .toolfr.help.m; .toolfr.help.m unpost; postFileMenu; break}
bind .toolfr.file.m <Left> { grab release .toolfr.file.m; .toolfr.file.m unpost; postHelpMenu; break}
bind .toolfr.option.m <Left> { grab release .toolfr.option.m; .toolfr.option.m unpost; postFileMenu; break}
bind .toolfr.help.m <Left> { grab release .toolfr.help.m; .toolfr.help.m unpost; postOptionMenu; break}

wm resizable . false false
wm title . "bwedit 3.0"

set globalb ""
proc showhint { row col msg } {
   global blnbg blnfg globalb dpyfont

   if {[winfo exists $globalb]} { destroy $globalb }

   set b [toplevel .bln]
   set globalb $b

   frame $b.f1 -bg $blnfg -height 1
   frame $b.f2 -bg $blnbg
   frame $b.f3 -bg $blnfg -height 1
   label $b.f2.l -text $msg -relief flat -fg $blnfg -bg $blnbg -font $dpyfont
   frame $b.f2.lb -bg $blnfg -width 1
   frame $b.f2.rb -bg $blnfg -width 1
   pack $b.f2.lb $b.f2.l $b.f2.rb -expand yes -fill both -side left
   pack $b.f1 $b.f2 $b.f3 -expand yes -fill both

   set x [winfo x .]
   set y [winfo y .]
   incr x [winfo x .btnfr]
   incr y [winfo y .btnfr]
   incr x [winfo x .btnfr.row$row]
   incr y [winfo y .btnfr.row$row]
   incr x [winfo x .btnfr.row$row.b$col]
   incr y [winfo y .btnfr.row$row.b$col]
   incr x [expr [winfo width .btnfr.row$row.b$col] / 2]
   incr y [winfo height .btnfr.row$row.b$col]
   incr y 2

   set wd [winfo reqwidth $b.f2.l]
   incr wd 2
   set ht [winfo reqheight $b.f2.l]
   incr ht 2
   wm geometry $b "${wd}x${ht}+$x+$y"
   wm overrideredirect $b true
}

proc hidehint { } {
   global globalb

   if [winfo exists $globalb] {destroy $globalb}
}

proc addballoon { i j msg } {
   bind .btnfr.row$i.b$j <Enter> "showhint $i $j \"$msg\""
   bind .btnfr.row$i.b$j <Leave> {hidehint}
}

addballoon 1 1 "New main window"
addballoon 1 2 "Open file in main window"
addballoon 1 3 "Edit main window options"

addballoon 2 1 "New transliterator window"
addballoon 2 2 "Open file in transliterator window"
addballoon 2 3 "Edit transliterator window options"

addballoon 3 1 "Read BW encoded text"
addballoon 3 2 "Read MIME encoded text"
addballoon 3 3 "Read UU encoded text"

addballoon 4 1 "Read and send e-mail"
addballoon 4 2 "Edit mail options"
addballoon 4 3 "View Bengali wordlist"

addballoon 5 1 "Show keyboard map"
addballoon 5 2 "Launch help window"
addballoon 5 3 "Roman-to-Bengali conversion rules"

########################     End of coord.tcl    ##########################

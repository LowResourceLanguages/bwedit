############################################################################
# trans.tcl: Implements the transliterator window functions
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

proc editRoman { myid { rfnm "" } } {
   global textbg2 textfg2 textsbg2 textsfg2 textibg2 textht2 textwd2
   global olbg olfg
   global bweditlogo rfname installdir dpyfont
   global rselstart rselend
   global rdirtybit
   global appbg appfg opttype newTclTk

   set myname ".roman$myid"
   if {[winfo exists $myname]} {return}
   set rwin [toplevel $myname]
   $rwin config -bg $appbg
   wm title $rwin "bwedit: Transliterator window $myid"

   frame $rwin.cmdfr -relief raised -borderwidth 2 -bg $appbg
   frame $rwin.namefr -bg $appbg
   frame $rwin.mainfr -bg $appbg
   frame $rwin.mainfr.editfr -bg $appbg

   # Tool bar
   menubutton $rwin.cmdfr.file -text "File" -height 1 -relief flat \
      -menu $rwin.cmdfr.file.m -bg $appbg -fg $appfg -highlightthickness 0 \
      -activeforeground $appfg -activebackground $appbg
   menubutton $rwin.cmdfr.edit -text "Edit" -height 1 -relief flat \
      -menu $rwin.cmdfr.edit.m -bg $appbg -fg $appfg -highlightthickness 0 \
      -activeforeground $appfg -activebackground $appbg
   menubutton $rwin.cmdfr.transfer -text "Export" -height 1 -relief flat \
      -menu $rwin.cmdfr.transfer.m -bg $appbg -fg $appfg -highlightthickness 0 \
      -activeforeground $appfg -activebackground $appbg
   menubutton $rwin.cmdfr.mail -text "Mail" -height 1 -relief flat \
      -menu $rwin.cmdfr.mail.m -bg $appbg -fg $appfg -highlightthickness 0 \
      -activeforeground $appfg -activebackground $appbg
   menubutton $rwin.cmdfr.option -text "Option" -height 1 -relief flat \
      -menu $rwin.cmdfr.option.m -bg $appbg -fg $appfg -highlightthickness 0 \
      -activeforeground $appfg -activebackground $appbg
   menubutton $rwin.cmdfr.help -text "Help" -height 1 -relief flat \
      -menu $rwin.cmdfr.help.m -bg $appbg -fg $appfg -highlightthickness 0 \
      -activeforeground $appfg -activebackground $appbg

   menu $rwin.cmdfr.file.m -tearoff false -bg $appbg -fg $appfg
   $rwin.cmdfr.file.m add command -label "  New main window " -accelerator " Alt+1 " -command "newMain" -underline 6
   $rwin.cmdfr.file.m add command -label "  New transliterator window " -accelerator " Alt+2 " -command "newRoman" -underline 6
   $rwin.cmdfr.file.m add separator
   $rwin.cmdfr.file.m add command -label "  New file " -accelerator " Alt+N " -command "newRomanFile $myid" -underline 2
   $rwin.cmdfr.file.m add command -label "  Load file " -accelerator " F2 " -command "loadRomanFile $myid" -underline 2
   $rwin.cmdfr.file.m add command -label "  Insert file " -accelerator " Alt+I " -command "insertRomanFile $myid" -underline 2
   $rwin.cmdfr.file.m add command -label "  Append file " -accelerator " Alt+A " -command "appendRomanFile $myid" -underline 2
   $rwin.cmdfr.file.m add command -label "  Save file " -accelerator " F3 " -command "saveThisRomanFile $myid" -underline 4
   $rwin.cmdfr.file.m add command -label "  Save as file " -accelerator " Alt+S " -command "saveRomanFile $myid" -underline 2
   $rwin.cmdfr.file.m add separator
   $rwin.cmdfr.file.m add command -label "  Read encoding from file " -command "readEnc 1" -underline 2
   $rwin.cmdfr.file.m add separator
   $rwin.cmdfr.file.m add command -label "  Close " -accelerator " Alt+C " -command "closeRoman $myid" -underline 2
   $rwin.cmdfr.file.m add command -label "  Quit " -accelerator " Alt+Q " -command "quitEditor" -underline 2

   menu $rwin.cmdfr.edit.m -tearoff false -bg $appbg -fg $appfg
   $rwin.cmdfr.edit.m add command -label "  Clear  " -command "rclearTextArea $myid ; incr rdirtybit($myid) 1" -underline 2
   $rwin.cmdfr.edit.m add command -label "  Select all  " -command "rselectAll $myid " -underline 9
   $rwin.cmdfr.edit.m add separator
   $rwin.cmdfr.edit.m add command -label "  Cut  " -accelerator " F4 " -command "rcutBuffer $myid " -underline 4
   $rwin.cmdfr.edit.m add command -label "  Copy  " -accelerator " F5 " -command "rcopyBuffer $myid " -underline 5
   $rwin.cmdfr.edit.m add command -label "  Paste  " -accelerator " F6 " -command "rpasteBuffer $myid " -underline 2
   $rwin.cmdfr.edit.m add separator
   $rwin.cmdfr.edit.m add command -label "  Search  " -accelerator " F11 " -command "searchExpr $myid roman" -underline 2
   $rwin.cmdfr.edit.m add command -label "  Goto line  " -accelerator " Alt+# " -command "gotoLine $myid roman" -underline 2
   $rwin.cmdfr.edit.m add command -label "  Check spelling  " -accelerator " F12 " -command "rCheckSpell $myid" -underline 3
   $rwin.cmdfr.edit.m add command -label "  Clear spelling error marks  " -accelerator " Shift+F12 " -command "rClearSpell $myid" -underline 26

   menu $rwin.cmdfr.transfer.m -tearoff false -bg $appbg -fg $appfg
   $rwin.cmdfr.transfer.m add cascade -label "  Select target window " -menu $rwin.cmdfr.transfer.m.m -underline 2
   menu $rwin.cmdfr.transfer.m.m -tearoff false -bg $appbg -fg $appfg
   $rwin.cmdfr.transfer.m add command -label "  Transfer text to main window " -accelerator " Alt+T " -command "transferText $myid" -underline 2
   $rwin.cmdfr.transfer.m add command -label "  Transfer line to main window " -accelerator " Alt+F " -command "transferLine $myid" -underline 7
   $rwin.cmdfr.transfer.m add command -label "  Transfer selected text to main window " -accelerator " Alt+X " -command "transferSelText $myid" -underline 22
   $rwin.cmdfr.transfer.m add separator
   $rwin.cmdfr.transfer.m add command -label "  Export text to Bengali " -accelerator "Alt+B" -command "rExportBNG $myid" -underline 17
   $rwin.cmdfr.transfer.m add command -label "  Export text to HTML " -accelerator "Alt+H" -command "rExportHTML $myid" -underline 17
   $rwin.cmdfr.transfer.m add command -label "  Export text to ISCII " -accelerator "Alt+E" -command "rExportISCII $myid" -underline 2
   $rwin.cmdfr.transfer.m add command -label "  Export text to LaTeX " -accelerator "Alt+L" -command "rExportLaTeX $myid" -underline 17
   $rwin.cmdfr.transfer.m add command -label "  Export text to PostScript " -accelerator "Alt+P" -command "rExportPS $myid" -underline 17

   menu $rwin.cmdfr.mail.m -tearoff false -bg $appbg -fg $appfg
   $rwin.cmdfr.mail.m add command -label "  Read mail  " -accelerator " F9 " -command "readMail" -underline 2
   $rwin.cmdfr.mail.m add command -label "  Send mail  " -accelerator " Shift+F9 " -command "sendMail 2 $myid" -underline 2
   $rwin.cmdfr.mail.m add separator
   $rwin.cmdfr.mail.m add command -label "  Read bwencoded text  " -accelerator "Alt+5" -command "readBW 2 $myid" -underline 7
   $rwin.cmdfr.mail.m add command -label "  Read MIME encoded text  " -accelerator "Alt+6" -command "readMIME 2 $myid" -underline 7
   $rwin.cmdfr.mail.m add command -label "  Read uuencoded text  " -accelerator "Alt+7" -command "readUU 2 $myid" -underline 7
   $rwin.cmdfr.mail.m add separator
   $rwin.cmdfr.mail.m add command -label "  Edit mail options  " -command "set opttype 3; editOptions 1 $myid" -underline 2

   menu $rwin.cmdfr.option.m -tearoff false -bg $appbg -fg $appfg
   $rwin.cmdfr.option.m add command -label "  Edit options " -accelerator " Alt+O " -command " set opttype 2 ; editOptions 2 $myid " -underline 7
   $rwin.cmdfr.option.m add command -label "  Save options  " -command " saveOptions 2 $myid " -underline 2

   menu $rwin.cmdfr.help.m -tearoff false -bg $appbg -fg $appfg
   $rwin.cmdfr.help.m add command -label "  Show Keyboard map " -accelerator " Alt+K " -command {viewKbdMap} -underline 7
   $rwin.cmdfr.help.m add command -label "  Show Bengali wordlist " -command {viewWordList} -underline 15
   $rwin.cmdfr.help.m add separator
   $rwin.cmdfr.help.m add command -label "  About bwedit  " -accelerator " F1 " -command {helpWin} -underline 2
   $rwin.cmdfr.help.m add command -label "  Roman-to-Bengali conversion rules  " -accelerator " Shift+F1 " -command {helpWinRoman} -underline 2
   $rwin.cmdfr.help.m add command -label "  Copyright notice  " -command {copyInfo} -underline 2

   label $rwin.cmdfr.blank -text "" -relief flat -bg $appbg -fg $appfg
   label $rwin.cmdfr.logo -image "bweditlogo" -relief flat -bg $appbg -fg $appfg -cursor hand2
   bind $rwin.cmdfr.logo <Button-1> { copyInfo }

   # File name
   label $rwin.namefr.lbl -text " File name: " -relief flat -foreground $appfg -background $appbg
   entry $rwin.namefr.ent -textvariable "rfname($myid)" -relief sunken \
      -background #ffb6c1 -foreground #000000 \
      -selectbackground #000000 -selectforeground #ffb6c1 -selectborderwidth 0
   bind $rwin.namefr.ent <Return> "focus $rwin.mainfr.editfr.textarea"

   # Edit area
   text $rwin.mainfr.editfr.textarea -relief sunken -height $textht2 -width $textwd2 \
      -font $dpyfont -wrap none -relief flat \
      -xscroll "$rwin.mainfr.hscroll set" -yscroll "$rwin.mainfr.editfr.scrbar set" \
      -insertbackground $textibg2 -insertwidth 3 \
      -background $textbg2 -foreground $textfg2 -borderwidth 2 \
      -selectbackground $textsbg2 -selectforeground $textsfg2 -selectborderwidth 0
   scrollbar $rwin.mainfr.editfr.scrbar -relief sunken -orient vertical \
      -command "$rwin.mainfr.editfr.textarea yview" -bg $appbg -width 12 \
      -activebackground $appbg
   $rwin.mainfr.editfr.textarea tag config spe1 -background "#FFFFFF" -foreground "#0000ff"
   $rwin.mainfr.editfr.textarea tag config spe2 -background "#FFFFFF" -foreground "#ff0000"
   $rwin.mainfr.editfr.textarea tag config spe4 -background "#FFFFFF" -foreground "#00aa00"

   # Horizontal scrollbar
   scrollbar $rwin.mainfr.hscroll -relief sunken -orient horizontal \
      -command "$rwin.mainfr.editfr.textarea xview" -bg $appbg -width 12 \
      -activebackground $appbg

   # Online view
   if ($newTclTk) {
      text $rwin.mainfr.olview -bg $olbg -fg $olfg -state disabled \
         -height 1 -width 120 -relief flat -selectforeground $olfg \
         -font "-*-bengali2-medium-r-*-*-*-120-*-*-*-*-iso10646-1" \
         -selectbackground $olbg -selectborder 0 -spacing3 3 \
         -xscroll "$rwin.mainfr.hscroll2 set" -wrap none
   } else {
      text $rwin.mainfr.olview -bg $olbg -fg $olfg -state disabled \
         -height 1 -width 80 -relief flat -selectforeground $olfg \
         -font "-*-bengali-medium-r-*-*-*-120-*-*-*-*-*-fontspecific" \
         -selectbackground $olbg -selectborder 0 -spacing3 3 \
         -xscroll "$rwin.mainfr.hscroll2 set" -wrap none
   }
   $rwin.mainfr.olview tag config english -font $dpyfont
   scrollbar $rwin.mainfr.hscroll2 -relief sunken -orient horizontal \
      -command "$rwin.mainfr.olview xview" -bg $appbg -width 12 \
      -activebackground $appbg

   pack $rwin.cmdfr.file $rwin.cmdfr.edit $rwin.cmdfr.transfer \
      $rwin.cmdfr.mail $rwin.cmdfr.option $rwin.cmdfr.help \
      -side left -padx 4 -pady 0 -side left
   pack $rwin.cmdfr.blank -side left -expand yes -fill both
   pack $rwin.cmdfr.logo -side left -padx 5 -pady 0 -side left
   pack $rwin.namefr.lbl -side left -padx 0 -pady 0
   pack $rwin.namefr.ent -side left -padx 0 -pady 0 -expand yes -fill x
   pack $rwin.mainfr.editfr.scrbar -fill y -side right -padx 0 -pady 0
   pack $rwin.mainfr.editfr.textarea -expand yes -fill both -side right -padx 0 -pady 0
   pack $rwin.mainfr.hscroll2 -padx 0 -pady 0 -fill x -side bottom
   pack $rwin.mainfr.olview -padx 0 -pady 0 -fill x -side bottom
   pack $rwin.mainfr.hscroll -padx 0 -pady 0 -fill x -side bottom
   pack $rwin.mainfr.editfr -padx 0 -pady 0 -expand yes -fill both -side bottom
   pack $rwin.cmdfr -padx 0 -pady 0 -fill x
   pack $rwin.namefr -padx 5 -pady 5 -fill x
   pack $rwin.mainfr -padx 0 -pady 0 -expand yes -fill both

   focus $rwin.mainfr.editfr.textarea

   tkwait visibility $rwin
   refreshAllWinList
   set rfnm [string trim $rfnm]
   if {[string length $rfnm] > 0} { loadThisRomanFile $myid $rfnm }

   bind $rwin.mainfr.editfr.textarea <Any-KeyRelease> "setbnstr $myid"
   bind $rwin.mainfr.editfr.textarea <ButtonRelease-1> "setbnstr $myid"

   # Function key bindings
   bind $rwin <F1> "helpWin"
   bind $rwin <Shift-F1> "helpWinRoman"
   bind $rwin <F2> "loadRomanFile $myid"
   bind $rwin <F3> "saveThisRomanFile $myid"
   bind $rwin <F4> "rcutBuffer $myid"
   bind $rwin <F5> "rcopyBuffer $myid"
   bind $rwin <F6> "rpasteBuffer $myid"
   set rselstart($myid) ""
   set rselend($myid) ""
   bind $rwin.mainfr.editfr.textarea <F7> "rmarkbegin $myid"
   bind $rwin.mainfr.editfr.textarea <F8> "rmarkend $myid"
   bind $rwin <F9> "readMail"
   bind $rwin <Shift-F9> "sendMail 2 $myid"
   bind $rwin <F10> "ractivateFileMenu $myid ; break"
   bind $rwin <F11> "searchExpr $myid roman"
   bind $rwin <F12> "rCheckSpell $myid"
   bind $rwin <Shift-F12> "rClearSpell $myid"

   # Alt + key bindings
   bind $rwin <Alt-Key-1> "newMain"
   bind $rwin <Alt-Key-2> "newRoman"
   bind $rwin <Alt-Key-5> "readBW 2 $myid"
   bind $rwin <Alt-Key-6> "readMIME 2 $myid"
   bind $rwin <Alt-Key-7> "readUU 2 $myid"
   bind $rwin <Alt-a> "appendRomanFile $myid"
   bind $rwin <Alt-A> "appendRomanFile $myid"
   bind $rwin <Alt-b> "rExportBNG $myid"
   bind $rwin <Alt-B> "rExportBNG $myid"
   bind $rwin <Alt-c> "closeRoman $myid; break"
   bind $rwin <Alt-C> "closeRoman $myid; break"
   bind $rwin <Alt-e> "rExportISCII $myid"
   bind $rwin <Alt-E> "rExportISCII $myid"
   bind $rwin <Alt-f> "transferLine $myid"
   bind $rwin <Alt-F> "transferLine $myid"
   bind $rwin <Alt-h> "rExportHTML $myid"
   bind $rwin <Alt-H> "rExportHTML $myid"
   bind $rwin <Alt-i> "insertRomanFile $myid"
   bind $rwin <Alt-I> "insertRomanFile $myid"
   bind $rwin <Alt-k> "viewKbdMap"
   bind $rwin <Alt-K> "viewKbdMap"
   bind $rwin <Alt-l> "rExportLaTeX $myid"
   bind $rwin <Alt-L> "rExportLaTeX $myid"
   bind $rwin <Alt-n> "newFile $myid"
   bind $rwin <Alt-N> "newFile $myid"
   bind $rwin <Alt-o> "set opttype 2 ; editOptions 1 $myid"
   bind $rwin <Alt-O> "set opttype 2 ; editOptions 1 $myid"
   bind $rwin <Alt-p> "rExportPS $myid"
   bind $rwin <Alt-P> "rExportPS $myid"
   bind $rwin <Alt-q> "quitEditor; break"
   bind $rwin <Alt-Q> "quitEditor; break"
   bind $rwin <Alt-s> "saveRomanFile $myid"
   bind $rwin <Alt-S> "saveRomanFile $myid"
   bind $rwin <Alt-t> "transferText $myid"
   bind $rwin <Alt-T> "transferText $myid"
   bind $rwin <Alt-x> "transferSelText $myid"
   bind $rwin <Alt-X> "transferSelText $myid"
   bind $rwin <Alt-Key-numbersign> "gotoLine $myid roman"

   # Dirty bit
   bind $rwin.mainfr.editfr.textarea <Any-Key> "rprocKey $myid %A"
   bind $rwin.mainfr.editfr.textarea <Alt-Key> { }
   bind $rwin.mainfr.editfr.textarea <Control-Key> { }
   bind $rwin.mainfr.editfr.textarea <BackSpace> " incr rdirtybit($myid) 1 "
   bind $rwin.mainfr.editfr.textarea <Control-h> " incr rdirtybit($myid) 1 "
   bind $rwin.mainfr.editfr.textarea <Delete> " incr rdirtybit($myid) 1 "
   bind $rwin.mainfr.editfr.textarea <Control-d> " incr rdirtybit($myid) 1 "
   bind $rwin.mainfr.editfr.textarea <Meta-d> " incr rdirtybit($myid) 1 "
   bind $rwin.mainfr.editfr.textarea <Control-k> " incr rdirtybit($myid) 1 "
   bind $rwin.mainfr.editfr.textarea <Control-o> " incr rdirtybit($myid) 1 "
   bind $rwin.mainfr.editfr.textarea <Control-w> " incr rdirtybit($myid) 1 "
   bind $rwin.mainfr.editfr.textarea <Control-x> " incr rdirtybit($myid) 1 "
   bind $rwin.mainfr.editfr.textarea <Control-t> " incr rdirtybit($myid) 1 "

   # Menu bindings
   bind $rwin.cmdfr.file.m <Right> " grab release $rwin.cmdfr.file.m; $rwin.cmdfr.file.m unpost; ractivateEditMenu $myid ; break "
   bind $rwin.cmdfr.edit.m <Right> " grab release $rwin.cmdfr.edit.m; $rwin.cmdfr.edit.m unpost; ractivateTransferMenu $myid ; break "
   bind $rwin.cmdfr.transfer.m <Right> " grab release $rwin.cmdfr.transfer.m; $rwin.cmdfr.transfer.m unpost; ractivateMailMenu $myid ; break "
   bind $rwin.cmdfr.mail.m <Right> " grab release $rwin.cmdfr.mail.m; $rwin.cmdfr.mail.m unpost; ractivateOptionMenu $myid ; break "
   bind $rwin.cmdfr.option.m <Right> " grab release $rwin.cmdfr.option.m; $rwin.cmdfr.option.m unpost; ractivateHelpMenu $myid ; break "
   bind $rwin.cmdfr.help.m <Right> " grab release $rwin.cmdfr.help.m; $rwin.cmdfr.help.m unpost; ractivateFileMenu $myid ; break "
   bind $rwin.cmdfr.file.m <Left> " grab release $rwin.cmdfr.file.m; $rwin.cmdfr.file.m unpost; ractivateHelpMenu $myid ; break "
   bind $rwin.cmdfr.edit.m <Left> " grab release $rwin.cmdfr.edit.m; $rwin.cmdfr.edit.m unpost; ractivateFileMenu $myid ; break "
   bind $rwin.cmdfr.transfer.m <Left> " grab release $rwin.cmdfr.transfer.m; $rwin.cmdfr.transfer.m unpost; ractivateEditMenu $myid ; break "
   bind $rwin.cmdfr.mail.m <Left> " grab release $rwin.cmdfr.mail.m; $rwin.cmdfr.mail.m unpost; ractivateTransferMenu $myid ; break "
   bind $rwin.cmdfr.option.m <Left> " grab release $rwin.cmdfr.option.m; $rwin.cmdfr.option.m unpost; ractivateMailMenu $myid ; break "
   bind $rwin.cmdfr.help.m <Left> " grab release $rwin.cmdfr.help.m; $rwin.cmdfr.help.m unpost; ractivateOptionMenu $myid ; break "

   # Control + key bindings
   bind $rwin.mainfr.editfr.textarea <Control-Delete> " rdelword $myid ; break "
   bind $rwin.mainfr.editfr.textarea <Control-BackSpace> " rbsword $myid ; break "
   bind $rwin.mainfr.editfr.textarea <Control-w> " rdeltotalword $myid ; break "
   bind $rwin.mainfr.editfr.textarea <Control-j> " rjoinword $myid ; break "

   bind $rwin.mainfr.editfr.textarea <Control-Shift-Delete> " rdelline $myid ; break "
   bind $rwin.mainfr.editfr.textarea <Control-Shift-BackSpace> " rbsline $myid ; break "
   bind $rwin.mainfr.editfr.textarea <Control-L> " rdeltotalline $myid ; break "
   bind $rwin.mainfr.editfr.textarea <Control-J> " rjoinline $myid ; break "

   # Mouse bindings
   menu $rwin.b2m  -tearoff false -bg $appbg -fg $appfg
   $rwin.b2m add command -label " Cut " -command "rcutBuffer $myid"
   $rwin.b2m add command -label " Copy " -command "rcopyBuffer $myid"
   $rwin.b2m add command -label " Paste " -command "rpasteBuffer $myid"
   $rwin.b2m add separator
   $rwin.b2m add command -label " Transfer text " -command "transferText $myid"
   $rwin.b2m add command -label " Transfer line " -command "transferLine $myid"
   $rwin.b2m add command -label " Transfer selection " -command "transferSelText $myid"
   $rwin.b2m add separator
   $rwin.b2m add command -label " Conversion rules " -command {helpwinRoman}

   menu $rwin.b3m  -tearoff false -bg $appbg -fg $appfg
   $rwin.b3m add command -label " Load file " -command "loadRomanFile $myid"
   $rwin.b3m add command -label " Save file " -command "saveThisRomanFile $myid"
   $rwin.b3m add command -label " Save as file " -command "saveRomanFile $myid"
   $rwin.b3m add separator
   $rwin.b3m add command -label " Send mail " -command "sendMail 2 $myid"
   $rwin.b3m add command -label " Read bwencoded file " -command "readBW 2 $myid"
   $rwin.b3m add command -label " Read MIME encoded file " -command "readMIME 2 $myid"
   $rwin.b3m add command -label " Read uuencoded file " -command "readUU 2 $myid"
   $rwin.b3m add separator
   $rwin.b3m add command -label " Close " -command "closeRoman $myid"
   $rwin.b3m add command -label " Quit " -command "quitEditor"

   bind $rwin.mainfr.editfr.textarea <ButtonPress-2> "
      $rwin.b2m post %X %Y
      $rwin.b2m activate 0
      grab set -global $rwin.b2m
   "
   bind $rwin.mainfr.editfr.textarea <ButtonPress-3> "
      $rwin.b3m post %X %Y
      $rwin.b3m activate 0
      grab set -global $rwin.b3m
   "
}

proc rprocKey { myid A } {
   global rdirtybit

   if { ([string compare $A " "] >= 0) && ([string compare $A "~"] <= 0) } {
      incr rdirtybit($myid) 1
   }
   if {![string compare $A "\t"]} { incr rdirtybit($myid) 1 }
   if {![string compare $A "\n"]} { incr rdirtybit($myid) 1 }
   if {![string compare $A "\r"]} { incr rdirtybit($myid) 1 }
   if {![string compare $A "\f"]} { incr rdirtybit($myid) 1 }
}

proc rdelword { myid } {
   global rdirtybit

   set rwin ".roman$myid"
   $rwin.mainfr.editfr.textarea delete "insert" "insert wordend"
   incr rdirtybit($myid) 1
}

proc rbsword { myid } {
   global rdirtybit

   set rwin ".roman$myid"
   $rwin.mainfr.editfr.textarea delete "insert - 1 chars wordstart" "insert"
   incr rdirtybit($myid) 1
}

proc rdeltotalword { myid } {
   global rdirtybit

   set rwin ".roman$myid"
   $rwin.mainfr.editfr.textarea delete "insert wordstart" "insert wordend"
   incr rdirtybit($myid) 1
}

proc rjoinword { myid } {
   global rdirtybit

   set rwin ".roman$myid"
   switch -exact [$rwin.mainfr.editfr.textarea get [$rwin.mainfr.editfr.textarea index "insert wordend"]] {
      "\n" {
         $rwin.mainfr.editfr.textarea delete "insert wordend" "insert wordend + 1 chars"
         incr rdirtybit($myid) 1
      }
      "\t" {
         $rwin.mainfr.editfr.textarea delete "insert wordend" "insert wordend + 1 chars"
         incr rdirtybit($myid) 1
      }
      " " {
         $rwin.mainfr.editfr.textarea delete "insert wordend" "insert wordend + 1 chars"
         incr rdirtybit($myid) 1
      }
   }
}

proc rdelline { myid } {
   global rdirtybit

   set rwin ".roman$myid"
   $rwin.mainfr.editfr.textarea delete "insert" "insert lineend"
   incr rdirtybit($myid) 1
}

proc rbsline { myid } {
   global rdirtybit

   set rwin ".roman$myid"
   $rwin.mainfr.editfr.textarea delete "insert linestart" "insert"
   incr rdirtybit($myid) 1
}

proc rdeltotalline { myid } {
   global rdirtybit

   set rwin ".roman$myid"
   $rwin.mainfr.editfr.textarea delete "insert linestart" "insert + 1 lines linestart"
   incr rdirtybit($myid) 1
}

proc rjoinline { myid } {
   global rdirtybit

   set rwin ".roman$myid"
   $rwin.mainfr.editfr.textarea delete "insert lineend" "insert + 1 lines linestart"
   incr rdirtybit($myid) 1
}

proc ractivateFileMenu { myid } {
   set rwin ".roman$myid"
   set posx [winfo x $rwin]
   incr posx [winfo x $rwin.cmdfr.file]
   set posy [winfo y $rwin]
   incr posy [winfo y $rwin.cmdfr.file]
   incr posy [winfo height $rwin.cmdfr.file]
   $rwin.cmdfr.file.m post $posx $posy
   $rwin.cmdfr.file.m activate 0
   grab set -global $rwin.cmdfr.file.m
   focus $rwin.cmdfr.file.m
}

proc ractivateEditMenu { myid } {
   set rwin ".roman$myid"
   set posx [winfo x $rwin]
   incr posx [winfo x $rwin.cmdfr.edit]
   set posy [winfo y $rwin]
   incr posy [winfo y $rwin.cmdfr.edit]
   incr posy [winfo height $rwin.cmdfr.edit]
   $rwin.cmdfr.edit.m post $posx $posy
   $rwin.cmdfr.edit.m activate 0
   grab set -global $rwin.cmdfr.edit.m
   focus $rwin.cmdfr.edit.m
}

proc ractivateTransferMenu { myid } {
   set rwin ".roman$myid"
   set posx [winfo x $rwin]
   incr posx [winfo x $rwin.cmdfr.transfer]
   set posy [winfo y $rwin]
   incr posy [winfo y $rwin.cmdfr.transfer]
   incr posy [winfo height $rwin.cmdfr.transfer]
   $rwin.cmdfr.transfer.m post $posx $posy
   $rwin.cmdfr.transfer.m activate 0
   grab set -global $rwin.cmdfr.transfer.m
   focus $rwin.cmdfr.transfer.m
}

proc ractivateOptionMenu { myid } {
   set rwin ".roman$myid"
   set posx [winfo x $rwin]
   incr posx [winfo x $rwin.cmdfr.option]
   set posy [winfo y $rwin]
   incr posy [winfo y $rwin.cmdfr.option]
   incr posy [winfo height $rwin.cmdfr.option]
   $rwin.cmdfr.option.m post $posx $posy
   $rwin.cmdfr.option.m activate 0
   grab set -global $rwin.cmdfr.option.m
   focus $rwin.cmdfr.option.m
}

proc ractivateMailMenu { myid } {
   set rwin ".roman$myid"
   set posx [winfo x $rwin]
   incr posx [winfo x $rwin.cmdfr.mail]
   set posy [winfo y $rwin]
   incr posy [winfo y $rwin.cmdfr.mail]
   incr posy [winfo height $rwin.cmdfr.mail]
   $rwin.cmdfr.mail.m post $posx $posy
   $rwin.cmdfr.mail.m activate 0
   grab set -global $rwin.cmdfr.mail.m
   focus $rwin.cmdfr.mail.m
}

proc ractivateHelpMenu { myid } {
   set rwin ".roman$myid"
   set posx [winfo x $rwin]
   incr posx [winfo x $rwin.cmdfr.help]
   set posy [winfo y $rwin]
   incr posy [winfo y $rwin.cmdfr.help]
   incr posy [winfo height $rwin.cmdfr.help]
   $rwin.cmdfr.help.m post $posx $posy
   $rwin.cmdfr.help.m activate 0
   grab set -global $rwin.cmdfr.help.m
   focus $rwin.cmdfr.help.m
}

proc rmarkbegin { myid } {
   global rselstart

   set rwin ".roman$myid"
   set lsel [$rwin.mainfr.editfr.textarea tag ranges sel]
   if {([llength $lsel] == 2)} {
      $rwin.mainfr.editfr.textarea tag remove sel [lindex $lsel 0] [lindex $lsel 1]
   }
   set rselstart($myid) [$rwin.mainfr.editfr.textarea index insert]
}

proc rmarkend { myid } {
   global rselstart rselend

   set rwin ".roman$myid"
   if {[string length $rselstart($myid)] > 0} {
      set lsel [$rwin.mainfr.editfr.textarea tag ranges sel]
      if {[llength $lsel] == 2} {
         $rwin.mainfr.editfr.textarea tag remove sel [lindex $lsel 0] [lindex $lsel 1]
      }
      set rselend($myid) [$rwin.mainfr.editfr.textarea index insert]
      if {[$rwin.mainfr.editfr.textarea compare $rselstart($myid) <= $rselend($myid)]} {
         $rwin.mainfr.editfr.textarea tag add sel $rselstart($myid) $rselend($myid)
      } else {
         $rwin.mainfr.editfr.textarea tag add sel $rselend($myid) $rselstart($myid)
      }
   }
   set rselstart($myid) ""
   set rselend($myid) ""
}

proc newRomanFile { myid } {
   global rfname rdirtybit

   set rwin ".roman$myid"
   saveRomanConfirm $myid; if {$rdirtybit($myid) != 0} { return }
   rclearTextArea $myid
   set rfname($myid) ""
   setbnstr $myid
}

proc loadThisRomanFile { myid fn } {
   global rfname rdirtybit

   set rwin ".roman$myid"
   saveRomanConfirm $myid; if {$rdirtybit($myid) != 0} { return }
   set fn [string trim $fn]
   if {[string compare $fn ""] != 0} {
      if {![file readable $fn]} {
         errmsg2 $myid "ERROR:\nI cannot load the file \"$fn\". The file does not exist or does not have read permission."
         return
      }
      if {![file isfile $fn]} {
         errmsg2 $myid "ERROR:\nI cannot load the file. \"$fn\" is not a regular file."
         return
      }
      set f [open $fn r]
      set x [read $f]
      close $f
      $rwin.mainfr.editfr.textarea delete 1.0 end
      $rwin.mainfr.editfr.textarea insert 1.0 $x
      $rwin.mainfr.editfr.textarea see insert
      focus $rwin.mainfr.editfr.textarea
      set rfname($myid) $fn
      set rdirtybit($myid) 0
      setbnstr $myid
   }
}

proc loadRomanFile { myid } {
   global rfname rdirtybit

   set rwin ".roman$myid"
   saveRomanConfirm $myid; if {$rdirtybit($myid) != 0} { return }
   set fn [getFileName "bwedit: Load Roman file"]
   if {[string compare $fn ""] != 0} {
      if {![file readable $fn]} {
         errmsg2 $myid "ERROR:\nI cannot load the file \"$fn\". The file does not exist or does not have read permission."
         return
      }
      if {![file isfile $fn]} {
         errmsg2 $myid "ERROR:\nI cannot load the file. \"$fn\" is not a regular file."
         return
      }
      set f [open $fn r]
      set x [read $f]
      $rwin.mainfr.editfr.textarea delete 1.0 end
      $rwin.mainfr.editfr.textarea insert 1.0 $x
      close $f
      set rfname($myid) $fn
      $rwin.mainfr.editfr.textarea see insert
      set rdirtybit($myid) 0
      setbnstr $myid
   }
}

proc insertRomanFile { myid } {
   global rdirtybit

   set rwin ".roman$myid"
   set fn [getFileName "bwedit: Insert Roman file"]
   if {[string compare $fn ""] != 0} {
      if {![file readable $fn]} {
         errmsg2 $myid "ERROR:\nI cannot load the file \"$fn\". The file does not exist or does not have read permission."
         return
      }
      if {![file isfile $fn]} {
         errmsg2 $myid "ERROR:\nI cannot load the file. \"$fn\" is not a regular file."
         return
      }
      set f [open $fn r]
      set x [read $f]
      close $f
      $rwin.mainfr.editfr.textarea insert insert $x
      $rwin.mainfr.editfr.textarea see insert
      incr rdirtybit($myid) 1
      setbnstr $myid
   }
}

proc appendRomanFile { myid } {
   global rdirtybit

   set rwin ".roman$myid"
   set fn [getFileName "bwedit: Append Roman file"]
   if {[string compare $fn ""] != 0} {
      if {![file readable $fn]} {
         errmsg2 $myid "ERROR:\nI cannot load the file \"$fn\". The file does not exist or does not have read permission."
         return
      }
      if {![file isfile $fn]} {
         errmsg2 $myid "ERROR:\nI cannot load the file. \"$fn\" is not a regular file."
         return
      }
      set f [open $fn r]
      set x [read $f]
      close $f
      $rwin.mainfr.editfr.textarea insert end $x
      $rwin.mainfr.editfr.textarea see insert
      incr rdirtybit($myid) 1
      setbnstr $myid
   }
}

proc saveThisRomanFile { myid } {
   global rfname rdirtybit

   set rwin ".roman$myid"
   set rfname($myid) [string trim $rfname($myid)]
   set fnm $rfname($myid)
   if {![string compare "" $fnm]} {
      errmsg2 $myid "ERROR:\nI cannot save file. No file name is given."
      return
   }
   set dnm [file dirname $fnm]
   if {![file isdirectory $dnm]} {
      errmsg2 $myid "ERROR:\nI cannot save the file. \"$dnm\" is not a directory."
      return
   }
   if {![file writable $dnm]} {
      errmsg2 $myid "ERROR:\nI cannot save the file. You do not have permission to write in the directory \"$dnm\"."
      return
   }
   if {[file exists $fnm] && ![file isfile $fnm]} {
      errmsg2 $myid "ERROR:\nI cannot save the file. \"$fnm\" is not a regular file."
      return
   }
   if {[file exists $fnm] && ![file writable $fnm]} {
      errmsg2 $myid "ERROR:\nI cannot save the file. You do not have permission to overwrite \"$fnm\""
      return
   }
   set f [open $fnm w]
   set x [$rwin.mainfr.editfr.textarea get 1.0 end]
   puts -nonewline $f $x
   close $f
   set rdirtybit($myid) 0
   errmsg2 $myid "$fnm saved"
}

proc saveRomanFile { myid } {
   global rfname rdirtybit

   set rwin ".roman$myid"
   set fnm [getFileName "bwedit: Save Roman file"]
   if {![string compare "" $fnm]} { return }
   set dnm [file dirname $fnm]
   if {![file isdirectory $dnm]} {
      errmsg2 $myid "ERROR:\nI cannot save the file. \"$dnm\" is not a directory."
      return
   }
   if {![file writable $dnm]} {
      errmsg2 $myid "ERROR:\nI cannot save the file. You do not have permission to write in the directory \"$dnm\"."
      return
   }
   if {[file exists $fnm] && ![file isfile $fnm]} {
      errmsg2 $myid "ERROR:\nI cannot save the file. \"$fnm\" is not a regular file."
      return
   }
   if {[file exists $fnm] && ![file writable $fnm]} {
      errmsg2 $myid "ERROR:\nI cannot save the file. You do not have permission to overwrite \"$fnm\""
      return
   }
   set f [open $fnm w]
   set x [$rwin.mainfr.editfr.textarea get 1.0 end]
   puts -nonewline $f $x
   close $f
   set rdirtybit($myid) 0
   if {![string compare $rfname($myid) ""]} { set rfname($myid) $fnm }
   errmsg2 $myid "$fnm saved"
}

proc rclearTextArea { myid } {
   .roman$myid.mainfr.editfr.textarea delete 1.0 end
}

proc rselectAll { myid } {
   .roman$myid.mainfr.editfr.textarea tag add sel 1.0 end
}

set rbuffer ""

proc rcutBuffer { myid } {
   global rbuffer rdirtybit

   set rwin ".roman$myid"
   set lsel [$rwin.mainfr.editfr.textarea tag ranges sel]
   if {[llength $lsel] != 2} {
      errmsg2 $myid "Text does not contain a selected region. Select text by left mouse button and retry."
      return
   }

   incr rdirtybit($myid) 1
   set rbuffer [$rwin.mainfr.editfr.textarea get sel.first sel.last]
   $rwin.mainfr.editfr.textarea delete sel.first sel.last
   $rwin.mainfr.editfr.textarea see insert
   setbnstr $myid
}

proc rcopyBuffer { myid } {
   global rbuffer

   set rwin ".roman$myid"
   set lsel [$rwin.mainfr.editfr.textarea tag ranges sel]
   if {[llength $lsel] != 2} {
      errmsg2 $myid "Text does not contain a selected region. Select text by left mouse button and retry."
      return
   }

   set rbuffer [$rwin.mainfr.editfr.textarea get sel.first sel.last]
}

proc rpasteBuffer { myid } {
   global rbuffer rdirtybit

   set rwin ".roman$myid"
   $rwin.mainfr.editfr.textarea insert insert $rbuffer
   incr rdirtybit($myid) 1
   setbnstr $myid
   $rwin.mainfr.editfr.textarea see insert
}

proc transferText { myid } {
   global ttargetWin dirtybit

   set mwin ".main$ttargetWin"
   set rwin ".roman$myid"

   if {[winfo exists $mwin]} {
      set ipstr "[$rwin.mainfr.editfr.textarea get 1.0 end]"
      romanToBeng $ipstr $mwin.mainfr.editfr.textarea
      $mwin.mainfr.editfr.textarea see insert
      incr dirtybit($ttargetWin) 1
   }
}

proc transferLine { myid } {
   global ttargetWin dirtybit

   set mwin ".main$ttargetWin"
   set rwin ".roman$myid"

   if {[winfo exists $mwin]} {
      set ipstr "[$rwin.mainfr.editfr.textarea get "insert linestart" "insert lineend"]\n"
      romanToBeng $ipstr $mwin.mainfr.editfr.textarea
      $mwin.mainfr.editfr.textarea see insert
      incr dirtybit($ttargetWin) 1
   }
}

proc transferSelText { myid } {
   global ttargetWin dirtybit

   set mwin ".main$ttargetWin"
   set rwin ".roman$myid"
   set lsel [$rwin.mainfr.editfr.textarea tag ranges sel]
   if {[llength $lsel] != 2} {
      errmsg2 $myid "Text does not contain a selected region. Select text by left mouse button and retry."
      return
   }
   if {[winfo exists $mwin]} {
      set ipstr "[$rwin.mainfr.editfr.textarea get sel.first sel.last]\n"
      romanToBeng $ipstr $mwin.mainfr.editfr.textarea
      $mwin.mainfr.editfr.textarea see insert
      incr dirtybit($ttargetWin) 1
   }
}

proc setbnstr { myid } {
   set ipstr "[.roman$myid.mainfr.editfr.textarea get "insert linestart" "insert lineend"] "
   .roman$myid.mainfr.olview config -state normal
   .roman$myid.mainfr.olview delete 1.0 end
   romanToBeng $ipstr .roman$myid.mainfr.olview
   .roman$myid.mainfr.olview config -state disabled
}

set srcwinid -1
proc saveRomanConfirm { myid } {
   global srcwin rdirtybit btnbg btnfg srcwinid srccancel

   set rwin ".roman$myid"
   if {[winfo exists $srcwinid]} {focus $scrwinid; tkwait variable rdirtybit($myid); return}
   set srccancel 0
   while {($rdirtybit($myid) != 0) && ($srccancel == 0)} {
      set srcwin [toplevel .src]
      set srcwinid $srcwin
      $srcwin config -background #004466
      label $srcwin.l -text "Unsaved changes in transliterator window $myid" -fg #ffffff -bg #006688
      frame $srcwin.bfr -bg #004466
      button $srcwin.bfr.b1 -text "Save" -command "saveThisRomanFile $myid" -underline 0 \
         -bg $btnbg -fg $btnfg -activebackground $btnbg -activeforeground $btnfg \
         -relief raised
      button $srcwin.bfr.b2 -text "Save as" -command "saveRomanFile $myid" -underline 5 \
         -bg $btnbg -fg $btnfg -activebackground $btnbg -activeforeground $btnfg \
         -relief raised
      button $srcwin.bfr.b3 -text "Do not save" -command "set rdirtybit($myid) 0" -underline 3 \
         -bg $btnbg -fg $btnfg -activebackground $btnbg -activeforeground $btnfg \
         -relief raised
      button $srcwin.bfr.b4 -text "Cancel" -command "set rdirtybit($myid) $rdirtybit($myid); set srccancel 1" -underline 0 \
         -bg $btnbg -fg $btnfg -activebackground $btnbg -activeforeground $btnfg \
         -relief raised
      pack $srcwin.l -expand yes -fill both -padx 0 -pady 0
      pack $srcwin.bfr.b1 $srcwin.bfr.b2 $srcwin.bfr.b3 $srcwin.bfr.b4 -side left -padx 10 -pady 0
      pack $srcwin.bfr -expand no -padx 0 -pady 10

      bind $srcwin <Key-S> "saveThisRomanFile $myid"
      bind $srcwin <Key-A> "saveRomanFile $myid"
      bind $srcwin <Key-N> "set rdirtybit($myid) 0"
      bind $srcwin <Key-C> "set rdirtybit($myid) $rdirtybit($myid); set srccancel 1"
      bind $srcwin <Key-s> "saveThisRomanFile $myid"
      bind $srcwin <Key-a> "saveRomanFile $myid"
      bind $srcwin <Key-n> "set rdirtybit($myid) 0"
      bind $srcwin <Key-c> "set rdirtybit($myid) $rdirtybit($myid); set srccancel 1"

      wm transient $srcwin $rwin
      wm title $srcwin "Options for unsaved changes"
      set posx [winfo x $rwin]
      set posy [winfo y $rwin]
      incr posx [winfo x $rwin.mainfr]
      incr posy [winfo y $rwin.mainfr]
      set twd [winfo width $rwin.mainfr.editfr.textarea]
      set tht [winfo height $rwin.mainfr.editfr.textarea]
      set ewd1 [winfo reqwidth $srcwin.l]
      set ewd2 [expr [winfo reqwidth $srcwin.bfr.b1] + \
                     [winfo reqwidth $srcwin.bfr.b2] + \
                     [winfo reqwidth $srcwin.bfr.b3] + \
                     [winfo reqwidth $srcwin.bfr.b4] + 100]
      if {$ewd1 > $ewd2} { set ewd $ewd1 } else { set ewd $ewd2 }
      set eht [expr [winfo reqheight $srcwin.l] + [winfo reqheight $srcwin.bfr.b1] + 40]
      set posx [expr $posx + ($twd - $ewd) / 2]
      set posy [expr $posy + ($tht - $eht) / 2]
      if {$posx <= 0} { set posx 0 }
      if {$posy <= 0} { set posy 0 }
      wm geometry $srcwin "${ewd}x${eht}+$posx+$posy"
      focus $srcwin

      grab $srcwin
      tkwait variable rdirtybit($myid)
      grab release $srcwin
      destroy $srcwin
      set srcwinid -1
   }
}

proc errmsg2 { myid msg } {
   global btnbg btnfg

   set rwin ".roman$myid"
   set ewin [toplevel .error]

   message $ewin.msg -text $msg -relief flat -bg #006688 -fg #ffffff -width 250 -justify center
   button $ewin.btn -text "Ok" -relief raised -fg $btnfg -bg $btnbg \
          -activeforeground $btnfg -activebackground $btnbg \
          -command {set edone 1} -height 0

   pack $ewin.msg -padx 0 -pady 0 -expand yes -fill both
   pack $ewin.btn -pady 10

   bind $ewin <Escape> {set edone 1}
   bind $ewin <Return> {set edone 1}

   $ewin config -bg #004466

   wm transient $ewin $rwin
   set posx [winfo x $rwin]
   set posy [winfo y $rwin]
   incr posx [winfo x $rwin.mainfr]
   incr posy [winfo y $rwin.mainfr]
   set twd [winfo width $rwin.mainfr.editfr.textarea]
   set tht [winfo height $rwin.mainfr.editfr.textarea]
   set ewd [winfo reqwidth $ewin.msg]
   set eht [expr [winfo reqheight $ewin.msg] + [winfo reqheight $ewin.btn] + 40]
   set posx [expr $posx + ($twd - $ewd) / 2]
   set posy [expr $posy + ($tht - $eht) / 2]
   if {$posx <= 0} { set posx 0 }
   if {$posy <= 0} { set posy 0 }
   wm geometry $ewin "${ewd}x${eht}+$posx+$posy"
   wm title $ewin "Diagnostic message"

   grab $ewin
   tkwait variable edone
   grab release $ewin
   destroy $ewin
}

set ravail 1
proc newRoman { } {
   global ravail rdirtybit rfname

   set rdirtybit($ravail) 0
   set rfname($ravail) ""
   incr ravail 1
   editRoman [expr $ravail - 1]
   return [expr $ravail - 1]
}

proc loadRoman { } {
   global ravail rdirtybit rfname

   set rdirtybit($ravail) 0
   set rfname($ravail) ""
   incr ravail 1
   editRoman [expr $ravail - 1] [getFileName "Load Roman file"]
   return [expr $ravail - 1]
}

proc loadRoman2 { fnm } {
   global ravail rdirtybit rfname

   set rdirtybit($ravail) 0
   set rfname($ravail) ""
   incr ravail 1
   editRoman [expr $ravail - 1] $fnm
   return [expr $ravail - 1]
}

proc closeRoman { myid } {
   global rdirtybit

   set rwin ".roman$myid"
   saveRomanConfirm $myid; if { $rdirtybit($myid) != 0 } { return }
   destroy $rwin
   refreshAllWinList
}

########################     End of trans.tcl    ##########################

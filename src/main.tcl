############################################################################
# main.tcl: Implements the main window functions
# Author: Abhijit Das (Barda) [ad_rab@yahoo.com]
# Last updated: October 04 2002
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

proc editMain { myid {fnm ""} } {
   global appbg appfg btnbg btnfg dirtybit opttype bweditlogo
   global textbg textfg textsbg textsfg textibg textht textwd ptsize slant textsp3
   global fname customfontno selstart selend asciimode ascin newTclTk

   set myname ".main$myid"
   if {[winfo exists $myname]} {return}
   set mwin [toplevel $myname]
   $mwin config -bg $appbg
   wm title $mwin "bwedit: Main editor window $myid"

   frame $mwin.cmdfr -relief raised -borderwidth 2 -bg $appbg
   frame $mwin.namefr -bg $appbg
   frame $mwin.mainfr -bg $appbg
   frame $mwin.mainfr.editfr -bg $appbg

   # Tool bar
   menubutton $mwin.cmdfr.file -text "File" -height 1 -relief flat \
      -menu $mwin.cmdfr.file.m -bg $appbg -fg $appfg -highlightthickness 0 \
      -activeforeground $appfg -activebackground $appbg
   menubutton $mwin.cmdfr.edit -text "Edit" -height 1 -relief flat \
      -menu $mwin.cmdfr.edit.m -bg $appbg -fg $appfg -highlightthickness 0 \
      -activeforeground $appfg -activebackground $appbg
   menubutton $mwin.cmdfr.tag -text "Tag" -height 1 -relief flat \
      -menu $mwin.cmdfr.tag.m -bg $appbg -fg $appfg -highlightthickness 0 \
      -activeforeground $appfg -activebackground $appbg
   menubutton $mwin.cmdfr.import -text "Import" -height 1 -relief flat \
      -menu $mwin.cmdfr.import.m -bg $appbg -fg $appfg -highlightthickness 0 \
      -activeforeground $appfg -activebackground $appbg
   menubutton $mwin.cmdfr.export -text "Export" -height 1 -relief flat \
      -menu $mwin.cmdfr.export.m -bg $appbg -fg $appfg -highlightthickness 0 \
      -activeforeground $appfg -activebackground $appbg
   menubutton $mwin.cmdfr.mail -text "Mail" -height 1 -relief flat \
      -menu $mwin.cmdfr.mail.m -bg $appbg -fg $appfg -highlightthickness 0 \
      -activeforeground $appfg -activebackground $appbg
   menubutton $mwin.cmdfr.option -text "Option" -height 1 -relief flat \
      -menu $mwin.cmdfr.option.m -bg $appbg -fg $appfg -highlightthickness 0 \
      -activeforeground $appfg -activebackground $appbg
   menubutton $mwin.cmdfr.help -text "Help" -height 1 -relief flat \
      -menu $mwin.cmdfr.help.m -bg $appbg -fg $appfg -highlightthickness 0 \
      -activeforeground $appfg -activebackground $appbg

   menu $mwin.cmdfr.file.m -tearoff false -bg $appbg -fg $appfg
   $mwin.cmdfr.file.m add command -label "  New main window " -accelerator " Alt+1 " -command "newMain" -underline 6
   $mwin.cmdfr.file.m add command -label "  New transliterator window " -accelerator " Alt+2 " -command "newRoman" -underline 6
   $mwin.cmdfr.file.m add separator
   $mwin.cmdfr.file.m add command -label "  New file " -accelerator " Alt+N " -command "newFile $myid" -underline 2
   $mwin.cmdfr.file.m add command -label "  Load file " -accelerator " F2 " -command "loadFile $myid" -underline 2
   $mwin.cmdfr.file.m add command -label "  Insert file " -accelerator " Alt+I " -command "insertFile $myid" -underline 2
   $mwin.cmdfr.file.m add command -label "  Append file " -accelerator " Alt+A " -command "appendFile $myid" -underline 2
   $mwin.cmdfr.file.m add command -label "  Save file " -accelerator " F3 " -command "saveThisFile $myid" -underline 4
   $mwin.cmdfr.file.m add command -label "  Save as file " -accelerator " Alt+S " -command "saveFile $myid" -underline 2
   $mwin.cmdfr.file.m add separator
   $mwin.cmdfr.file.m add command -label "  Close " -accelerator " Alt+C " -command "closeMain $myid" -underline 2
   $mwin.cmdfr.file.m add command -label "  Quit " -accelerator " Alt+Q " -command "quitEditor" -underline 2

   menu $mwin.cmdfr.edit.m -tearoff false -bg $appbg -fg $appfg
   $mwin.cmdfr.edit.m add command -label "  Clear  " -command "clearTextArea $myid ; incr dirtybit($myid)" -underline 2
   $mwin.cmdfr.edit.m add command -label "  Select all  " -command "selectAll $myid" -underline 9
   $mwin.cmdfr.edit.m add separator
   $mwin.cmdfr.edit.m add command -label "  Cut  " -accelerator " F4 " -command "cutBuffer $myid" -underline 4
   $mwin.cmdfr.edit.m add command -label "  Copy  " -accelerator " F5 " -command "copyBuffer $myid" -underline 5
   $mwin.cmdfr.edit.m add command -label "  Paste  " -accelerator " F6 " -command "pasteBuffer $myid" -underline 2
   $mwin.cmdfr.edit.m add separator
   $mwin.cmdfr.edit.m add command -label "  Search  " -accelerator " F11 " -command "searchExpr $myid" -underline 2
   $mwin.cmdfr.edit.m add command -label "  Goto line  " -accelerator " Alt + # " -command "gotoLine $myid" -underline 2

   menu $mwin.cmdfr.tag.m -tearoff false -bg $appbg -fg $appfg
   $mwin.cmdfr.tag.m add command -label "  Normal  " -command "normalSel $myid" -underline 2
   $mwin.cmdfr.tag.m add command -label "  Underline  " -command "ulSel $myid" -underline 2
   $mwin.cmdfr.tag.m add command -label "  Superscript  " -command "supSel $myid" -underline 4
   $mwin.cmdfr.tag.m add command -label "  Supersuperscript  " -command "supsupSel $myid" -underline 5
   $mwin.cmdfr.tag.m add command -label "  Subsuperscript  " -command "subsupSel $myid" -underline 9
   $mwin.cmdfr.tag.m add command -label "  Subscript  " -command "subSel $myid" -underline 4
   $mwin.cmdfr.tag.m add command -label "  Subsubscript  " -command "subsubSel $myid" -underline 9
   $mwin.cmdfr.tag.m add command -label "  Supersubscript  " -command "supsubSel $myid" -underline 15
   $mwin.cmdfr.tag.m add command -label "  Select font  " -command "fontSel $myid" -underline 9
   $mwin.cmdfr.tag.m add separator
   $mwin.cmdfr.tag.m add command -label "  Load tags  " -accelerator " Alt+G " -command "loadTags $myid" -underline 2
   $mwin.cmdfr.tag.m add command -label "  Save tags  " -accelerator " Alt+V " -command "saveTags $myid" -underline 4

   menu $mwin.cmdfr.import.m -tearoff false -bg $appbg -fg $appfg
   $mwin.cmdfr.import.m add command -label "  Read encoding from file " -command {readEnc 1} -underline 2
   $mwin.cmdfr.import.m add separator
   $mwin.cmdfr.import.m add command -label "  Load transliterated roman file  " -accelerator " Alt+T" -command "importRoman $myid 0" -underline 2
   $mwin.cmdfr.import.m add command -label "  Insert transliterated roman file  " -accelerator " Alt+R" -command "importRoman $myid 1" -underline 2
   $mwin.cmdfr.import.m add command -label "  Append transliterated roman file  " -command "importRoman $myid 2" -underline 2
   $mwin.cmdfr.import.m add separator
   $mwin.cmdfr.import.m add command -label "  Roman-to-Bengali transliteration rules  " -accelerator " Shift+F1 " -command {helpWinRoman} -underline 19

   menu $mwin.cmdfr.export.m -tearoff false -bg $appbg -fg $appfg
   $mwin.cmdfr.export.m add command -label "  To HTML  " -accelerator " Alt+H " -command "exportHTML $myid" -underline 5
   $mwin.cmdfr.export.m add command -label "  To LaTeX  " -accelerator " Alt+L " -command "exportLaTeX $myid" -underline 5
   $mwin.cmdfr.export.m add command -label "  To PostScript  " -accelerator " Alt+P " -command "exportPS $myid" -underline 5

   menu $mwin.cmdfr.mail.m -tearoff false -bg $appbg -fg $appfg
   $mwin.cmdfr.mail.m add command -label "  Read mail  " -accelerator " F9 " -command "readMail" -underline 2
   $mwin.cmdfr.mail.m add command -label "  Send mail  " -accelerator " Shift+F9 " -command "sendMail 1 $myid" -underline 2
   $mwin.cmdfr.mail.m add separator
   $mwin.cmdfr.mail.m add command -label "  Read bwencoded text  " -accelerator "Alt+5" -command "readBW 1 $myid" -underline 7
   $mwin.cmdfr.mail.m add command -label "  Read MIME-encoded text  "  -accelerator "Alt+6" -command "readMIME 1 $myid" -underline 7
   $mwin.cmdfr.mail.m add command -label "  Read uuencoded text  " -accelerator "Alt+7" -command "readUU 1 $myid" -underline 7
   $mwin.cmdfr.mail.m add separator
   $mwin.cmdfr.mail.m add command -label "  Edit mail options  " -command "set opttype 3; editOptions 1 $myid" -underline 2

   menu $mwin.cmdfr.option.m -tearoff false -bg $appbg -fg $appfg
   $mwin.cmdfr.option.m add command -label "  Select document font " -accelerator " Alt+D " -command {chooseBaseFont} -underline 9
   $mwin.cmdfr.option.m add separator
   $mwin.cmdfr.option.m add command -label "  Edit options " -accelerator " Alt+O " -command " set opttype 1 ; editOptions 1 $myid " -underline 7
   $mwin.cmdfr.option.m add command -label "  Save options  " -command " saveOptions 1 $myid " -underline 2

   menu $mwin.cmdfr.help.m -tearoff false -bg $appbg -fg $appfg
   $mwin.cmdfr.help.m add command -label "  Show Keyboard map " -accelerator " Alt+K " -command {viewKbdMap} -underline 7
   $mwin.cmdfr.help.m add command -label "  Show Bengali wordlist " -command {viewWordList} -underline 7
   $mwin.cmdfr.help.m add separator
   $mwin.cmdfr.help.m add command -label "  About bwedit  " -accelerator " F1 " -command {helpWin} -underline 2
   $mwin.cmdfr.help.m add command -label "  Copyright notice  " -command {copyInfo} -underline 2

   label $mwin.cmdfr.blank -text "" -relief flat -bg $appbg -fg $appfg
   label $mwin.cmdfr.logo -image "bweditlogo" -relief flat -bg $appbg -fg $appfg -cursor hand2
   bind $mwin.cmdfr.logo <Button-1> { copyInfo }

   # File name
   label $mwin.namefr.lbl -text " File name: " -relief flat -foreground $appfg -background $appbg
   entry $mwin.namefr.ent -textvariable "fname($myid)" -relief sunken \
      -background #ffb6c1 -foreground #000000 \
      -selectbackground #000000 -selectforeground #ffb6c1 -selectborderwidth 0
   bind $mwin.namefr.ent <Return> "focus $mwin.mainfr.editfr.textarea"

   # Edit area
   if ($newTclTk) {
      text $mwin.mainfr.editfr.textarea -relief sunken -height $textht -width $textwd \
         -font "-*-bengali2-medium-$slant-*-*-*-$ptsize-*-*-*-*-iso10646-1" \
         -xscroll "$mwin.mainfr.hscroll set" -yscroll "$mwin.mainfr.editfr.scrbar set" \
         -wrap none -spacing3 $textsp3 -relief flat \
         -insertbackground $textibg -insertwidth 3 \
         -background $textbg -foreground $textfg -borderwidth 2 \
         -selectbackground $textsbg -selectforeground $textsfg -selectborderwidth 0
   } else {
      text $mwin.mainfr.editfr.textarea -relief sunken -height $textht -width $textwd \
         -font "-*-bengali-medium-$slant-*-*-*-$ptsize-*-*-*-*-*-fontspecific" \
         -xscroll "$mwin.mainfr.hscroll set" -yscroll "$mwin.mainfr.editfr.scrbar set" \
         -wrap none -spacing3 $textsp3 -relief flat \
         -insertbackground $textibg -insertwidth 3 \
         -background $textbg -foreground $textfg -borderwidth 2 \
         -selectbackground $textsbg -selectforeground $textsfg -selectborderwidth 0
   }
   scrollbar $mwin.mainfr.editfr.scrbar -relief sunken -orient vertical \
      -command "$mwin.mainfr.editfr.textarea yview" -bg $appbg -width 12 \
      -activebackground $appbg

   # Horizontal scrollbar
   scrollbar $mwin.mainfr.hscroll -relief sunken -orient horizontal \
      -command "$mwin.mainfr.editfr.textarea xview" -bg $appbg -width 12 \
      -activebackground $appbg

   pack $mwin.cmdfr.file $mwin.cmdfr.edit $mwin.cmdfr.tag $mwin.cmdfr.import \
      $mwin.cmdfr.export $mwin.cmdfr.mail $mwin.cmdfr.option $mwin.cmdfr.help \
      -side left -padx 4 -pady 0 -side left
   pack $mwin.cmdfr.blank -side left -expand yes -fill both
   pack $mwin.cmdfr.logo -side left -padx 5 -pady 0 -side left
   pack $mwin.namefr.lbl -side left -padx 0 -pady 0
   pack $mwin.namefr.ent -side left -padx 0 -pady 0 -expand yes -fill x
   pack $mwin.mainfr.editfr.scrbar -fill y -side right -padx 0 -pady 0
   pack $mwin.mainfr.editfr.textarea -expand yes -fill both -side right -padx 0 -pady 0
   pack $mwin.mainfr.hscroll -padx 0 -pady 0 -fill x -side bottom
   pack $mwin.mainfr.editfr -padx 0 -pady 0 -expand yes -fill both -side bottom
   pack $mwin.cmdfr -padx 0 -pady 0 -fill x
   pack $mwin.namefr -padx 5 -pady 5 -fill x
   pack $mwin.mainfr -padx 0 -pady 0 -expand yes -fill both

   configTags $myid
   set fnm [string trim $fnm]
   if {[string length $fnm] > 0} { tkwait visibility $mwin ; loadThisFile $myid $fnm }

   focus $mwin.mainfr.editfr.textarea
   refreshAllWinList

   # Function key bindings
   bind $mwin <F1> "helpWin"
   bind $mwin <Shift-F1> "helpWinRoman"
   bind $mwin <F2> "loadFile $myid"
   bind $mwin <F3> "saveThisFile $myid"
   bind $mwin <F4> "cutBuffer $myid"
   bind $mwin <F5> "copyBuffer $myid"
   bind $mwin <F6> "pasteBuffer $myid"
   set selstart($myid) ""
   set selend($myid) ""
   bind $mwin.mainfr.editfr.textarea <F7> "markbegin $myid ; break"
   bind $mwin.mainfr.editfr.textarea <F8> "markend $myid ; break"
   bind $mwin <F9> "readMail"
   bind $mwin <Shift-F9> "sendMail 1 $myid"
   bind $mwin <F10> "activateFileMenu $myid ; break"
   bind $mwin <F11> "searchExpr $myid"
   bind $mwin <Alt-Key-numbersign> "gotoLine $myid; break"

   # Alt + key bindings
   bind $mwin <Alt-Key-1> "newMain"
   bind $mwin <Alt-Key-2> "newRoman"
   bind $mwin <Alt-Key-5> "readBW 1 $myid"
   bind $mwin <Alt-Key-6> "readMIME 1 $myid"
   bind $mwin <Alt-Key-7> "readUU 1 $myid"
   bind $mwin <Alt-a> "appendFile $myid"
   bind $mwin <Alt-A> "appendFile $myid"
   bind $mwin <Alt-c> "closeMain $myid; break"
   bind $mwin <Alt-C> "closeMain $myid; break"
   bind $mwin <Alt-d> "chooseBaseFont"
   bind $mwin <Alt-D> "chooseBaseFont"
   bind $mwin <Alt-g> "loadTags $myid"
   bind $mwin <Alt-G> "loadTags $myid"
   bind $mwin <Alt-h> "exportHTML $myid"
   bind $mwin <Alt-H> "exportHTML $myid"
   bind $mwin <Alt-i> "insertFile $myid"
   bind $mwin <Alt-I> "insertFile $myid"
   bind $mwin <Alt-k> "viewKbdMap"
   bind $mwin <Alt-K> "viewKbdMap"
   bind $mwin <Alt-l> "exportLaTeX $myid"
   bind $mwin <Alt-L> "exportLaTeX $myid"
   bind $mwin <Alt-n> "newFile $myid"
   bind $mwin <Alt-N> "newFile $myid"
   bind $mwin <Alt-o> "set opttype 1 ; editOptions 1 $myid"
   bind $mwin <Alt-O> "set opttype 1 ; editOptions 1 $myid"
   bind $mwin <Alt-p> "exportPS $myid"
   bind $mwin <Alt-P> "exportPS $myid"
   bind $mwin <Alt-q> "quitEditor; break"
   bind $mwin <Alt-Q> "quitEditor; break"
   bind $mwin <Alt-r> "importRoman $myid 1"
   bind $mwin <Alt-R> "importRoman $myid 1"
   bind $mwin <Alt-s> "saveFile $myid"
   bind $mwin <Alt-S> "saveFile $myid"
   bind $mwin <Alt-t> "importRoman $myid 0"
   bind $mwin <Alt-T> "importRoman $myid 0"
   bind $mwin <Alt-v> "saveTags $myid"
   bind $mwin <Alt-V> "saveTags $myid"

   # Escape binding
   set asciimode($myid) 0
   set ascin($myid) ""
   for {set i 0} {$i < 10} {incr i 1} {
      bind .main$myid.mainfr.editfr.textarea <Key-$i> "
         [ list eval if (\$asciimode($myid)) \{ set ascin($myid) \$ascin($myid)%A \; break \} else \{ incr dirtybit($myid) \; procKey $myid $i \; break \} ]
      "
      bind .main$myid.mainfr.editfr.textarea <Alt-Key-$i> { }
   }
   bind $mwin.mainfr.editfr.textarea <Escape> "procEsc $myid ; break"

   # Dirty bit
   bind $mwin.mainfr.editfr.textarea <Any-Key> "
      if { ([string compare %A " "] >= 0) && ([string compare %A "~"] <= 0) } {
         procKey $myid %A
         break
      }
   "

   bind $mwin.mainfr.editfr.textarea <Alt_L> { }
   bind $mwin.mainfr.editfr.textarea <Alt_R> { }
   bind $mwin.mainfr.editfr.textarea <Meta_L> { }
   bind $mwin.mainfr.editfr.textarea <Meta_R> { }
   bind $mwin.mainfr.editfr.textarea <Alt-Any-Key> { }
   bind $mwin.mainfr.editfr.textarea <Control_L> { }
   bind $mwin.mainfr.editfr.textarea <Control_R> { }
   bind $mwin.mainfr.editfr.textarea <Shift_L> { }
   bind $mwin.mainfr.editfr.textarea <Shift_R> { }
   bind $mwin.mainfr.editfr.textarea <Super_L> { }
   bind $mwin.mainfr.editfr.textarea <Super_R> { }
   bind $mwin.mainfr.editfr.textarea <Hyper_L> { }
   bind $mwin.mainfr.editfr.textarea <Hyper_R> { }
   bind $mwin.mainfr.editfr.textarea <Caps_Lock> { }
   bind $mwin.mainfr.editfr.textarea <Shift_Lock> { }
   bind $mwin.mainfr.editfr.textarea <Insert> { break }
   bind $mwin.mainfr.editfr.textarea <Num_Lock> { }
   bind $mwin.mainfr.editfr.textarea <Print> { break }
   bind $mwin.mainfr.editfr.textarea <Sys_Req> { break }
   bind $mwin.mainfr.editfr.textarea <Scroll_Lock> { break }
   bind $mwin.mainfr.editfr.textarea <Pause> { break }
   bind $mwin.mainfr.editfr.textarea <Break> { break }
   bind $mwin.mainfr.editfr.textarea <KP_Enter> " $mwin.mainfr.editfr.textarea insert insert {\n} ; incr dirtybit($myid) ; break "
   bind $mwin.mainfr.editfr.textarea <KP_Home> { break }
   bind $mwin.mainfr.editfr.textarea <KP_Page_Up> { break }
   bind $mwin.mainfr.editfr.textarea <KP_Page_Down> { break }
   bind $mwin.mainfr.editfr.textarea <KP_Begin> { break }
   bind $mwin.mainfr.editfr.textarea <KP_End> { break }
   bind $mwin.mainfr.editfr.textarea <KP_Up> { break }
   bind $mwin.mainfr.editfr.textarea <KP_Down> { break }
   bind $mwin.mainfr.editfr.textarea <KP_Left> { break }
   bind $mwin.mainfr.editfr.textarea <KP_Right> { break }
   bind $mwin.mainfr.editfr.textarea <KP_Insert> { break }
   bind $mwin.mainfr.editfr.textarea <KP_Delete> { break }

   bind $mwin.mainfr.editfr.textarea <Control-Any-Key> { }
   bind $mwin.mainfr.editfr.textarea <BackSpace> " incr dirtybit($myid) "
   bind $mwin.mainfr.editfr.textarea <Delete> " incr dirtybit($myid) "
   bind $mwin.mainfr.editfr.textarea <Return> " incr dirtybit($myid) "
   bind $mwin.mainfr.editfr.textarea <Tab> " incr dirtybit($myid) "
   bind $mwin.mainfr.editfr.textarea <Up> { }
   bind $mwin.mainfr.editfr.textarea <Down> { }
   bind $mwin.mainfr.editfr.textarea <Left> { }
   bind $mwin.mainfr.editfr.textarea <Right> { }
   bind $mwin.mainfr.editfr.textarea <Home> { }
   bind $mwin.mainfr.editfr.textarea <End> { }
   bind $mwin.mainfr.editfr.textarea <Page_Up> { }
   bind $mwin.mainfr.editfr.textarea <Page_Down> { }
   bind $mwin.mainfr.editfr.textarea <Control-h> " incr dirtybit($myid) "
   bind $mwin.mainfr.editfr.textarea <Control-d> " incr dirtybit($myid) "
   bind $mwin.mainfr.editfr.textarea <Meta-d> " incr dirtybit($myid) "
   bind $mwin.mainfr.editfr.textarea <Control-k> " incr dirtybit($myid) "
   bind $mwin.mainfr.editfr.textarea <Control-o> " incr dirtybit($myid) "
   bind $mwin.mainfr.editfr.textarea <Control-w> " incr dirtybit($myid) "
   bind $mwin.mainfr.editfr.textarea <Control-x> " incr dirtybit($myid) "
   bind $mwin.mainfr.editfr.textarea <Control-t> " incr dirtybit($myid) "
   bind $mwin.mainfr.editfr.textarea <F1> { }
   bind $mwin.mainfr.editfr.textarea <Shift-F1> { }
   bind $mwin.mainfr.editfr.textarea <F2> { }
   bind $mwin.mainfr.editfr.textarea <F3> { }
   bind $mwin.mainfr.editfr.textarea <F4> { }
   bind $mwin.mainfr.editfr.textarea <F5> { }
   bind $mwin.mainfr.editfr.textarea <F6> { }
   bind $mwin.mainfr.editfr.textarea <F9> { }
   bind $mwin.mainfr.editfr.textarea <Shift-F9> { }
   bind $mwin.mainfr.editfr.textarea <F10> { }
   bind $mwin.mainfr.editfr.textarea <F11> { }
   bind $mwin.mainfr.editfr.textarea <F12> { }

   # Menu bindings
   bind $mwin.cmdfr.file.m <Right> " grab release $mwin.cmdfr.file.m; $mwin.cmdfr.file.m unpost; activateEditMenu $myid ; break "
   bind $mwin.cmdfr.edit.m <Right> " grab release $mwin.cmdfr.edit.m; $mwin.cmdfr.edit.m unpost; activateTagMenu $myid ; break "
   bind $mwin.cmdfr.tag.m <Right> " grab release $mwin.cmdfr.tag.m; $mwin.cmdfr.tag.m unpost; activateImportMenu $myid ; break "
   bind $mwin.cmdfr.import.m <Right> " grab release $mwin.cmdfr.import.m; $mwin.cmdfr.import.m unpost; activateExportMenu $myid ; break "
   bind $mwin.cmdfr.export.m <Right> " grab release $mwin.cmdfr.export.m; $mwin.cmdfr.export.m unpost; activateMailMenu $myid ; break "
   bind $mwin.cmdfr.mail.m <Right> " grab release $mwin.cmdfr.mail.m; $mwin.cmdfr.mail.m unpost; activateOptionMenu $myid ; break "
   bind $mwin.cmdfr.option.m <Right> " grab release $mwin.cmdfr.option.m; $mwin.cmdfr.option.m unpost; activateHelpMenu $myid ; break "
   bind $mwin.cmdfr.help.m <Right> " grab release $mwin.cmdfr.help.m; $mwin.cmdfr.help.m unpost; activateFileMenu $myid ; break "
   bind $mwin.cmdfr.file.m <Left> " grab release $mwin.cmdfr.file.m; $mwin.cmdfr.file.m unpost; activateHelpMenu $myid ; break "
   bind $mwin.cmdfr.edit.m <Left> " grab release $mwin.cmdfr.edit.m; $mwin.cmdfr.edit.m unpost; activateFileMenu $myid ; break "
   bind $mwin.cmdfr.tag.m <Left> " grab release $mwin.cmdfr.tag.m; $mwin.cmdfr.tag.m unpost; activateEditMenu $myid ; break "
   bind $mwin.cmdfr.import.m <Left> " grab release $mwin.cmdfr.import.m; $mwin.cmdfr.import.m unpost; activateTagMenu $myid ; break "
   bind $mwin.cmdfr.export.m <Left> " grab release $mwin.cmdfr.export.m; $mwin.cmdfr.export.m unpost; activateImportMenu $myid ; break "
   bind $mwin.cmdfr.mail.m <Left> " grab release $mwin.cmdfr.mail.m; $mwin.cmdfr.mail.m unpost; activateExportMenu $myid ; break "
   bind $mwin.cmdfr.option.m <Left> " grab release $mwin.cmdfr.option.m; $mwin.cmdfr.option.m unpost; activateMailMenu $myid ; break "
   bind $mwin.cmdfr.help.m <Left> " grab release $mwin.cmdfr.help.m; $mwin.cmdfr.help.m unpost; activateOptionMenu $myid ; break "

   # Control + key bindings
   bind $mwin.mainfr.editfr.textarea <Control-Delete> " delword $myid ; break "
   bind $mwin.mainfr.editfr.textarea <Control-BackSpace> " bsword $myid ; break "
   bind $mwin.mainfr.editfr.textarea <Control-w> " deltotalword $myid ; break "
   bind $mwin.mainfr.editfr.textarea <Control-j> " joinword $myid ; break "

   bind $mwin.mainfr.editfr.textarea <Control-Shift-Delete> " delline $myid ; break "
   bind $mwin.mainfr.editfr.textarea <Control-Shift-BackSpace> " bsline $myid ; break "
   bind $mwin.mainfr.editfr.textarea <Control-L> " deltotalline $myid ; break "
   bind $mwin.mainfr.editfr.textarea <Control-J> " joinline $myid ; break "

   if ($newTclTk) {
      bind $mwin.mainfr.editfr.textarea <Control-a> " $mwin.mainfr.editfr.textarea insert insert [encfrom a]; incr dirtybit($myid); break "
      bind $mwin.mainfr.editfr.textarea <Control-A> " $mwin.mainfr.editfr.textarea insert insert [encfrom aA]; incr dirtybit($myid); break "
      bind $mwin.mainfr.editfr.textarea <Control-i> " $mwin.mainfr.editfr.textarea insert insert [encfrom [format %c 1]]; incr dirtybit($myid); break "
      bind $mwin.mainfr.editfr.textarea <Control-I> " $mwin.mainfr.editfr.textarea insert insert [encfrom [format %c 2]]; incr dirtybit($myid); break "
      bind $mwin.mainfr.editfr.textarea <Control-u> " $mwin.mainfr.editfr.textarea insert insert [encfrom [format %c 3]]; incr dirtybit($myid); break "
      bind $mwin.mainfr.editfr.textarea <Control-U> " $mwin.mainfr.editfr.textarea insert insert [encfrom [format %c 4]]; incr dirtybit($myid); break "
      bind $mwin.mainfr.editfr.textarea <Control-R> " $mwin.mainfr.editfr.textarea insert insert [encfrom [format %c 5]]; incr dirtybit($myid); break "
      bind $mwin.mainfr.editfr.textarea <Control-e> " $mwin.mainfr.editfr.textarea insert insert [encfrom [format %c 6]]; incr dirtybit($myid); break "
      bind $mwin.mainfr.editfr.textarea <Control-E> " $mwin.mainfr.editfr.textarea insert insert [encfrom [format %c 7]]; incr dirtybit($myid); break "
      bind $mwin.mainfr.editfr.textarea <Control-o> " $mwin.mainfr.editfr.textarea insert insert [encfrom [format %c 8]]; incr dirtybit($myid); break "
      bind $mwin.mainfr.editfr.textarea <Control-O> " $mwin.mainfr.editfr.textarea insert insert [encfrom o]; incr dirtybit($myid); break "
      bind $mwin.mainfr.editfr.textarea <Control-y> " $mwin.mainfr.editfr.textarea insert insert [encfrom [format %c 14]]; incr dirtybit($myid); break "
      bind $mwin.mainfr.editfr.textarea <Control-r> " $mwin.mainfr.editfr.textarea insert insert [encfrom [format %c 15]]; incr dirtybit($myid); break "
   } else {
      bind $mwin.mainfr.editfr.textarea <Control-a> " $mwin.mainfr.editfr.textarea insert insert {a}; incr dirtybit($myid); break "
      bind $mwin.mainfr.editfr.textarea <Control-A> " $mwin.mainfr.editfr.textarea insert insert {aA}; incr dirtybit($myid); break "
      bind $mwin.mainfr.editfr.textarea <Control-i> " $mwin.mainfr.editfr.textarea insert insert [format %c 1]; incr dirtybit($myid); break "
      bind $mwin.mainfr.editfr.textarea <Control-I> " $mwin.mainfr.editfr.textarea insert insert [format %c 2]; incr dirtybit($myid); break "
      bind $mwin.mainfr.editfr.textarea <Control-u> " $mwin.mainfr.editfr.textarea insert insert [format %c 3]; incr dirtybit($myid); break "
      bind $mwin.mainfr.editfr.textarea <Control-U> " $mwin.mainfr.editfr.textarea insert insert [format %c 4]; incr dirtybit($myid); break "
      bind $mwin.mainfr.editfr.textarea <Control-R> " $mwin.mainfr.editfr.textarea insert insert [format %c 5]; incr dirtybit($myid); break "
      bind $mwin.mainfr.editfr.textarea <Control-e> " $mwin.mainfr.editfr.textarea insert insert [format %c 6]; incr dirtybit($myid); break "
      bind $mwin.mainfr.editfr.textarea <Control-E> " $mwin.mainfr.editfr.textarea insert insert [format %c 7]; incr dirtybit($myid); break "
      bind $mwin.mainfr.editfr.textarea <Control-o> " $mwin.mainfr.editfr.textarea insert insert [format %c 8]; incr dirtybit($myid); break "
      bind $mwin.mainfr.editfr.textarea <Control-O> " $mwin.mainfr.editfr.textarea insert insert {o}; incr dirtybit($myid); break "
      bind $mwin.mainfr.editfr.textarea <Control-y> " $mwin.mainfr.editfr.textarea insert insert [format %c 14]; incr dirtybit($myid); break "
      bind $mwin.mainfr.editfr.textarea <Control-r> " $mwin.mainfr.editfr.textarea insert insert [format %c 15]; incr dirtybit($myid); break "
   }

   # Mouse bindings
   menu $mwin.b2m -tearoff false -bg $appbg -fg $appfg
   $mwin.b2m add command -label " Cut " -command "cutBuffer $myid"
   $mwin.b2m add command -label " Copy " -command "copyBuffer $myid"
   $mwin.b2m add command -label " Paste " -command "pasteBuffer $myid"
   $mwin.b2m add separator
   $mwin.b2m add command -label " Normal " -command "normalSel $myid"
   $mwin.b2m add command -label " Underline " -command "ulSel $myid"
   $mwin.b2m add command -label " Superscript " -command "supSel $myid"
   $mwin.b2m add command -label " Supersuperscript " -command "supsupSel $myid"
   $mwin.b2m add command -label " Subsuperscript " -command "subsupSel $myid"
   $mwin.b2m add command -label " Subscript " -command "subSel $myid"
   $mwin.b2m add command -label " Subsubscript " -command "subsubSel $myid"
   $mwin.b2m add command -label " Supersubscript " -command "supsubSel $myid"
   $mwin.b2m add separator
   $mwin.b2m add command -label " Selection Font " -command "fontSel $myid"
   $mwin.b2m add command -label " Document Font " -command "chooseBaseFont"

   menu $mwin.b3m -tearoff false -bg $appbg -fg $appfg
   $mwin.b3m add command -label " Load file " -command "loadFile $myid"
   $mwin.b3m add command -label " Save file " -command "saveThisFile $myid"
   $mwin.b3m add command -label " Save as file " -command "saveFile $myid"
   $mwin.b3m add separator
   $mwin.b3m add command -label " Load Roman file " -command "importRoman $myid 0"
   $mwin.b3m add command -label " Insert Roman file " -command "importRoman $myid 1"
   $mwin.b3m add command -label " Append Roman file " -command "importRoman $myid 2"
   $mwin.b3m add separator
   $mwin.b3m add command -label " Load Tags " -command "loadTags $myid"
   $mwin.b3m add command -label " Save Tags " -command "saveTags $myid"
   $mwin.b3m add separator
   $mwin.b3m add command -label " Export to HTML " -command "exportHTML $myid"
   $mwin.b3m add command -label " Export to LaTeX " -command "exportLaTeX $myid"
   $mwin.b3m add command -label " Export to PostScript " -command "exportPS $myid"
   $mwin.b3m add separator
   $mwin.b3m add command -label " Send mail " -command "sendMail 1 $myid"
   $mwin.b3m add command -label " Read bwencoded file " -command "readBW 1 $myid"
   $mwin.b3m add command -label " Read MIME encoded file " -command "readMIME 1 $myid"
   $mwin.b3m add command -label " Read uuencoded file " -command "readUU 1 $myid"
   $mwin.b3m add separator
   $mwin.b3m add command -label " Close " -command "closeMain $myid"
   $mwin.b3m add command -label " Quit " -command "quitEditor"

   bind $mwin.mainfr.editfr.textarea <ButtonPress-2> "
      $mwin.b2m post %X %Y
      $mwin.b2m activate 0
      grab set -global $mwin.b2m
   "

   bind $mwin.mainfr.editfr.textarea <ButtonPress-3> "
      $mwin.b3m post %X %Y
      $mwin.b3m activate 0
      grab set -global $mwin.b3m
   "
}

proc activateFileMenu { myid } {
   set mwin ".main$myid"
   set posx [winfo x $mwin]
   incr posx [winfo x $mwin.cmdfr.file]
   set posy [winfo y $mwin]
   incr posy [winfo y $mwin.cmdfr.file]
   incr posy [winfo height $mwin.cmdfr.file]
   $mwin.cmdfr.file.m post $posx $posy
   $mwin.cmdfr.file.m activate 0
   grab set -global $mwin.cmdfr.file.m
   focus $mwin.cmdfr.file.m
}

proc activateEditMenu { myid } {
   set mwin ".main$myid"
   set posx [winfo x $mwin]
   incr posx [winfo x $mwin.cmdfr.edit]
   set posy [winfo y $mwin]
   incr posy [winfo y $mwin.cmdfr.edit]
   incr posy [winfo height $mwin.cmdfr.edit]
   $mwin.cmdfr.edit.m post $posx $posy
   $mwin.cmdfr.edit.m activate 0
   grab set -global $mwin.cmdfr.edit.m
   focus $mwin.cmdfr.edit.m
}

proc activateTagMenu { myid } {
   set mwin ".main$myid"
   set posx [winfo x $mwin]
   incr posx [winfo x $mwin.cmdfr.tag]
   set posy [winfo y $mwin]
   incr posy [winfo y $mwin.cmdfr.tag]
   incr posy [winfo height $mwin.cmdfr.tag]
   $mwin.cmdfr.tag.m post $posx $posy
   $mwin.cmdfr.tag.m activate 0
   grab set -global $mwin.cmdfr.tag.m
   focus $mwin.cmdfr.tag.m
}

proc activateOptionMenu { myid } {
   set mwin ".main$myid"
   set posx [winfo x $mwin]
   incr posx [winfo x $mwin.cmdfr.option]
   set posy [winfo y $mwin]
   incr posy [winfo y $mwin.cmdfr.option]
   incr posy [winfo height $mwin.cmdfr.option]
   $mwin.cmdfr.option.m post $posx $posy
   $mwin.cmdfr.option.m activate 0
   grab set -global $mwin.cmdfr.option.m
   focus $mwin.cmdfr.option.m
}

proc activateImportMenu { myid } {
   set mwin ".main$myid"
   set posx [winfo x $mwin]
   incr posx [winfo x $mwin.cmdfr.import]
   set posy [winfo y $mwin]
   incr posy [winfo y $mwin.cmdfr.import]
   incr posy [winfo height $mwin.cmdfr.import]
   $mwin.cmdfr.import.m post $posx $posy
   $mwin.cmdfr.import.m activate 0
   grab set -global $mwin.cmdfr.import.m
   focus $mwin.cmdfr.import.m
}

proc activateExportMenu { myid } {
   set mwin ".main$myid"
   set posx [winfo x $mwin]
   incr posx [winfo x $mwin.cmdfr.export]
   set posy [winfo y $mwin]
   incr posy [winfo y $mwin.cmdfr.export]
   incr posy [winfo height $mwin.cmdfr.export]
   $mwin.cmdfr.export.m post $posx $posy
   $mwin.cmdfr.export.m activate 0
   grab set -global $mwin.cmdfr.export.m
   focus $mwin.cmdfr.export.m
}

proc activateMailMenu { myid } {
   set mwin ".main$myid"
   set posx [winfo x $mwin]
   incr posx [winfo x $mwin.cmdfr.mail]
   set posy [winfo y $mwin]
   incr posy [winfo y $mwin.cmdfr.mail]
   incr posy [winfo height $mwin.cmdfr.mail]
   $mwin.cmdfr.mail.m post $posx $posy
   $mwin.cmdfr.mail.m activate 0
   grab set -global $mwin.cmdfr.mail.m
   focus $mwin.cmdfr.mail.m
}

proc activateHelpMenu { myid } {
   set mwin ".main$myid"
   set posx [winfo x $mwin]
   incr posx [winfo x $mwin.cmdfr.help]
   set posy [winfo y $mwin]
   incr posy [winfo y $mwin.cmdfr.help]
   incr posy [winfo height $mwin.cmdfr.help]
   $mwin.cmdfr.help.m post $posx $posy
   $mwin.cmdfr.help.m activate 0
   grab set -global $mwin.cmdfr.help.m
   focus $mwin.cmdfr.help.m
}

proc procEsc { myid } {
   global asciimode ascin dirtybit newTclTk

   set mwin ".main$myid"
   if {($asciimode($myid)) && ([string length $ascin($myid)] > 0)} {
      if ($newTclTk) {
         $mwin.mainfr.editfr.textarea insert insert [encfrom [format "%c" $ascin($myid)]]
      } else {
         $mwin.mainfr.editfr.textarea insert insert [format "%c" $ascin($myid)]
      }
      set ascin($myid) ""
      incr dirtybit($myid)
   }
   set asciimode($myid) [expr 1 - $asciimode($myid)]
}

proc procKey { myid A } {
   global newTclTk asciimode ascin dirtybit

   set mwin ".main$myid"
   if ($asciimode($myid)) { set ascin($myid) "" ; set asciimode($myid) 0 }
   if ($newTclTk) {
      $mwin.mainfr.editfr.textarea insert insert [encfrom $A]
   } else {
      $mwin.mainfr.editfr.textarea insert insert $A
   }
   incr dirtybit($myid)
}

proc markbegin { myid } {
   global selstart

   set mwin ".main$myid"
   set lsel [$mwin.mainfr.editfr.textarea tag ranges sel]
   if {([llength $lsel] == 2)} {
      $mwin.mainfr.editfr.textarea tag remove sel [lindex $lsel 0] [lindex $lsel 1]
   }
   set selstart($myid) [$mwin.mainfr.editfr.textarea index insert]
}

proc markend { myid } {
   global selstart selend

   set mwin ".main$myid"
   if {[string length $selstart($myid)] > 0} {
      set lsel [$mwin.mainfr.editfr.textarea tag ranges sel]
      if {[llength $lsel] == 2} {
         $mwin.mainfr.editfr.textarea tag remove sel [lindex $lsel 0] [lindex $lsel 1]
      }
      set selend($myid) [$mwin.mainfr.editfr.textarea index insert]
      if {[$mwin.mainfr.editfr.textarea compare $selstart($myid) <= $selend($myid)]} {
         $mwin.mainfr.editfr.textarea tag add sel $selstart($myid) $selend($myid)
      } else {
         $mwin.mainfr.editfr.textarea tag add sel $selend($myid) $selstart($myid)
      }
   }
   set selstart($myid) ""
   set selend($myid) ""
}

proc puncsymb { ch } {
   switch -exact "$ch" {
       " " { return 1 }
      "\n" { return 1 }
      "\t" { return 1 }
      "." { return 1 }
      "<" { return 1 }
      "," { return 1 }
      ";" { return 1 }
      ":" { return 1 }
      "?" { return 1 }
      "!" { return 1 }
      "/" { return 1 }
      "%" { return 1 }
      "~" { return 1 }
      "`" { return 1 }
      "'" { return 1 }
      "\\" { return 1 }
      "\"" { return 1 }
      "#" { return 1 }
      "\$" { return 1 }
      "+" { return 1 }
      "-" { return 1 }
      "*" { return 1 }
      "=" { return 1 }
      "\{" { return 1 }
      "|" { return 1 }
      "(" { return 1 }
      ")" { return 1 }
      "\[" { return 1 }
      "\]" { return 1 }
      default { return 0 }
   }
}

proc delword { myid } {
   global dirtybit

   set mwin ".main$myid"
   incr dirtybit($myid)
   set ch [$mwin.mainfr.editfr.textarea get insert]
   $mwin.mainfr.editfr.textarea delete insert
   if {[puncsymb $ch]} { return }
   set ch [$mwin.mainfr.editfr.textarea get insert]
   while {![puncsymb $ch]} {
      $mwin.mainfr.editfr.textarea delete insert
      set ch [$mwin.mainfr.editfr.textarea get insert]
   }
}

proc bsword { myid } {
   global dirtybit

   set mwin ".main$myid"
   incr dirtybit($myid)
   set ch [$mwin.mainfr.editfr.textarea get "insert -1 chars"]
   $mwin.mainfr.editfr.textarea delete "insert -1 chars"
   if {[puncsymb $ch]} { return }
   set ch [$mwin.mainfr.editfr.textarea get "insert -1 chars"]
   while {[puncsymb $ch] == 0} {
      $mwin.mainfr.editfr.textarea delete "insert -1 chars"
      set ch [$mwin.mainfr.editfr.textarea get "insert -1 chars"]
   }
}

proc deltotalword { myid } {
   global dirtybit

   set mwin ".main$myid"
   incr dirtybit($myid)

   set ch [$mwin.mainfr.editfr.textarea get insert]
   $mwin.mainfr.editfr.textarea delete insert
   if {[puncsymb $ch]} { return }

   set ch [$mwin.mainfr.editfr.textarea get "insert -1 chars"]
   while {[puncsymb $ch] == 0} {
      $mwin.mainfr.editfr.textarea delete "insert -1 chars"
      set ch [$mwin.mainfr.editfr.textarea get "insert -1 chars"]
   }
   set ch [$mwin.mainfr.editfr.textarea get insert]
   while {![puncsymb $ch]} {
      $mwin.mainfr.editfr.textarea delete insert
      set ch [$mwin.mainfr.editfr.textarea get insert]
   }
   if {![string compare " " [$mwin.mainfr.editfr.textarea get insert]]} {
      $mwin.mainfr.editfr.textarea delete insert
   } elseif {![string compare "\t" [$mwin.mainfr.editfr.textarea get insert]]} {
      $mwin.mainfr.editfr.textarea delete insert
   }
}

proc joinword { myid } {
   global dirtybit

   set mwin ".main$myid"
   set i 0
   while {![puncsymb [$mwin.mainfr.editfr.textarea get "insert + $i chars"]]} {
      incr i 1
   }
   switch -exact [$mwin.mainfr.editfr.textarea get "insert + $i chars"] {
      "\n" {
         $mwin.mainfr.editfr.textarea delete "insert + $i chars"
         incr dirtybit($myid)
      }
      "\t" {
         $mwin.mainfr.editfr.textarea delete "insert + $i chars"
         incr dirtybit($myid)
      }
      " " {
         $mwin.mainfr.editfr.textarea delete "insert + $i chars"
         incr dirtybit($myid)
      }
   }
}

proc delline { myid } {
   global dirtybit

   set mwin ".main$myid"
   $mwin.mainfr.editfr.textarea delete insert "insert lineend"
   incr dirtybit($myid)
}

proc bsline { myid } {
   global dirtybit

   set mwin ".main$myid"
   $mwin.mainfr.editfr.textarea delete "insert linestart" "insert"
   incr dirtybit($myid)
}

proc deltotalline { myid } {
   global dirtybit

   set mwin ".main$myid"
   $mwin.mainfr.editfr.textarea delete "insert linestart" "insert + 1 lines linestart"
   incr dirtybit($myid)
}

proc joinline { myid } {
   global dirtybit

   set mwin ".main$myid"
   $mwin.mainfr.editfr.textarea delete "insert lineend" "insert + 1 lines linestart"
   incr dirtybit($myid)
}

set mavail 1
proc newMain { } {
   global mavail dirtybit fname customfontno

   set dirtybit($mavail) 0
   set fname($mavail) ""
   set customfontno($mavail) 0
   editMain $mavail
   incr mavail 1
   return [expr $mavail - 1]
}

proc loadMain { } {
   global mavail dirtybit fname customfontno

   set dirtybit($mavail) 0
   set fname($mavail) ""
   set customfontno($mavail) 0
   editMain $mavail [getFileName "Load file"]
   incr mavail 1
   return [expr $mavail - 1]
}

proc loadMain2 { fnm } {
   global mavail dirtybit fname customfontno

   set dirtybit($mavail) 0
   set fname($mavail) ""
   set customfontno($mavail) 0
   editMain $mavail $fnm
   incr mavail 1
   return [expr $mavail - 1]
}

proc closeMain { myid } {
   global dirtybit

   set mwin ".main$myid"
   saveConfirm $myid; if { $dirtybit($myid) != 0 } { return }
   destroy $mwin
   refreshAllWinList
}

proc newFile { myid } {
   global fname dirtybit

   set mwin ".main$myid"
   saveConfirm $myid; if {$dirtybit($myid) != 0} { return }
   clearTextArea $myid
   set fname($myid) ""
}

proc loadThisFile { myid fnm } {
   global dirtybit fname newTclTk

   set mwin ".main$myid"
   saveConfirm $myid; if {$dirtybit($myid) != 0} { return }
   set fnm [string trim $fnm]
   if {![file readable $fnm]} {
      errmsg $myid "ERROR:\nI cannot load the file \"$fnm\". The file does not exist or does not have read permission."
      return
   }
   if {![file isfile $fnm]} {
      errmsg $myid "ERROR:\nI cannot load the file. \"$fnm\" is not a regular file."
      return
   }
   set f [open $fnm r]
   set x [read $f]
   close $f
   clearTextArea $myid
   if ($newTclTk) {
      $mwin.mainfr.editfr.textarea insert 1.0 [encfrom $x]
   } else {
      $mwin.mainfr.editfr.textarea insert 1.0 $x
   }
   focus $mwin.mainfr.editfr.textarea
   loadTags $myid "$fnm.tags"
   set fname($myid) $fnm
   $mwin.mainfr.editfr.textarea see insert
}

proc loadFile { myid } {
   global fname dirtybit newTclTk

   set mwin ".main$myid"
   saveConfirm $myid; if {$dirtybit($myid) != 0} { return }
   set fn [getFileName "bwedit: Load"]
   if { [string compare $fn ""] != 0 } {
      if {![file readable $fn]} {
         errmsg $myid "ERROR:\nI cannot load the file \"$fn\". The file does not exist or does not have read permission."
         return
      }
      if {![file isfile $fn]} {
         errmsg $myid "ERROR:\nI cannot load the file. \"$fn\" is not a regular file."
         return
      }
      set f [open $fn r]
      set x [read $f]
      close $f
      clearTextArea $myid
      if ($newTclTk) {
         $mwin.mainfr.editfr.textarea insert insert [encfrom $x]
      } else {
         $mwin.mainfr.editfr.textarea insert insert "$x"
      }
      loadTags $myid "$fn.tags"
      set fname($myid) $fn
      $mwin.mainfr.editfr.textarea see insert
   }
}

proc insertFile { myid } {
   global dirtybit newTclTk

   set mwin ".main$myid"
   set fn [getFileName "bwedit: Insert"]
   if { [string compare $fn ""] != 0 } {
      if {![file readable $fn]} {
         errmsg $myid "ERROR:\nI cannot insert the file \"$fn\". The file does not exist or does not have read permission."
         return
      }
      if {![file isfile $fn]} {
         errmsg $myid "ERROR:\nI cannot insert the file. \"$fn\" is not a regular file."
         return
      }
      set offset [$mwin.mainfr.editfr.textarea index insert]
      set dotidx [string first "." $offset]
      set offset [string range $offset 0 [expr $dotidx - 1]]
      set f [open $fn r]
      set x [read $f]
      close $f
      if ($newTclTk) {
         $mwin.mainfr.editfr.textarea insert insert [encfrom "\n$x"]
      } else {
         $mwin.mainfr.editfr.textarea insert insert "\n$x"
      }
      loadTags $myid "$fn.tags" $offset
      $mwin.mainfr.editfr.textarea see insert
      incr dirtybit($myid)
   }
}

proc appendFile { myid } {
   global dirtybit newTclTk

   set mwin ".main$myid"
   set fn [getFileName "bwedit: Append"]
   if { [string compare $fn ""] != 0 } {
      if {![file readable $fn]} {
         errmsg $myid "ERROR:\nI cannot append the file \"$fn\". The file does not exist or does not have read permission."
         return
      }
      if {![file isfile $fn]} {
         errmsg $myid "ERROR:\nI cannot append the file. \"$fn\" is not a regular file."
         return
      }
      set offset [$mwin.mainfr.editfr.textarea index end]
      set dotidx [string first "." $offset]
      set offset [string range $offset 0 [expr $dotidx - 1]]
      incr offset -1
      set f [open $fn r]
      set x [read $f]
      if ($newTclTk) {
         $mwin.mainfr.editfr.textarea insert end [encfrom "\n$x"]
      } else {
         $mwin.mainfr.editfr.textarea insert end "\n$x"
      }
      close $f
      loadTags $myid "$fn.tags" $offset
      $mwin.mainfr.editfr.textarea see insert
      incr dirtybit($myid)
   }
}

proc saveThisFile { myid } {
   global fname dirtybit newTclTk

   set mwin ".main$myid"
   set fnm [string trim $fname($myid)]
   if {![string compare "" $fnm]} {
      errmsg $myid "ERROR:\nI cannot save file. No file name is given."
      return
   }
   set dnm [file dirname $fnm]
   if {![file isdirectory $dnm]} {
      errmsg $myid "ERROR:\nI cannot save the file. \"$dnm\" is not a directory."
      return
   }
   if {![file writable $dnm]} {
      errmsg $myid "ERROR:\nI cannot save the file. You do not have permission to write in the directory \"$dnm\"."
      return
   }
   if {[file exists $fnm] && ![file isfile $fnm]} {
      errmsg $myid "ERROR:\nI cannot save the file. \"$fnm\" is not a regular file."
      return
   }
   if {[file exists $fnm] && ![file writable $fnm]} {
      errmsg $myid "ERROR:\nI cannot save the file. You do not have permission to overwrite \"$fnm\""
      return
   }
   if ($newTclTk) {
      set x [encto [$mwin.mainfr.editfr.textarea get 1.0 end]]
   } else {
      set x [$mwin.mainfr.editfr.textarea get 1.0 end]
   }
   set f [open $fnm w]
   puts -nonewline $f $x
   close $f
   saveTags $myid "$fnm.tags"
   set dirtybit($myid) 0
   errmsg $myid "$fnm saved"
}

proc saveFile { myid } {
   global fname dirtybit newTclTk

   set mwin ".main$myid"
   set fnm [getFileName "bwedit: Save"]
   if {![string compare "" $fnm]} { return }
   set dnm [file dirname $fnm]
   if {![file isdirectory $dnm]} {
      errmsg $myid "ERROR:\nI cannot save the file. \"$dnm\" is not a directory."
      return
   }
   if {![file writable $dnm]} {
      errmsg $myid "ERROR:\nI cannot save the file. You do not have permission to write in the directory \"$dnm\"."
      return
   }
   if {[file exists $fnm] && ![file isfile $fnm]} {
      errmsg $myid "ERROR:\nI cannot save the file. \"$fnm\" is not a regular file."
      return
   }
   if {[file exists $fnm] && ![file writable $fnm]} {
      errmsg $myid "ERROR:\nI cannot save the file. You do not have permission to overwrite \"$fnm\""
      return
   }
   if ($newTclTk) {
      set x [encto [$mwin.mainfr.editfr.textarea get 1.0 end]]
   } else {
      set x [$mwin.mainfr.editfr.textarea get 1.0 end]
   }
   set f [open $fnm w]
   puts -nonewline $f $x
   close $f
   saveTags $myid "$fnm.tags"
   set dirtybit($myid) 0
   if {![string compare $fname($myid) ""]} { set fname($myid) $fnm }
   errmsg $myid "$fnm saved"
}

proc clearTextArea { myid } {
   .main$myid.mainfr.editfr.textarea delete 1.0 end
}

proc selectAll { myid } {
   .main$myid.mainfr.editfr.textarea tag add sel 1.0 end
}

set buffer ""
proc cutBuffer { myid } {
   global buffer dirtybit

   set mwin .main$myid
   set lsel [$mwin.mainfr.editfr.textarea tag ranges sel]
   if {[llength $lsel] != 2} {
      errmsg $myid "Text does not contain a selected region. Select text by left mouse button and retry."
      return
   }

   incr dirtybit($myid)
   set buffer [$mwin.mainfr.editfr.textarea get sel.first sel.last]
   $mwin.mainfr.editfr.textarea delete sel.first sel.last
   $mwin.mainfr.editfr.textarea see insert
}

proc copyBuffer { myid } {
   global buffer

   set mwin .main$myid
   set lsel [$mwin.mainfr.editfr.textarea tag ranges sel]
   if {[llength $lsel] != 2} {
      errmsg $myid "Text does not contain a selected region. Select text by left mouse button and retry."
      return
   }

   set buffer [$mwin.mainfr.editfr.textarea get sel.first sel.last]
}

proc pasteBuffer { myid } {
   global buffer dirtybit newTclTk

   set mwin .main$myid
   if ($newTclTk) {
      for {set i 0} {$i < [string length $buffer]} {incr i} {
         scan [string range $buffer $i $i] "%c" nextchar
         if {($nextchar < 256)} {
            $mwin.mainfr.editfr.textarea insert insert [format "%c" $nextchar] english
         } else {
            $mwin.mainfr.editfr.textarea insert insert [format "%c" $nextchar]
         }
      }
   } else {
      $mwin.mainfr.editfr.textarea insert insert $buffer
   }
   incr dirtybit($myid)
   $mwin.mainfr.editfr.textarea see insert
}

proc configTags { myid } {
   global off1 off2 off3 ptsize slant newTclTk

   set mwin ".main$myid"

   switch -exact $ptsize {
      100 { set scriptsize 100; set scriptscriptsize 100 }
      120 { set scriptsize 100; set scriptscriptsize 100 }
      150 { set scriptsize 120; set scriptscriptsize 100 }
      180 { set scriptsize 150; set scriptscriptsize 120 }
      210 { set scriptsize 180; set scriptscriptsize 150 }
      250 { set scriptsize 210; set scriptscriptsize 180 }
      300 { set scriptsize 250; set scriptscriptsize 210 }
      360 { set scriptsize 300; set scriptscriptsize 250 }
      default { set scriptsize 120; set scriptscriptsize 120 }
   }

   if ($newTclTk) {
      $mwin.mainfr.editfr.textarea tag config suptag -offset $off1 -font "-*-bengali2-medium-$slant-*-*-*-$scriptsize-*-*-*-*-iso10646-1"
      $mwin.mainfr.editfr.textarea tag config supsuptag -offset $off2 -font "-*-bengali2-medium-$slant-*-*-*-$scriptscriptsize-*-*-*-*-iso10646-1"
      $mwin.mainfr.editfr.textarea tag config subsuptag -offset $off3 -font "-*-bengali2-medium-$slant-*-*-*-$scriptscriptsize-*-*-*-*-iso10646-1"
      $mwin.mainfr.editfr.textarea tag config subtag -offset -$off1 -font "-*-bengali2-medium-$slant-*-*-*-$scriptsize-*-*-*-*-iso10646-1"
      $mwin.mainfr.editfr.textarea tag config subsubtag -offset -$off2 -font "-*-bengali2-medium-$slant-*-*-*-$scriptscriptsize-*-*-*-*-iso10646-1"
      $mwin.mainfr.editfr.textarea tag config supsubtag -offset -$off3 -font "-*-bengali2-medium-$slant-*-*-*-$scriptscriptsize-*-*-*-*-iso10646-1"
      $mwin.mainfr.editfr.textarea tag config ultag -underline true

      foreach point {100 120 150 180 210 250 300 360} {
         $mwin.mainfr.editfr.textarea tag config bengali${point}o -font "-*-bengali2-medium-o-*-*-*-$point-*-*-*-*-iso10646-1"
         $mwin.mainfr.editfr.textarea tag config bengali${point}r -font "-*-bengali2-medium-r-*-*-*-$point-*-*-*-*-iso10646-1"
      }
   } else {
      $mwin.mainfr.editfr.textarea tag config suptag -offset $off1 -font "-*-bengali-medium-$slant-*-*-*-$scriptsize-*-*-*-*-*-fontspecific"
      $mwin.mainfr.editfr.textarea tag config supsuptag -offset $off2 -font "-*-bengali-medium-$slant-*-*-*-$scriptscriptsize-*-*-*-*-*-fontspecific"
      $mwin.mainfr.editfr.textarea tag config subsuptag -offset $off3 -font "-*-bengali-medium-$slant-*-*-*-$scriptscriptsize-*-*-*-*-*-fontspecific"
      $mwin.mainfr.editfr.textarea tag config subtag -offset -$off1 -font "-*-bengali-medium-$slant-*-*-*-$scriptsize-*-*-*-*-*-fontspecific"
      $mwin.mainfr.editfr.textarea tag config subsubtag -offset -$off2 -font "-*-bengali-medium-$slant-*-*-*-$scriptscriptsize-*-*-*-*-*-fontspecific"
      $mwin.mainfr.editfr.textarea tag config supsubtag -offset -$off3 -font "-*-bengali-medium-$slant-*-*-*-$scriptscriptsize-*-*-*-*-*-fontspecific"
      $mwin.mainfr.editfr.textarea tag config ultag -underline true

      foreach point {100 120 150 180 210 250 300 360} {
         $mwin.mainfr.editfr.textarea tag config bengali${point}o -font "-*-bengali-medium-o-*-*-*-$point-*-*-*-*-*-fontspecific"
         $mwin.mainfr.editfr.textarea tag config bengali${point}r -font "-*-bengali-medium-r-*-*-*-$point-*-*-*-*-*-fontspecific"
      }
   }

   $mwin.mainfr.editfr.textarea tag config english -font fixed
}

proc supSel { myid } {
   set mwin ".main$myid"
   set lsel [$mwin.mainfr.editfr.textarea tag ranges sel]
   if {[llength $lsel] != 2} {
      errmsg $myid "Text does not contain a selected region. Select text by left mouse button and retry."
      return
   }

   $mwin.mainfr.editfr.textarea tag add suptag sel.first sel.last
   $mwin.mainfr.editfr.textarea tag remove supsuptag sel.first sel.last
   $mwin.mainfr.editfr.textarea tag remove subsuptag sel.first sel.last
   $mwin.mainfr.editfr.textarea tag remove subtag sel.first sel.last
   $mwin.mainfr.editfr.textarea tag remove subsubtag sel.first sel.last
   $mwin.mainfr.editfr.textarea tag remove supsubtag sel.first sel.last
}

proc supsupSel { myid } {
   set mwin ".main$myid"
   set lsel [$mwin.mainfr.editfr.textarea tag ranges sel]
   if {[llength $lsel] != 2} {
      errmsg $myid "Text does not contain a selected region. Select text by left mouse button and retry."
      return
   }

   $mwin.mainfr.editfr.textarea tag remove suptag sel.first sel.last
   $mwin.mainfr.editfr.textarea tag add supsuptag sel.first sel.last
   $mwin.mainfr.editfr.textarea tag remove subsuptag sel.first sel.last
   $mwin.mainfr.editfr.textarea tag remove subtag sel.first sel.last
   $mwin.mainfr.editfr.textarea tag remove subsubtag sel.first sel.last
   $mwin.mainfr.editfr.textarea tag remove supsubtag sel.first sel.last
}

proc subsupSel { myid } {
   set mwin ".main$myid"
   set lsel [$mwin.mainfr.editfr.textarea tag ranges sel]
   if {[llength $lsel] != 2} {
      errmsg $myid "Text does not contain a selected region. Select text by left mouse button and retry."
      return
   }

   $mwin.mainfr.editfr.textarea tag remove suptag sel.first sel.last
   $mwin.mainfr.editfr.textarea tag remove supsuptag sel.first sel.last
   $mwin.mainfr.editfr.textarea tag add subsuptag sel.first sel.last
   $mwin.mainfr.editfr.textarea tag remove subtag sel.first sel.last
   $mwin.mainfr.editfr.textarea tag remove subsubtag sel.first sel.last
   $mwin.mainfr.editfr.textarea tag remove supsubtag sel.first sel.last
}

proc subSel { myid } {
   set mwin ".main$myid"
   set lsel [$mwin.mainfr.editfr.textarea tag ranges sel]
   if {[llength $lsel] != 2} {
      errmsg $myid "Text does not contain a selected region. Select text by left mouse button and retry."
      return
   }

   $mwin.mainfr.editfr.textarea tag remove suptag sel.first sel.last
   $mwin.mainfr.editfr.textarea tag remove supsuptag sel.first sel.last
   $mwin.mainfr.editfr.textarea tag remove subsuptag sel.first sel.last
   $mwin.mainfr.editfr.textarea tag add subtag sel.first sel.last
   $mwin.mainfr.editfr.textarea tag remove subsubtag sel.first sel.last
   $mwin.mainfr.editfr.textarea tag remove supsubtag sel.first sel.last
}

proc subsubSel { myid } {
   set mwin ".main$myid"
   set lsel [$mwin.mainfr.editfr.textarea tag ranges sel]
   if {[llength $lsel] != 2} {
      errmsg $myid "Text does not contain a selected region. Select text by left mouse button and retry."
      return
   }

   $mwin.mainfr.editfr.textarea tag remove suptag sel.first sel.last
   $mwin.mainfr.editfr.textarea tag remove supsuptag sel.first sel.last
   $mwin.mainfr.editfr.textarea tag remove subsuptag sel.first sel.last
   $mwin.mainfr.editfr.textarea tag remove subtag sel.first sel.last
   $mwin.mainfr.editfr.textarea tag add subsubtag sel.first sel.last
   $mwin.mainfr.editfr.textarea tag remove supsubtag sel.first sel.last
}

proc supsubSel { myid } {
   set mwin ".main$myid"
   set lsel [$mwin.mainfr.editfr.textarea tag ranges sel]
   if {[llength $lsel] != 2} {
      errmsg $myid "Text does not contain a selected region. Select text by left mouse button and retry."
      return
   }

   $mwin.mainfr.editfr.textarea tag remove suptag sel.first sel.last
   $mwin.mainfr.editfr.textarea tag remove supsuptag sel.first sel.last
   $mwin.mainfr.editfr.textarea tag remove subsuptag sel.first sel.last
   $mwin.mainfr.editfr.textarea tag remove subtag sel.first sel.last
   $mwin.mainfr.editfr.textarea tag remove subsubtag sel.first sel.last
   $mwin.mainfr.editfr.textarea tag add supsubtag sel.first sel.last
}

proc ulSel { myid } {
   set mwin ".main$myid"
   set lsel [$mwin.mainfr.editfr.textarea tag ranges sel]
   if {[llength $lsel] != 2} {
      errmsg $myid "Text does not contain a selected region. Select text by left mouse button and retry."
      return
   }

   $mwin.mainfr.editfr.textarea tag add ultag sel.first sel.last
}

proc normalSel { myid } {
   global customfontno newTclTk

   set mwin ".main$myid"
   set lsel [$mwin.mainfr.editfr.textarea tag ranges sel]
   if {[llength $lsel] != 2} {
      errmsg $myid "Text does not contain a selected region. Select text by left mouse button and retry."
      return
   }
   set selfirst [$mwin.mainfr.editfr.textarea index sel.first]
   set sellast [$mwin.mainfr.editfr.textarea index sel.last]
   set seltext [$mwin.mainfr.editfr.textarea get $selfirst $sellast]
   $mwin.mainfr.editfr.textarea delete $selfirst $sellast
   tkTextSetCursor $mwin.mainfr.editfr.textarea $selfirst
   if ($newTclTk) {
      $mwin.mainfr.editfr.textarea insert insert [encfrom $seltext]
   } else {
      $mwin.mainfr.editfr.textarea insert insert $seltext
   }
}

proc fontSel { myid } {
   global ptsize slant fseltype fselpt fselsl fswin fsgfname newTclTk
   global fsok customfid customfontno lsel fontlist appbg appfg btnbg btnfg

   set mwin ".main$myid"
   set lsel [$mwin.mainfr.editfr.textarea tag ranges sel]
   if {[llength $lsel] != 2} {
      errmsg $myid "Text does not contain a selected region. Select text by left mouse button and retry."
      return
   }

   set fswin [toplevel .fsel]
   set fseltype 0
   set fselpt $ptsize
   set fselsl $slant
   set fsgfname ""

   frame $fswin.bfr -bg $appbg -relief flat
   frame $fswin.efr -bg $appbg -relief flat
   frame $fswin.gfr -bg $appbg -relief flat
   frame $fswin.gfr.fr1 -bg $appbg -relief flat
   frame $fswin.gfr.fr2 -bg $appbg -relief flat
   frame $fswin.ofr -bg $appbg -relief flat
   radiobutton $fswin.bfr.rb  -text "Bengali: " -variable fseltype -value 0 \
      -relief ridge -selectcolor #bbff00 -fg #000000 -bg #88ccdd \
      -activebackground #88ccdd -activeforeground #000000
   menubutton $fswin.bfr.mb -text "Point size" -height 1 -width 10 \
      -relief raised -menu $fswin.bfr.mb.m -bg $appbg -fg #000000 \
      -activebackground $appbg -activeforeground #000000 -disabledforeground #A2A2A2
   menu $fswin.bfr.mb.m -tearoff false -bg $appbg -fg $appfg
   $fswin.bfr.mb.m add command -label " 100 " -command {$fswin.bfr.mb config -text 100; set fselpt 100}
   $fswin.bfr.mb.m add command -label " 120 " -command {$fswin.bfr.mb config -text 120; set fselpt 120}
   $fswin.bfr.mb.m add command -label " 150 " -command {$fswin.bfr.mb config -text 150; set fselpt 150}
   $fswin.bfr.mb.m add command -label " 180 " -command {$fswin.bfr.mb config -text 180; set fselpt 180}
   $fswin.bfr.mb.m add command -label " 210 " -command {$fswin.bfr.mb config -text 210; set fselpt 210}
   $fswin.bfr.mb.m add command -label " 250 " -command {$fswin.bfr.mb config -text 250; set fselpt 250}
   $fswin.bfr.mb.m add command -label " 300 " -command {$fswin.bfr.mb config -text 300; set fselpt 300}
   $fswin.bfr.mb.m add command -label " 360 " -command {$fswin.bfr.mb config -text 360; set fselpt 360}
   checkbutton $fswin.bfr.cb -text "Slanted" \
      -variable fselsl -onvalue "o" -offvalue "r" -relief flat \
      -selectcolor #bbff00 -fg $appfg -bg $appbg \
      -activeforeground #000000 -activebackground $appbg -disabledforeground #A2A2A2
   label $fswin.bfr.space -text "" -relief flat -fg #000000 -bg $appbg
   radiobutton $fswin.efr.rb  -text "English: " -variable fseltype -value 1 \
      -relief ridge -selectcolor #bbff00 -fg #000000 -bg #88ccdd \
      -activebackground #88ccdd -activeforeground #000000
   label $fswin.efr.space -text "" -relief flat -fg #000000 -bg $appbg
   radiobutton $fswin.gfr.fr1.rb  -text "General: " -variable fseltype -value 2 \
      -relief ridge -selectcolor #bbff00 -fg #000000 -bg #88ccdd \
      -activebackground #88ccdd -activeforeground #000000
   entry $fswin.gfr.fr1.e -textvariable fsgfname -width 40 -bg #ddddaa -fg #000000 \
      -state disabled -selectbackground #000000 -selectforeground #ddddaa
   listbox $fswin.gfr.fr2.lbx -bg #ddddaa -fg #A2A2A2 -height 10 \
      -yscroll "$fswin.gfr.fr2.scr set" -relief sunken \
      -selectmode single -selectforeground #ddddaa -selectbackground #A2A2A2 \
      -selectborderwidth 0
   scrollbar $fswin.gfr.fr2.scr -command "$fswin.gfr.fr2.lbx yview" \
      -orient vertical -bg $appbg -width 12 -activebackground $appbg
   set fllen [llength $fontlist]
   for {set idx 0} {$idx < $fllen} {incr idx 1} {
      $fswin.gfr.fr2.lbx insert end [lindex $fontlist $idx]
   }
   bind $fswin.gfr.fr2.lbx <ButtonPress-1> {
      if {$fseltype == 2} {
         set fsgfname [$fswin.gfr.fr2.lbx get [$fswin.gfr.fr2.lbx nearest %y]]
      }
   }
   bind $fswin.gfr.fr2.lbx <ButtonRelease-1> "
      $mwin.mainfr.editfr.textarea tag add sel [lindex $lsel 0] [lindex $lsel 1]
   "
   bind $fswin.bfr.rb <ButtonPress-1> {
      $fswin.gfr.fr2.lbx config -fg #A2A2A2 -selectbackground #A2A2A2
      $fswin.bfr.mb config -state active
      $fswin.bfr.cb config -state active
   }
   bind $fswin.efr.rb <ButtonPress-1> {
      $fswin.gfr.fr2.lbx config -fg #A2A2A2 -selectbackground #A2A2A2
      $fswin.bfr.mb config -state disabled
      $fswin.bfr.cb config -state disabled
   }
   bind $fswin.gfr.fr1.rb <ButtonPress-1> {
      $fswin.gfr.fr2.lbx config -fg #000000 -selectbackground #000000
      $fswin.bfr.mb config -state disabled
      $fswin.bfr.cb config -state disabled
   }

   button $fswin.ofr.ok -text " Ok " -relief raised -fg $btnfg -bg $btnbg \
      -activebackground $btnbg -activeforeground $btnfg -command "set fsok 1"
   label $fswin.ofr.space -text "" -relief flat -fg $appfg -bg $appbg
   button $fswin.ofr.cancel -text " Cancel " -relief raised -fg $btnfg -bg $btnbg \
      -activebackground $btnbg -activeforeground $btnfg -command "set fsok 0"

   pack $fswin.bfr.rb $fswin.bfr.mb $fswin.bfr.cb -expand no -side left -padx 5 -pady 0
   pack $fswin.bfr.space -expand yes -fill x -padx 5 -pady 0 -side left
   pack $fswin.efr.rb -expand no -side left -padx 5 -pady 0
   pack $fswin.efr.space -expand yes -fill x -padx 5 -pady 0 -side left
   pack $fswin.gfr.fr1.rb -expand no -side left -padx 5 -pady 0
   pack $fswin.gfr.fr1.e -expand yes -fill x -padx 5 -pady 0 -side left
   pack $fswin.gfr.fr2.scr -side right -expand no -fill y -padx 0 -pady 0
   pack $fswin.gfr.fr2.lbx -side right -expand yes -fill x -padx 0 -pady 0
   pack $fswin.gfr.fr1 -expand yes -fill x -padx 0 -pady 0
   pack $fswin.gfr.fr2 -expand yes -fill x -padx 5 -pady 0
   pack $fswin.ofr.ok -expand no -side left -padx 5 -pady 0
   pack $fswin.ofr.space -expand yes -fill x -padx 5 -pady 0 -side left
   pack $fswin.ofr.cancel -expand no -side left -padx 5 -pady 0
   pack $fswin.bfr $fswin.efr $fswin.gfr $fswin.ofr -padx 5 -pady 10 -expand yes -fill x
   $fswin config -bg $appbg

   wm title $fswin "Selection font"
   wm resizable $fswin false false

   bind $fswin <Escape> "set fsok 0"

   grab $fswin
   tkwait variable fsok
   destroy $fswin

   set selfirst [lindex $lsel 0]
   set sellast [lindex $lsel 1]
   $mwin.mainfr.editfr.textarea tag add sel $selfirst $sellast

   if {($fsok)} {
      set seltext [$mwin.mainfr.editfr.textarea get $selfirst $sellast]
      $mwin.mainfr.editfr.textarea delete $selfirst $sellast
      tkTextSetCursor $mwin.mainfr.editfr.textarea $selfirst
      switch -exact $fseltype {
         0 {
              if ($newTclTk) {
                 $mwin.mainfr.editfr.textarea insert insert [encfrom $seltext] bengali$fselpt$fselsl
              } else {
                 $mwin.mainfr.editfr.textarea insert insert bengali$fselpt$fselsl $seltext
              }
           }
         1 {
              if ($newTclTk) {
                 $mwin.mainfr.editfr.textarea insert insert [encto $seltext] english
              } else {
                 $mwin.mainfr.editfr.textarea insert insert english
              }
           }
         2 {
            set inserted 0
            for {set i 0} {($i < $customfontno($myid)) && (!$inserted)} {incr i 1} {
               if {![string comp $customfid("$myid:$i") $fsgfname]} {
                  if ($newTclTk) {
                     $mwin.mainfr.editfr.textarea insert insert [encto $seltext] customftag$i
                  } else {
                     $mwin.mainfr.editfr.textarea insert insert $seltext customftag$i
                  }
                  set inserted 1
               }
            }
            if {!($inserted)} {
               $mwin.mainfr.editfr.textarea tag config customftag$customfontno($myid) -font $fsgfname
               if ($newTclTk) {
                  $mwin.mainfr.editfr.textarea insert insert [encto $seltext] customftag$customfontno($myid)
               } else {
                  $mwin.mainfr.editfr.textarea insert insert $seltext customftag$customfontno($myid)
               }
               set customfid("$myid:$customfontno($myid)") $fsgfname
               incr customfontno($myid) 1
            }
         }
      }
      $mwin.mainfr.editfr.textarea see insert
   }
}

proc loadTags { myid { tfname "" } { offset 0 } } {
   set mwin ".main$myid"
   if {![string compare $tfname ""]} {
      set fn [getFileName "bwedit: Load tags"]
   } else {
      set fn $tfname
   }
   if { [string compare $fn ""] != 0 } {
      if {![file readable $fn]} {
         if {![string compare $tfname ""]} {
            errmsg $myid "ERROR:\nI cannot load the file \"$fn\". The file does not exist or does not have read permission."
         }
         return
      }
      if {![file isfile $fn]} {
         if {![string compare $tfname ""]} {
            errmsg $myid "ERROR:\nI cannot load the file. \"$fn\" is not a regular file."
         }
         return
      }
      set f [open $fn r]
      foreach line [split [read $f] "\n"] {
         addTag $myid $line $offset
      }
      close $f
      $mwin.mainfr.editfr.textarea see insert
   }
}

proc addTag { myid line { offset 0 } } {
   global customfontno customfid fontlist scriptlist newTclTk

   set mwin ".main$myid"
   set endidx [$mwin.mainfr.editfr.textarea index end]
   set colonidx [ string first ":" $line ]
   if {$colonidx > 0} {
      set tagname [ string range $line 0 [expr $colonidx - 1] ]
      set tagranges [ string range $line [expr $colonidx + 1] [ expr [string length $line] - 1] ]
      set tagname [ string trim $tagname ]
      set tagranges [ string trim $tagranges ]
      set cfidx -1
      if {![string compare $tagname "customfont"]} {
         set tabidx [string first "\t" $tagranges]
         if {$tabidx > 0} {
            set tagname [string trim [string range $tagranges 0 [expr $tabidx - 1]]]
            set tagranges [string trim [string range $tagranges [expr $tabidx + 1] [expr [string length $tagranges] - 1]]]
            for {set i 0} {$i < $customfontno($myid)} {incr i 1} {
               if {![string compare $tagname $customfid("$myid:$i")]} { set cfidx $i }
            }
            if {$cfidx == -1} {
               set cfidx $customfontno($myid)
               incr customfontno($myid) 1
               set customfid("$myid:$cfidx") $tagname
               if {[lsearch -exact $fontlist $tagname] < 0} {
                  puts "Unable to find font $tagname.. using fixed instead"
                  $mwin.mainfr.editfr.textarea tag config customftag$cfidx -font fixed
               } else {
                  $mwin.mainfr.editfr.textarea tag config customftag$cfidx -font $tagname
               }
            }
         } else { set cfidx -2 }
      }
      set tagranges [split $tagranges " "]
      if {($cfidx != -2)} {
         while {[llength $tagranges] > 1} {
            set tagfirst [lindex $tagranges 0]
            set taglast [lindex $tagranges 1]
            set tagranges [lreplace $tagranges 0 1]
            if { [regexp {[0-9]+\.[0-9]+} $tagfirst] && [regexp {[0-9]+\.[0-9]+} $taglast] && [$mwin.mainfr.editfr.textarea compare $tagfirst <= $taglast] && [$mwin.mainfr.editfr.textarea compare $tagfirst >= 1.0] && [$mwin.mainfr.editfr.textarea compare $taglast <= $endidx]} {
               set dotidx [string first "." $tagfirst]
               set tagfirst [expr $offset + [string range $tagfirst 0 [expr $dotidx - 1]]].[string range $tagfirst [expr $dotidx + 1] [expr [string length $tagfirst] - 1]]
               set dotidx [string first "." $taglast]
               set taglast [expr $offset + [string range $taglast 0 [expr $dotidx - 1]]].[string range $taglast [expr $dotidx + 1] [expr [string length $taglast] - 1]]
               if {[lsearch -exact $scriptlist $tagname] >= 0} {
                  $mwin.mainfr.editfr.textarea tag remove suptag $tagfirst $taglast
                  $mwin.mainfr.editfr.textarea tag remove supsuptag $tagfirst $taglast
                  $mwin.mainfr.editfr.textarea tag remove subsuptag $tagfirst $taglast
                  $mwin.mainfr.editfr.textarea tag remove subtag $tagfirst $taglast
                  $mwin.mainfr.editfr.textarea tag remove subsubtag $tagfirst $taglast
                  $mwin.mainfr.editfr.textarea tag remove supsubtag $tagfirst $taglast
                  $mwin.mainfr.editfr.textarea tag add $tagname $tagfirst $taglast
               } elseif {![string compare $tagname "ultag"]} {
                  $mwin.mainfr.editfr.textarea tag add $tagname $tagfirst $taglast
               } else {
                  set tagtext [$mwin.mainfr.editfr.textarea get $tagfirst $taglast]
                  $mwin.mainfr.editfr.textarea delete $tagfirst $taglast
                  if {($cfidx != -1)} {
                      set tagname customftag$cfidx
                     set instype 0
                  } elseif {![string compare $tagname "english"]} {
                     set instype 0
                  } else {
                     set instype 1
                  }
                  if ($newTclTk) {
                     if ($instype) {
                        $mwin.mainfr.editfr.textarea insert $tagfirst [encfrom $tagtext] $tagname
                     } else {
                        $mwin.mainfr.editfr.textarea insert $tagfirst [encto $tagtext] $tagname
                     }
                  } else {
                     $mwin.mainfr.editfr.textarea insert $tagfirst $tagtext $tagname
                  }
               }
            }
         }
      }
   }
}

proc saveTags { myid { tfname "" } } {
   global customfontno customfid

   set mwin ".main$myid"
   if {![string compare $tfname ""]} {
      set fn [getFileName "bwedit: Save tags"]
   } else {
      set fn $tfname
   }
   if { [string compare $fn ""] != 0 } {
      set dnm [file dirname $fn]
      if {![file isdirectory $dnm]} {
         errmsg $myid "ERROR:\nI cannot save the file. \"$dnm\" is not a directory."
         return
      }
      if {![file writable $dnm]} {
         errmsg $myid "ERROR:\nI cannot save the file. You do not have permission to write in the directory \"$dnm\"."
        return
      }
      if {[file exists $fn] && ![file isfile $fn]} {
         errmsg $myid "ERROR:\nI cannot save the file. \"$fn\" is not a regular file."
         return
      }
      if {[file exists $fn] && ![file writable $fn]} {
         errmsg $myid "ERROR:\nI cannot save the file. You do not have permission to overwrite \"$fn\""
         return
      }

      set f [open $fn w]
      foreach point {100 120 150 180 210 250 300 360} {
         set tagranges [$mwin.mainfr.editfr.textarea tag ranges bengali${point}o ]
         if {[llength $tagranges] > 0} { puts $f "bengali${point}o\t: $tagranges" }
         set tagranges [$mwin.mainfr.editfr.textarea tag ranges bengali${point}r ]
         if {[llength $tagranges] > 0} { puts $f "bengali${point}r\t: $tagranges" }
      }
      for {set i 0} {$i < $customfontno($myid)} {incr i 1} {
         set tagname customftag$i
         set tagranges [$mwin.mainfr.editfr.textarea tag ranges $tagname]
         if {[llength $tagranges] > 0} {
            set fid $customfid("$myid:$i")
            puts $f "customfont\t: $fid\t$tagranges"
         }
      }
      foreach tagname { english ultag suptag supsuptag subsuptag subtag subsubtag supsubtag } {
         set tagranges [$mwin.mainfr.editfr.textarea tag ranges $tagname]
         if {[llength $tagranges] > 0} { puts $f "$tagname\t: $tagranges" }
      }
      close $f
   }
}

set scwinid -1
proc saveConfirm { myid } {
   global scwin dirtybit btnbg btnfg scwinid sccancel

   set mwin ".main$myid"
   if {[winfo exists $scwinid]} {focus $scwinid; tkwait variable dirtybit($myid); return;}
   set sccancel 0
   while {($dirtybit($myid) != 0) && ($sccancel == 0)} {
      set scwin [toplevel .sc]
      set scwinid $scwin
      $scwin config -bg #004466
      label $scwin.l -text "Unsaved changes in main editor window $myid" -fg #ffffff -bg #006688
      frame $scwin.bfr -bg #004466
      button $scwin.bfr.b1 -text "Save" -command "saveThisFile $myid" -underline 0 \
         -bg $btnbg -fg $btnfg -activebackground $btnbg -activeforeground $btnfg \
         -relief raised
      button $scwin.bfr.b2 -text "Save as" -command "saveFile $myid" -underline 5 \
         -bg $btnbg -fg $btnfg -activebackground $btnbg -activeforeground $btnfg \
         -relief raised
      button $scwin.bfr.b3 -text "Do not save" -command "set dirtybit($myid) 0" -underline 3 \
         -bg $btnbg -fg $btnfg -activebackground $btnbg -activeforeground $btnfg \
         -relief raised
      button $scwin.bfr.b4 -text "Cancel" -command "set dirtybit($myid) $dirtybit($myid); set sccancel 1" -underline 0 \
         -bg $btnbg -fg $btnfg -activebackground $btnbg -activeforeground $btnfg \
         -relief raised
      pack $scwin.l -expand yes -fill both -padx 0 -pady 0
      pack $scwin.bfr.b1 $scwin.bfr.b2 $scwin.bfr.b3 $scwin.bfr.b4 -side left -padx 10 -pady 0
      pack $scwin.bfr -expand no -padx 0 -pady 10

      bind $scwin <Key-S> "saveThisFile $myid"
      bind $scwin <Key-A> "saveFile $myid"
      bind $scwin <Key-N> "set dirtybit($myid) 0"
      bind $scwin <Key-C> "set dirtybit($myid) $dirtybit($myid); set sccancel 1"
      bind $scwin <Key-s> "saveThisFile $myid"
      bind $scwin <Key-a> "saveFile $myid"
      bind $scwin <Key-n> "set dirtybit($myid) 0"
      bind $scwin <Key-c> "set dirtybit($myid) $dirtybit($myid); set sccancel 1"

      wm transient $scwin $mwin
      wm title $scwin "Options for unsaved changes"
      set posx [winfo x $mwin]
      set posy [winfo y $mwin]
      incr posx [winfo x $mwin.mainfr]
      incr posy [winfo y $mwin.mainfr]
      set twd [winfo width $mwin.mainfr.editfr.textarea]
      set tht [winfo height $mwin.mainfr.editfr.textarea]
      set ewd1 [winfo reqwidth $scwin.l]
      set ewd2 [expr [winfo reqwidth $scwin.bfr.b1] + \
                     [winfo reqwidth $scwin.bfr.b2] + \
                     [winfo reqwidth $scwin.bfr.b3] + \
                     [winfo reqwidth $scwin.bfr.b4] + 100]
      if {$ewd1 > $ewd2} { set ewd $ewd1 } else { set ewd $ewd2 }
      set eht [expr [winfo reqheight $scwin.l] + [winfo reqheight $scwin.bfr.b1] + 40]
      set posx [expr $posx + ($twd - $ewd) / 2]
      set posy [expr $posy + ($tht - $eht) / 2]
      if {$posx <= 0} { set posx 0 }
      if {$posy <= 0} { set posy 0 }
      wm geometry $scwin "${ewd}x${eht}+$posx+$posy"
      focus $scwin

      grab $scwin
      tkwait variable dirtybit($myid)
      grab release $scwin
      destroy $scwin
      set scwinid -1
   }
}

proc errmsg { myid msg } {
   global btnbg btnfg

   set mwin ".main$myid"
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

   wm transient $ewin $mwin
   set posx [winfo x $mwin]
   set posy [winfo y $mwin]
   incr posx [winfo x $mwin.mainfr]
   incr posy [winfo y $mwin.mainfr]
   set twd [winfo width $mwin.mainfr.editfr.textarea]
   set tht [winfo height $mwin.mainfr.editfr.textarea]
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

proc chooseBaseFont {} {
   global ptsize slant donef off1 off2 off3 appbg appfg btnbg btnfg mavail newTclTk

   set fwin [toplevel .font]

   label $fwin.lbl -text "Choose font size" -relief flat -fg $appfg -bg $appbg

   radiobutton $fwin.rb1 -width 6 -text "10" -variable ptsize -value "100" -relief ridge -selectcolor #bbff00 -fg $appfg -bg $appbg -activebackground $appbg -activeforeground $appfg
   radiobutton $fwin.rb2 -width 6 -text "12" -variable ptsize -value "120" -relief ridge -selectcolor #bbff00 -fg $appfg -bg $appbg -activebackground $appbg -activeforeground $appfg
   radiobutton $fwin.rb3 -width 6 -text "15" -variable ptsize -value "150" -relief ridge -selectcolor #bbff00 -fg $appfg -bg $appbg -activebackground $appbg -activeforeground $appfg
   radiobutton $fwin.rb4 -width 6 -text "18" -variable ptsize -value "180" -relief ridge -selectcolor #bbff00 -fg $appfg -bg $appbg -activebackground $appbg -activeforeground $appfg
   radiobutton $fwin.rb5 -width 6 -text "21" -variable ptsize -value "210" -relief ridge -selectcolor #bbff00 -fg $appfg -bg $appbg -activebackground $appbg -activeforeground $appfg
   radiobutton $fwin.rb6 -width 6 -text "25" -variable ptsize -value "250" -relief ridge -selectcolor #bbff00 -fg $appfg -bg $appbg -activebackground $appbg -activeforeground $appfg
   radiobutton $fwin.rb7 -width 6 -text "30" -variable ptsize -value "300" -relief ridge -selectcolor #bbff00 -fg $appfg -bg $appbg -activebackground $appbg -activeforeground $appfg
   radiobutton $fwin.rb8 -width 6 -text "36" -variable ptsize -value "360" -relief ridge -selectcolor #bbff00 -fg $appfg -bg $appbg -activebackground $appbg -activeforeground $appfg

   checkbutton $fwin.cb -width 9 -text " slanted" -variable slant \
      -onvalue "o" -offvalue "r" -relief raised \
      -selectcolor #bbff00 -fg $appfg -bg $appbg \
      -activeforeground $appfg -activebackground $appbg

   button $fwin.done -text "Done" -command {set donef 1} -fg $btnfg -bg $btnbg \
      -activeforeground $btnfg -activebackground $btnbg
   button $fwin.cancel -text "Cancel" -command {set donef 0} -fg $btnfg -bg $btnbg \
      -activeforeground $btnfg -activebackground $btnbg

   pack $fwin.lbl -pady 5 -padx 5
   for {set i 1} {$i <= 8} {incr i 1} {
      pack $fwin.rb$i
   }
   pack $fwin.cb -padx 5 -pady 5
   pack $fwin.done $fwin.cancel -pady 5 -padx 5
   $fwin config -bg $appbg
   bind $fwin <Escape> {set donef 0}

   wm title $fwin "bwedit: select font"
   wm resizable $fwin false false

   grab $fwin
   tkwait variable donef
   grab release $fwin
   destroy $fwin

   if {$donef} {
      switch -exact $ptsize {
         100 {set spacing3 4; set off1 5; set off2 8; set off3 3;}
         120 {set spacing3 5; set off1 6; set off2 9; set off3 3;}
         150 {set spacing3 6; set off1 7; set off2 12; set off3 4;}
         180 {set spacing3 7; set off1 9; set off2 14; set off3 5;}
         210 {set spacing3 8; set off1 10; set off2 16; set off3 6;}
         250 {set spacing3 10; set off1 12; set off2 20; set off3 7;}
         300 {set spacing3 12; set off1 15; set off2 24; set off3 9;}
         360 {set spacing3 15; set off1 18; set off2 28; set off3 10;}
         default {set spacing3 5; set off1 6; set off2 9; set off3 3;}
      }
      for {set i 1} {$i < $mavail} {incr i 1} {
         if {[winfo exists .main$i]} {
            if ($newTclTk) {
               .main$i.mainfr.editfr.textarea config -font "-*-bengali2-medium-$slant-*-*-*-$ptsize-*-*-*-*-iso10646-1"
            } else {
               .main$i.mainfr.editfr.textarea config -font "-*-bengali-medium-$slant-*-*-*-$ptsize-*-*-*-*-*-fontspecific"
            }
            .main$i.mainfr.editfr.textarea config -spacing3 $spacing3
            configTags $i
         }
      }
   }
}

########################     End of main.tcl    ##########################

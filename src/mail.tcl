############################################################################
# mail.tcl: Implements the mail read and send functions
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

proc readInbox { {flag 0} } {
   global inbox mno mfrom msender mdate msubject mrepto mbody mcurr mailEditMode

   if {![string compare $mailEditMode "on"]} {return}
   if {$flag == 0} { set minbox $inbox } else {
      set minbox [getFileName "bwedit: Choose mail folder"]
      if {![string compare $minbox ""]} { return }
   }
   set f [open $minbox r]
   set mlines [split [read $f] "\n"]
   close $f
   set mcurr 0
   set mno 0
   for {set i 0} {$i < [llength $mlines]} {incr i 1} {
      set nextline [lindex $mlines $i]
      if {![string compare "From " [string range $nextline 0 4]]} {
         incr mno 1
         set mbody($mno) ""
         set nextline [string trim [string range $nextline 5 [expr [string length $nextline] - 1]]]
         set spcidx [string first " " $nextline]
         if {$spcidx > 0} {
            set mfrom($mno) [string range $nextline 0 [expr $spcidx - 1]]
            set mdate($mno) [string trim [string range $nextline $spcidx [expr [string length $nextline] - 1]]]
         } else {
            set mfrom($mno) ""
            set mdate($mno) ""
         }
         set msubject($mno) ""
         set msender($mno) ""
         set mrepto($mno) ""
         set status 0
      } elseif {$mno > 0} {
         if {($status == 0)} {
            if {![string compare "" $nextline]} { set status 1 } else {
               if {![string compare "From: " [string range $nextline 0 5]] && ![string compare $msender($mno) ""]} {
                  set msender($mno) [string trim [string range $nextline 6 [expr [string length $nextline] - 1]]]
                  set ltidx [string first "<" $msender($mno)]
                  set gtidx [string first ">" $msender($mno)]
                  if { ($ltidx > 0) && ($gtidx > 0) && ($ltidx < $gtidx) } {
                     set msender($mno) [string trim [string range $msender($mno) 0 [expr $ltidx - 1]]]
                  } elseif { ($ltidx == 0) && ([expr $gtidx + 1] == [string length $msender($mno)])} {
                     set msender($mno) [string trim [string range $msender($mno) 1 [expr $gtidx - 1]]]
                  }
               } elseif {![string compare "Date: " [string range $nextline 0 5]] && ![string compare $mdate($mno) ""]} {
                  set mdate($mno) [string range $nextline 6 [expr [string length $nextline] - 1]]
               } elseif {![string compare "Subject: " [string range $nextline 0 8]] && ![string compare $msubject($mno) ""]} {
                  set msubject($mno) [string range $nextline 9 [expr [string length $nextline] - 1]]
               } elseif {![string compare "Reply-To: " [string range $nextline 0 9]] && ![string compare $mrepto($mno) ""]} {
                  set mrepto($mno) [string range $nextline 10 [expr [string length $nextline] - 1]]
               }
            }
         } else {
            set mbody($mno) "$mbody($mno)\n$nextline"
         }
      }
   }
   unset mlines
   .readmail.contfr.lbx delete 0 end
   for {set i 1} {$i <= $mno} {incr i 1} {
      .readmail.contfr.lbx insert 0 [formattedLine [expr $mno - $i + 1] $mdate($i) $msender($i) $msubject($i)]
   }
   .readmail.dpyfr.textfr.t config -state normal
   .readmail.dpyfr.textfr.t delete 1.0 end
   .readmail.dpyfr.textfr.t config -state disabled
   focus .readmail.dpyfr.textfr.t
   .readmail.fldrfr.h config -text "Current folder is  `$minbox'  with $mno messages"
   showMailNum 1
}

proc formattedLine { no date sender subject } {
   if {$no < 10} {
      set outp "   $no  "
   }  elseif {$no < 100} {
      set outp "  $no  "
   }  elseif {$no < 1000} {
      set outp " $no  "
   }  else {
      set outp "$no  "
   }
   set outp "${outp}[string range $date 4 9]  "
   if {[string length $sender] > 25} {
      set outp "${outp}[string range $sender 0 24] "
   } else {
      set outp "${outp}${sender}"
      while {[string length $outp] < 40} { set outp "$outp "  }
   }
   set outp "$outp $subject"
   return $outp
}

proc readMail { } {
   global appbg appfg btnbg btnfg bweditlogo dpyfont
   global inbox mno mfrom msender mdate msubject mrepto mbody mcurr mailEditMode msrcopt

   if {[winfo exists .readmail]} { focus .readmail ; return }

   set rmwin [toplevel .readmail]
   $rmwin config -bg $appbg
   wm title $rmwin "bwedit: Read mail"

   frame $rmwin.cmdfr -bg $appbg -relief raised -borderwidth 2
   frame $rmwin.fldrfr -bg $appbg -relief flat
   frame $rmwin.contfr -bg $appbg -relief flat
   frame $rmwin.dpyfr -bg $appbg -relief flat
   frame $rmwin.dpyfr.textfr -bg $appbg -relief flat

   menubutton $rmwin.cmdfr.file -text "File" -height 1 -relief flat \
      -menu $rmwin.cmdfr.file.m -bg $appbg -fg $appfg -highlightthickness 0 \
      -activeforeground $appfg -activebackground $appbg
   menubutton $rmwin.cmdfr.mail -text "Mail" -height 1 -relief flat \
      -menu $rmwin.cmdfr.mail.m -bg $appbg -fg $appfg -highlightthickness 0 \
      -activeforeground $appfg -activebackground $appbg
   menubutton $rmwin.cmdfr.option -text "Option" -height 1 -relief flat \
      -menu $rmwin.cmdfr.option.m -bg $appbg -fg $appfg -highlightthickness 0 \
      -activeforeground $appfg -activebackground $appbg
   menubutton $rmwin.cmdfr.help -text "Help" -height 1 -relief flat \
      -menu $rmwin.cmdfr.help.m -bg $appbg -fg $appfg -highlightthickness 0 \
      -activeforeground $appfg -activebackground $appbg

   menu $rmwin.cmdfr.file.m -tearoff false -bg $appbg -fg $appfg -disabledforeground #888888
   $rmwin.cmdfr.file.m add command -label "  New main window " -accelerator " Alt+1 " -command {newMain} -underline 6
   $rmwin.cmdfr.file.m add command -label "  New transliterator window " -accelerator " Alt+2 " -command {newRoman} -underline 6
   $rmwin.cmdfr.file.m add command -label "  Show mail in main window" -accelerator " Alt+3 " -command {loadMail} -underline 2
   $rmwin.cmdfr.file.m add command -label "  Show mail in transliterator window " -accelerator " Alt+4 " -command {loadMailRoman} -underline 3
   $rmwin.cmdfr.file.m add command -label "  BWdecode mail and show " -accelerator " Alt+5 " -command {decodeMail 1} -underline 2
   # $rmwin.cmdfr.file.m add command -label "  MIME decode mail and show " -accelerator " Alt+6 " -command {decodeMail 2} -underline 2
   $rmwin.cmdfr.file.m add command -label "  UUdecode mail and show " -accelerator " Alt+7 " -command {decodeMail 3} -underline 2
   $rmwin.cmdfr.file.m add command -label "  Save mail " -accelerator " F3 " -command {saveMail} -underline 4
   $rmwin.cmdfr.file.m add separator
   $rmwin.cmdfr.file.m add command -label "  Close " -accelerator " Alt+C " -command "set mcurr 0 ; set mailEditMode off ; if {$msrcopt == 3} { set msrcopt -1 } ; destroy $rmwin" -underline 2
   $rmwin.cmdfr.file.m add command -label "  Quit " -accelerator " Alt+Q " -command "quitEditor" -underline 2

   menu $rmwin.cmdfr.mail.m -tearoff false -bg $appbg -fg $appfg -disabledforeground #888888
   $rmwin.cmdfr.mail.m add command -label "  Reread inbox " -accelerator " Alt+R " -command "readInbox" -underline 9
   $rmwin.cmdfr.mail.m add command -label "  Read folder " -command "readInbox 1" -underline 2
   $rmwin.cmdfr.mail.m add separator
   $rmwin.cmdfr.mail.m add command -label "  Show next mail " -accelerator " Down / n / + " -command "showNextMail" -underline 7
   $rmwin.cmdfr.mail.m add command -label "  Show previous mail " -accelerator " Up / p / - " -command "showPrevMail" -underline 7
   $rmwin.cmdfr.mail.m add command -label "  Show first mail " -accelerator " Home " -command "showMailNum 1" -underline 11
   $rmwin.cmdfr.mail.m add command -label "  Show last mail " -accelerator " End " -command {showMailNum $mno} -underline 7
   $rmwin.cmdfr.mail.m add command -label "  Ten mails forward " -accelerator " Right / N " -command "tenForward" -underline 12
   $rmwin.cmdfr.mail.m add command -label "  Ten mails backward " -accelerator " Left / P " -command "tenBackward" -underline 12
   $rmwin.cmdfr.mail.m add command -label "  Goto mail " -accelerator " Hash " -command "gotoMail" -underline 2
   $rmwin.cmdfr.mail.m add separator
   $rmwin.cmdfr.mail.m add command -label "  Send mail " -accelerator " Shift+F9 " -command "sendMail 0" -underline 2
   $rmwin.cmdfr.mail.m add command -label "  Send reply " -accelerator " F9 " -command "sendReply" -underline 3
   $rmwin.cmdfr.mail.m add command -label "  Edit reply " -accelerator " Alt+E " -command "editMail" -underline 3

   menu $rmwin.cmdfr.option.m -tearoff false -bg $appbg -fg $appfg -disabledforeground #888888
   $rmwin.cmdfr.option.m add command -label "  Edit mail options " -accelerator " Alt+O " -command "set opttype 3; editOptions 0" -underline 2
   $rmwin.cmdfr.option.m add command -label "  Save options " -accelerator "" -command "saveOptions 3" -underline 2

   menu $rmwin.cmdfr.help.m -tearoff false -bg $appbg -fg $appfg -disabledforeground #888888
   $rmwin.cmdfr.help.m add command -label "  About bwedit  " -accelerator " F1 " -command {helpWin} -underline 2
   $rmwin.cmdfr.help.m add command -label "  Roman-to-Bengali conversion rules  " -accelerator " Shift+F1 " -command {helpWinRoman} -underline 2
   $rmwin.cmdfr.help.m add command -label "  Copyright notice  " -command {copyInfo} -underline 2

   label $rmwin.cmdfr.blank -text "" -relief flat -bg $appbg -fg $appfg
   label $rmwin.cmdfr.logo -image "bweditlogo" -relief flat -bg $appbg -fg $appfg -cursor hand2
   bind $rmwin.cmdfr.logo <Button-1> { copyInfo }

   label $rmwin.fldrfr.h -text "" -relief flat -fg #ffffff -bg #000000 \
      -font $dpyfont

   listbox $rmwin.contfr.lbx -width 80 -height 10 -bg #ffffff -fg #000000 \
      -yscroll "$rmwin.contfr.vscroll set" -relief flat -highlightthickness 0 \
      -selectmode single -selectforeground #ffffff -selectbackground #000000 \
      -selectborderwidth 0 -font fixed
   scrollbar $rmwin.contfr.vscroll -command "$rmwin.contfr.lbx yview" \
      -troughcolor $appbg -orient vertical -bg $appbg -width 12 \
      -activebackground $appbg

   text $rmwin.dpyfr.textfr.t -relief sunken -height 30 -width 80 \
      -xscroll "$rmwin.dpyfr.hscroll set" -yscroll "$rmwin.dpyfr.textfr.vscroll set" \
      -wrap none -relief flat -font fixed -fg $appfg -bg $appbg \
      -selectborderwidth 0 -selectbackground $appfg -selectforeground $appbg \
      -highlightthickness 0 -state disabled
   scrollbar $rmwin.dpyfr.textfr.vscroll -relief sunken -orient vertical -width 12 \
      -command "$rmwin.dpyfr.textfr.t yview" -bg $appbg -activebackground $appbg
   scrollbar $rmwin.dpyfr.hscroll -relief sunken -orient horizontal -width 12 \
      -command "$rmwin.dpyfr.textfr.t xview" -bg $appbg -activebackground $appbg

   pack $rmwin.cmdfr.file $rmwin.cmdfr.mail $rmwin.cmdfr.option $rmwin.cmdfr.help \
      -side left -padx 4 -pady 0 -side left
   pack $rmwin.cmdfr.blank -side left -expand yes -fill both
   pack $rmwin.cmdfr.logo -side left -padx 5 -pady 0 -side left

   pack $rmwin.fldrfr.h -expand yes -fill x -padx 0 -pady 0 -side left

   pack $rmwin.contfr.vscroll -expand no -fill y -padx 0 -pady 0 -side right
   pack $rmwin.contfr.lbx -expand yes -fill both -padx 0 -pady 0 -side right

   pack $rmwin.dpyfr.textfr.vscroll -side right -padx 0 -pady 0 -expand no -fill y
   pack $rmwin.dpyfr.textfr.t -side right -padx 0 -pady 0 -expand yes -fill both
   pack $rmwin.dpyfr.hscroll -side bottom -padx 0 -pady 0 -expand no -fill x
   pack $rmwin.dpyfr.textfr -side bottom -expand yes -fill both -padx 0 -pady 0

   pack $rmwin.cmdfr -expand no -fill x -padx 0 -pady 0
   pack $rmwin.fldrfr -expand no -fill x -padx 5 -pady 0
   pack $rmwin.contfr -expand no -fill x -padx 5 -pady 0
   pack $rmwin.dpyfr -expand yes -fill both -padx 5 -pady 5

   bind $rmwin.contfr.lbx <ButtonRelease-1> "showMail %Y"
   bind $rmwin.contfr.lbx <KeyRelease-space> "showMail %Y"

   set mailEditMode "off"
   readInbox
   focus $rmwin.dpyfr.textfr.t
   bind $rmwin.dpyfr.textfr.t <Up> {
      if {![string compare $mailEditMode "off"]} {showPrevMail; break}
   }
   bind $rmwin.dpyfr.textfr.t <Down> {
      if {![string compare $mailEditMode "off"]} {showNextMail; break}
   }
   bind $rmwin.dpyfr.textfr.t <Left> {
      if {![string compare $mailEditMode "off"]} {tenBackward; break}
   }
   bind $rmwin.dpyfr.textfr.t <Right> {
      if {![string compare $mailEditMode "off"]} {tenForward; break}
   }

   # Key bindings
   bind $rmwin <Key-plus> {showNextMail}
   bind $rmwin <Key-minus> {showPrevMail}
   bind $rmwin <Key-n> {showNextMail}
   bind $rmwin <Key-p> {showPrevMail}
   bind $rmwin <Key-N> {tenForward}
   bind $rmwin <Key-P> {tenBackward}
   bind $rmwin <Key-numbersign> {gotoMail}
   bind $rmwin <Home> {showMailNum 1}
   bind $rmwin <End> {showMailNum [expr $mno]}

   # Alt-key bindings
   bind $rmwin <Alt-Key-1> {newMain}
   bind $rmwin <Alt-Key-2> {newRoman}
   bind $rmwin <Alt-Key-3> {loadMail}
   bind $rmwin <Alt-Key-4> {loadMailRoman}
   bind $rmwin <Alt-Key-5> {decodeMail 1}
   bind $rmwin <Alt-Key-7> {decodeMail 3}
   bind $rmwin <Alt-c> "set mcurr 0 ; destroy $rmwin ; break"
   bind $rmwin <Alt-C> "set mcurr 0 ; destroy $rmwin ; break"
   bind $rmwin <Alt-e> {editMail}
   bind $rmwin <Alt-E> {editMail}
   bind $rmwin <Alt-o> {set opttype 3; editOptions 0}
   bind $rmwin <Alt-O> {set opttype 3; editOptions 0}
   bind $rmwin <Alt-q> {quitEditor; break}
   bind $rmwin <Alt-Q> {quitEditor; break}
   bind $rmwin <Alt-r> {readInbox}
   bind $rmwin <Alt-R> {readInbox}

   # Function key bindings
   bind $rmwin <F1> {helpWin}
   bind $rmwin <Shift-F1> {helpWinRoman}
   bind $rmwin <F3> {saveMail}
   bind $rmwin <F9> {sendReply}
   bind $rmwin <Shift-F9> {sendMail 0}
   bind $rmwin <F10> {mpostFileMenu ; break}

   # Menu bindings
   bind $rmwin.cmdfr.file.m <Right> "grab release $rmwin.cmdfr.file.m; $rmwin.cmdfr.file.m unpost; mpostMailMenu; break"
   bind $rmwin.cmdfr.mail.m <Right> "grab release $rmwin.cmdfr.mail.m; $rmwin.cmdfr.mail.m unpost; mpostOptionMenu; break"
   bind $rmwin.cmdfr.option.m <Right> "grab release $rmwin.cmdfr.option.m; $rmwin.cmdfr.option.m unpost; mpostHelpMenu; break"
   bind $rmwin.cmdfr.help.m <Right> "grab release $rmwin.cmdfr.help.m; $rmwin.cmdfr.help.m unpost; mpostFileMenu; break"
   bind $rmwin.cmdfr.file.m <Left> "grab release $rmwin.cmdfr.file.m; $rmwin.cmdfr.file.m unpost; mpostHelpMenu; break"
   bind $rmwin.cmdfr.mail.m <Left> "grab release $rmwin.cmdfr.mail.m; $rmwin.cmdfr.mail.m unpost; mpostFileMenu; break"
   bind $rmwin.cmdfr.option.m <Left> "grab release $rmwin.cmdfr.option.m; $rmwin.cmdfr.option.m unpost; mpostMailMenu; break"
   bind $rmwin.cmdfr.help.m <Left> "grab release $rmwin.cmdfr.help.m; $rmwin.cmdfr.help.m unpost; mpostOptionMenu; break"
}

proc mpostFileMenu { } {
   set posx [winfo x .readmail]
   incr posx [winfo x .readmail.cmdfr.file]
   set posy [winfo y .readmail]
   incr posy [winfo y .readmail.cmdfr.file]
   incr posy [winfo height .readmail.cmdfr.file]
   .readmail.cmdfr.file.m post $posx $posy
   .readmail.cmdfr.file.m activate 0
   grab set -global .readmail.cmdfr.file.m
   focus .readmail.cmdfr.file.m
}

proc mpostMailMenu { } {
   set posx [winfo x .readmail]
   incr posx [winfo x .readmail.cmdfr.mail]
   set posy [winfo y .readmail]
   incr posy [winfo y .readmail.cmdfr.mail]
   incr posy [winfo height .readmail.cmdfr.mail]
   .readmail.cmdfr.mail.m post $posx $posy
   .readmail.cmdfr.mail.m activate 0
   grab set -global .readmail.cmdfr.mail.m
   focus .readmail.cmdfr.mail.m
}

proc mpostOptionMenu { } {
   set posx [winfo x .readmail]
   incr posx [winfo x .readmail.cmdfr.option]
   set posy [winfo y .readmail]
   incr posy [winfo y .readmail.cmdfr.option]
   incr posy [winfo height .readmail.cmdfr.option]
   .readmail.cmdfr.option.m post $posx $posy
   .readmail.cmdfr.option.m activate 0
   grab set -global .readmail.cmdfr.option.m
   focus .readmail.cmdfr.option.m
}

proc mpostHelpMenu { } {
   set posx [winfo x .readmail]
   incr posx [winfo x .readmail.cmdfr.help]
   set posy [winfo y .readmail]
   incr posy [winfo y .readmail.cmdfr.help]
   incr posy [winfo height .readmail.cmdfr.help]
   .readmail.cmdfr.help.m post $posx $posy
   .readmail.cmdfr.help.m activate 0
   grab set -global .readmail.cmdfr.help.m
   focus .readmail.cmdfr.help.m
}

proc showMail { Y } {
   global mbody mdate msender msubject mrepto mno mcurr mailEditMode

   if {![string compare $mailEditMode "on"]} {return}
   set mi 0
   foreach si [.readmail.contfr.lbx curselection] { set mi [expr $mno - $si] }
   if {$mi != 0} {
      set mcurr $mi
      .readmail.dpyfr.textfr.t config -state normal
      .readmail.dpyfr.textfr.t delete 1.0 end
      .readmail.dpyfr.textfr.t insert insert "    From: $msender($mi)\n"
      .readmail.dpyfr.textfr.t insert insert "    Date: $mdate($mi)\n"
      .readmail.dpyfr.textfr.t insert insert " Subject: $msubject($mi)\n"
      if {[string compare $mrepto($mi) ""]} {
         .readmail.dpyfr.textfr.t insert insert "Reply-to: $mrepto($mi)\n"
      }
      .readmail.dpyfr.textfr.t insert insert $mbody($mi)
      .readmail.dpyfr.textfr.t config -state disabled
   }
}

proc showMailNum { n } {
   global mbody mdate msender mrepto msubject mno mcurr mailEditMode

   if {![string compare $mailEditMode "on"]} {return}
   if {($n < 1) || ($n > $mno)} {return}
   set mcurr [expr $mno - $n + 1]
   .readmail.dpyfr.textfr.t config -state normal
   .readmail.dpyfr.textfr.t delete 1.0 end
   .readmail.dpyfr.textfr.t insert insert "    From: $msender($mcurr)\n"
   .readmail.dpyfr.textfr.t insert insert "    Date: $mdate($mcurr)\n"
   .readmail.dpyfr.textfr.t insert insert " Subject: $msubject($mcurr)\n"
   if {[string compare $mrepto($mcurr) ""]} {
      .readmail.dpyfr.textfr.t insert insert "Reply-to: $mrepto($mcurr)\n"
   }
   .readmail.dpyfr.textfr.t insert insert $mbody($mcurr)
   .readmail.dpyfr.textfr.t config -state disabled
   .readmail.contfr.lbx select clear 0 end
   .readmail.contfr.lbx select set [expr $n - 1]
   .readmail.contfr.lbx see [expr $n - 1]
}

proc showNextMail { } {
   global mno mcurr

   showMailNum [expr $mno - $mcurr + 2]
}

proc showPrevMail { } {
   global mno mcurr

   showMailNum [expr $mno - $mcurr]
}

proc tenForward { } {
   global mno mcurr

   showMailNum [expr $mno - $mcurr + 11]
}

proc tenBackward { } {
   global mno mcurr

   showMailNum [expr $mno - $mcurr - 9]
}

proc gotoMail { } {
   global appbg appfg btnbg btnfg dpyfont gtmok mcurr mno mailEditMode

   if {![string compare $mailEditMode "on"]} {return}
   set gtmok 0
   set gtmbox [toplevel .gotomail]
   $gtmbox config -bg $appbg
   label $gtmbox.hdr -relief flat -fg $appfg -bg $appbg -text "Goto mail" -font $dpyfont
   frame $gtmbox.fr1 -relief flat -bg $appbg
   frame $gtmbox.fr2 -relief flat -bg $appbg
   frame $gtmbox.fr3 -relief flat -bg $appbg
   frame $gtmbox.fr4 -relief flat -bg $appbg

   label $gtmbox.fr1.l -text "Mail no:" -fg $appfg -bg $appbg -font $dpyfont
   entry $gtmbox.fr1.e -width 10 -bg #88ddff -fg #000000 \
      -selectforeground #88ddff -selectbackground #000000 -selectborderwidth 0
   $gtmbox.fr1.e insert insert [expr $mno - $mcurr + 1]
   button $gtmbox.fr1.b -text "Goto" -command { set gtmok [expr round([string trim [.gotomail.fr1.e get]])] } \
      -fg $btnfg -bg $btnbg -activeforeground $btnfg -activebackground $btnbg -underline 0

   button $gtmbox.fr2.n -text "Next" -command { set gtmok [expr $mno - $mcurr + 2] } \
      -fg $btnfg -bg $btnbg -activeforeground $btnfg -activebackground $btnbg -underline 0
   button $gtmbox.fr2.p -text "Previous" -command { set gtmok [expr $mno - $mcurr] } \
      -fg $btnfg -bg $btnbg -activeforeground $btnfg -activebackground $btnbg -underline 0
   button $gtmbox.fr2.f -text "First" -command { set gtmok 1 } \
      -fg $btnfg -bg $btnbg -activeforeground $btnfg -activebackground $btnbg -underline 4
   button $gtmbox.fr2.l -text "Last" -command { set gtmok $mno } \
      -fg $btnfg -bg $btnbg -activeforeground $btnfg -activebackground $btnbg -underline 0

   button $gtmbox.fr4.b -text "Cancel" -command { set gtmok 0 } \
      -fg $btnfg -bg $btnbg -activeforeground $btnfg -activebackground $btnbg -underline 0

   label $gtmbox.fr3.l -text "Shift:" -fg $appfg -bg $appbg -font $dpyfont
   entry $gtmbox.fr3.e -width 10 -bg #88ddff -fg #000000 \
      -selectforeground #88ddff -selectbackground #000000 -selectborderwidth 0
   $gtmbox.fr3.e insert insert "10"
   button $gtmbox.fr3.f -text "Forward" -command { set gtmok [expr $mno - $mcurr + 1 + round([string trim [.gotomail.fr3.e get]])] } \
      -fg $btnfg -bg $btnbg -activeforeground $btnfg -activebackground $btnbg -underline 0
   button $gtmbox.fr3.b -text "Backward" -command { set gtmok [expr $mno - $mcurr + 1 - round([string trim [.gotomail.fr3.e get]])] } \
      -fg $btnfg -bg $btnbg -activeforeground $btnfg -activebackground $btnbg -underline 0

   pack $gtmbox.fr1.l $gtmbox.fr1.e -expand no -padx 0 -pady 0 -side left
   pack $gtmbox.fr1.b -expand no -padx 10 -pady 0 -side left
   pack $gtmbox.fr2.n $gtmbox.fr2.p $gtmbox.fr2.f $gtmbox.fr2.l -expand no -padx 5 -pady 0 -side left
   pack $gtmbox.fr3.l $gtmbox.fr3.e -expand no -padx 0 -pady 0 -side left
   pack $gtmbox.fr3.f -expand no -padx 10 -pady 0 -side left
   pack $gtmbox.fr3.b -expand no -padx 0 -pady 0 -side left
   pack $gtmbox.fr4.b -expand no -padx 0 -pady 0
   pack $gtmbox.hdr $gtmbox.fr1 $gtmbox.fr2 $gtmbox.fr3 $gtmbox.fr4 \
      -expand no -padx 5 -pady 5

   wm resizable $gtmbox false false
   wm title $gtmbox "bwedit: Goto mail"
   focus $gtmbox.fr1.e
   bind $gtmbox.fr1.e <Return> { focus .gotomail.fr3.e }
   bind $gtmbox.fr3.e <Return> { focus .gotomail.fr1.e }
   bind $gtmbox <Alt-B> { .gotomail.fr3.b invoke }
   bind $gtmbox <Alt-C> { .gotomail.fr4.b invoke }
   bind $gtmbox <Alt-F> { .gotomail.fr3.f invoke }
   bind $gtmbox <Alt-G> { .gotomail.fr1.b invoke }
   bind $gtmbox <Alt-L> { .gotomail.fr2.l invoke }
   bind $gtmbox <Alt-N> { .gotomail.fr2.n invoke }
   bind $gtmbox <Alt-P> { .gotomail.fr2.p invoke }
   bind $gtmbox <Alt-T> { .gotomail.fr2.f invoke }
   bind $gtmbox <Alt-b> { .gotomail.fr3.b invoke }
   bind $gtmbox <Alt-c> { .gotomail.fr4.b invoke }
   bind $gtmbox <Alt-f> { .gotomail.fr3.f invoke }
   bind $gtmbox <Alt-g> { .gotomail.fr1.b invoke }
   bind $gtmbox <Alt-l> { .gotomail.fr2.l invoke }
   bind $gtmbox <Alt-n> { .gotomail.fr2.n invoke }
   bind $gtmbox <Alt-p> { .gotomail.fr2.p invoke }
   bind $gtmbox <Alt-t> { .gotomail.fr2.f invoke }
   bind $gtmbox <Escape> { .gotomail.fr2.p invoke }

   grab $gtmbox
   tkwait variable gtmok
   grab release $gtmbox
   destroy $gtmbox
   showMailNum $gtmok
}

proc editMail { } {
   global mailEditMode mno mcurr mrepto

   if {![string compare $mailEditMode "off"]} {
      set mlines [split [.readmail.dpyfr.textfr.t get 1.0 end] "\n"]
      .readmail.dpyfr.textfr.t config -state normal
      .readmail.dpyfr.textfr.t delete 1.0 end
      if {[string compare $mrepto($mcurr) ""]} { set fline 4 } else { set fline 3 }
      for {set i $fline} {$i < [llength $mlines]} {incr i 1} {
         .readmail.dpyfr.textfr.t insert end "> [lindex $mlines $i]\n"
      }
      unset mlines
      set mailEditMode "on"
      .readmail.dpyfr.textfr.t see insert
      .readmail.cmdfr.mail.m entryconfigure 0 -state disabled
      .readmail.cmdfr.mail.m entryconfigure 1 -state disabled
      .readmail.cmdfr.mail.m entryconfigure 3 -state disabled
      .readmail.cmdfr.mail.m entryconfigure 4 -state disabled
      .readmail.cmdfr.mail.m entryconfigure 5 -state disabled
      .readmail.cmdfr.mail.m entryconfigure 6 -state disabled
      .readmail.cmdfr.mail.m entryconfigure 7 -state disabled
      .readmail.cmdfr.mail.m entryconfigure 8 -state disabled
      .readmail.cmdfr.mail.m entryconfigure 9 -state disabled
      .readmail.cmdfr.mail.m entryconfigure 13 -label "  Done editing " -underline 2
   } else {
      set mailEditMode "off"
      showMailNum [expr $mno - $mcurr + 1]
      .readmail.cmdfr.mail.m entryconfigure 0 -state active
      .readmail.cmdfr.mail.m entryconfigure 1 -state active
      .readmail.cmdfr.mail.m entryconfigure 3 -state active
      .readmail.cmdfr.mail.m entryconfigure 4 -state active
      .readmail.cmdfr.mail.m entryconfigure 5 -state active
      .readmail.cmdfr.mail.m entryconfigure 6 -state active
      .readmail.cmdfr.mail.m entryconfigure 7 -state active
      .readmail.cmdfr.mail.m entryconfigure 8 -state active
      .readmail.cmdfr.mail.m entryconfigure 9 -state active
      .readmail.cmdfr.mail.m entryconfigure 13 -label "  Edit reply " -underline 3
   }
}

proc loadMail { } {
   global mno mbody dirtybit mcurr newTclTk

   set myid [newMain]
   if {$mcurr == 0} {
      if ($newTclTk) {
         .main$myid.mainfr.editfr.textarea insert insert [encfrom [.readmail.dpyfr.textfr.t get 1.0 end]]
      } else {
         .main$myid.mainfr.editfr.textarea insert insert [.readmail.dpyfr.textfr.t get 1.0 end]
      }
   } else {
      if ($newTclTk) {
         .main$myid.mainfr.editfr.textarea insert insert [enfrom $mbody($mcurr)]
      } else {
         .main$myid.mainfr.editfr.textarea insert insert $mbody($mcurr)
      }
   }
   .main$myid.mainfr.editfr.textarea see insert
   set dirtybit($myid) 1
}

proc loadMailRoman { } {
   global mno mbody rdirtybit mcurr

   set myid [newRoman]
   if {$mcurr == 0} {
      .roman$myid.mainfr.editfr.textarea insert insert [.readmail.dpyfr.textfr.t get 1.0 end]
   } else {
      .roman$myid.mainfr.editfr.textarea insert insert $mbody($mcurr)
   }
   .roman$myid.mainfr.editfr.textarea see insert
   set rdirtybit($myid) 1
}

proc decodeMail { type } {
   global bwmaildir mbody mno mcurr

   if {$mcurr == 0} { return }
   if {![file exists $bwmaildir]} {
      exec mkdir $bwmaildir
      exec chmod 700 $bwmaildir
   }
   if {!([file exists $bwmaildir] && [file isdirectory $bwmaildir] && [file writable $bwmaildir])} {
      return
   }
   set f [open "$bwmaildir/tmp.mail" w]
   puts -nonewline $f $mbody($mcurr)
   close $f
   switch -exact $type {
      "1" {
         readBW 0 0 "$bwmaildir/tmp.mail"
      }
      "2" {
         readMIME 0 0 "$bwmaildir/tmp.mail"
      }
      "3" {
         readUU 0 0 "$bwmaildir/tmp.mail"
      }
   }
   exec rm "$bwmaildir/tmp.mail"
}

proc saveMail { } {
   global mbody mno mcurr

   set fnm [getFileName "bwedit: Save mail"]
   if {![string compare "" $fnm]} { return }
   set dnm [file dirname $fnm]
   if {![file isdirectory $dnm]} { return }
   if {![file writable $dnm]} { return }
   if {[file exists $fnm] && ![file isfile $fnm]} { return }
   if {[file exists $fnm] && ![file writable $fnm]} { return }
   set f [open $fnm w]
   if {$mcurr > 0} {
      puts -nonewline $f $mbody($mcurr)
   } else {
      puts -nonewline $f [.readmail.dpyfr.textfr.t get 1.0 end]
   }
   close $f
}

proc sendReply { } {
   global mbody mno mfrom mrepto mcurr msubject mailEditMode

   if {$mcurr > 0} {
      if {![string compare $mailEditMode "off"]} {editMail}
      sendMail 3
      .sendmail.fr1.ent delete 0 end
      if {[string compare $mrepto($mcurr) "" ]} {
         .sendmail.fr1.ent insert end $mrepto($mcurr)
      } else {
         .sendmail.fr1.ent insert end $mfrom($mcurr)
      }
      .sendmail.fr2.ent delete 0 end
      if {[string length $msubject($mcurr)] == 0} {
         .sendmail.fr2.ent insert end "Re: Your mail"
      } elseif {![string compare "Re:" [string range $msubject($mcurr) 0 2]]} {
         .sendmail.fr2.ent insert end "$msubject($mcurr)"
      } else {
         .sendmail.fr2.ent insert end "Re: $msubject($mcurr)"
      }
   }
}

set msrcopt -1
set mfname ""
proc sendMail { option { myid 0 } } {
   global btnbg btnfg appbg appfg
   global msrcopt mfname mtwin rmtwin mailEditMode newTclTk

   if {[winfo exists .sendmail]} {
      if {$option == 1} {
         set msrcopt 1
         set mtwin $myid
         .sendmail.fr6.rad config -text "Main window $myid" -fg $appfg -activeforeground $appfg
         .sendmail.fr6.btn config -state active
         .sendmail.fr5.rad config -fg #A2A2A2 -activeforeground #A2A2A2
         .sendmail.fr5.btn config -state disabled
         .sendmail.fr5.ent config -state disabled -fg #A2A2A2
         .sendmail.fr7.rad config -fg #A2A2A2 -activeforeground #A2A2A2
         .sendmail.fr7.btn config -state disabled
         .sendmail.fr8.rad config -fg #A2A2A2 -activeforeground #A2A2A2
      } elseif {$option == 2} {
         set msrcopt 2
         set rmtwin $myid
         .sendmail.fr7.rad config -text "Transliterator window $myid" -fg $appfg -activeforeground $appfg
         .sendmail.fr7.btn config -state active
         .sendmail.fr5.rad config -fg #A2A2A2 -activeforeground #A2A2A2
         .sendmail.fr5.btn config -state disabled
         .sendmail.fr5.ent config -state disabled -fg #A2A2A2
         .sendmail.fr6.rad config -fg #A2A2A2 -activeforeground #A2A2A2
         .sendmail.fr6.btn config -state disabled
         .sendmail.fr8.rad config -fg #A2A2A2 -activeforeground #A2A2A2
      } elseif {$option == 3} {
         set msrcopt 3
         .sendmail.fr8.rad config -fg $appfg -activeforeground $appfg
         .sendmail.fr5.rad config -fg #A2A2A2 -activeforeground #A2A2A2
         .sendmail.fr5.btn config -state disabled
         .sendmail.fr6.rad config -fg #A2A2A2 -activeforeground #A2A2A2
         .sendmail.fr6.btn config -state disabled
         .sendmail.fr7.rad config -fg #A2A2A2 -activeforeground #A2A2A2
         .sendmail.fr7.btn config -state disabled
      }
      mupdateMenus
      focus .sendmail
      return
   }

   set mtwin 0
   set rmtwin 0

   set mwin [toplevel .sendmail]
   $mwin config -bg $appbg
   wm title $mwin "bwedit: Send mail"
   wm resizable $mwin false false

   frame $mwin.fr1 -bg $appbg
   frame $mwin.fr2 -bg $appbg
   frame $mwin.fr3 -bg $appbg
   frame $mwin.fr4 -bg $appbg
   frame $mwin.fr5 -bg $appbg
   frame $mwin.fr6 -bg $appbg
   frame $mwin.fr7 -bg $appbg
   frame $mwin.fr8 -bg $appbg
   frame $mwin.frA -bg $appbg

   label $mwin.fr1.lbl -text "To:" -relief flat -anchor w -fg $appfg -bg $appbg
   entry $mwin.fr1.ent -bg #ddaaaa -fg #000000 -width 40
   label $mwin.fr2.lbl -text "Subject:" -relief flat -anchor w -fg $appfg -bg $appbg
   entry $mwin.fr2.ent -bg #ddaaaa -fg #000000 -width 40
   label $mwin.fr3.lbl -text "Encoding:" -relief flat -anchor w -fg $appfg -bg $appbg
   menubutton $mwin.fr3.btn -text "Plain text" -height 1 -width 15 \
      -relief raised -menu $mwin.fr3.btn.m -bg $appbg -fg $appfg \
      -activebackground $appbg -activeforeground $appfg
   menu $mwin.fr3.btn.m -tearoff false -bg $appbg -fg $appfg
   $mwin.fr3.btn.m add command -label " Plain text " -command "$mwin.fr3.btn config -text {Plain text}"
   $mwin.fr3.btn.m add command -label " bwencode " -command "$mwin.fr3.btn config -text {bwencode}"
   $mwin.fr3.btn.m add command -label " MIME encoding " -command "$mwin.fr3.btn config -text {MIME encoding}"
   $mwin.fr3.btn.m add command -label " uuencode " -command "$mwin.fr3.btn config -text {uuencode}"
   label $mwin.fr4.lbl -text "Read mail body from: " -relief flat -anchor w -fg $appfg -bg $appbg
   radiobutton $mwin.fr5.rad  -relief flat -highlightthickness 0 \
      -selectcolor #bbff00 -fg #A2A2A2 -bg $appbg \
      -activebackground $appbg -activeforeground #A2A2A2 \
      -variable msrcopt -value 0 -text "File"
   entry $mwin.fr5.ent -textvariable mfname -bg #ddaaaa -fg #A2A2A2 -width 20 -state disabled
   button $mwin.fr5.btn -text "Browse" -relief raised -fg $appfg -bg $appbg \
      -activeforeground $appfg -activebackground $appbg \
      -command {set mfname [getFileName "bwedit: Choose file to mail"]} \
      -state disabled -disabledforeground #A2A2A2
   radiobutton $mwin.fr6.rad  -relief flat -highlightthickness 0 \
      -selectcolor #bbff00 -fg #A2A2A2 -bg $appbg \
      -activebackground $appbg -activeforeground #A2A2A2 \
      -variable msrcopt -value 1 -text "Main window" -width 25 -anchor w
   menubutton $mwin.fr6.btn -text "Select window" -height 1 -width 15 \
      -relief raised -menu $mwin.fr6.btn.m -bg $appbg -fg $appfg \
      -activebackground $appbg -activeforeground $appfg \
      -state disabled -disabledforeground #A2A2A2
   menu $mwin.fr6.btn.m -tearoff false -bg $appbg -fg $appfg
   radiobutton $mwin.fr7.rad  -relief flat -highlightthickness 0 \
      -selectcolor #bbff00 -fg #A2A2A2 -bg $appbg \
      -activebackground $appbg -activeforeground #A2A2A2 \
      -variable msrcopt -value 2 -text "Transliterator window" -width 25 -anchor w
   menubutton $mwin.fr7.btn -text "Select window" -height 1 -width 15 \
      -relief raised -menu $mwin.fr7.btn.m -bg $appbg -fg $appfg \
      -activebackground $appbg -activeforeground $appfg \
      -state disabled -disabledforeground #A2A2A2
   menu $mwin.fr7.btn.m -tearoff false -bg $appbg -fg $appfg
   radiobutton $mwin.fr8.rad  -relief flat -highlightthickness 0 \
      -selectcolor #bbff00 -fg #A2A2A2 -bg $appbg \
      -activebackground $appbg -activeforeground #A2A2A2 \
      -variable msrcopt -value 3 -text "Edited mail in read mail window" -anchor w
   button $mwin.frA.send -text "Send" -relief raised -command "sendThisMail" \
      -fg $btnfg -bg $btnbg -activeforeground $btnfg -activebackground $btnbg -underline 0
   button $mwin.frA.close -text "Close" -relief raised -command "destroy $mwin" \
      -fg $btnfg -bg $btnbg -activeforeground $btnfg -activebackground $btnbg -underline 0
   label $mwin.frA.space -text "" -fg $appfg -bg $appbg -relief flat

   pack $mwin.fr1.lbl -padx 5 -pady 5 -side left -expand yes -fill x
   pack $mwin.fr1.ent -padx 5 -pady 5
   pack $mwin.fr2.lbl -padx 5 -pady 5 -side left -expand yes -fill x
   pack $mwin.fr2.ent -padx 5 -pady 5
   pack $mwin.fr3.lbl $mwin.fr3.btn -padx 5 -pady 5 -expand no -side left
   pack $mwin.fr4.lbl -padx 5 -pady 5 -side left -expand yes -fill x
   pack $mwin.fr5.rad -expand no -side left -padx 5 -pady 5
   pack $mwin.fr5.ent -expand yes -fill x -side left -padx 5 -pady 5
   pack $mwin.fr5.btn -expand no -side left -padx 5 -pady 5
   pack $mwin.fr6.rad -expand no -side left -padx 5 -pady 5
   pack $mwin.fr6.btn -expand yes -fill x -side left -padx 5 -pady 5
   pack $mwin.fr7.rad -expand no -side left -padx 5 -pady 5
   pack $mwin.fr7.btn -expand yes -fill x -side left -padx 5 -pady 5
   pack $mwin.fr8.rad -expand no -side left -padx 5 -pady 5
   pack $mwin.frA.send -padx 5 -pady 5 -expand no -side left
   pack $mwin.frA.space -padx 5 -pady 5 -expand yes -fill x -side left
   pack $mwin.frA.close -padx 5 -pady 5 -expand no -side left
   pack $mwin.fr1 $mwin.fr2 -expand yes -fill x
   pack $mwin.fr3 -expand no
   pack $mwin.fr4 $mwin.fr5 $mwin.fr6 $mwin.fr7 $mwin.fr8 -expand yes -fill x
   pack $mwin.frA -expand yes -fill x

   mupdateMenus

   if {$option == 0} {
      if {$msrcopt == 0} {
         $mwin.fr5.btn config -state active
         $mwin.fr5.ent config -state normal -fg $appfg
         $mwin.fr5.rad config -fg $appfg -activeforeground $appfg
      } elseif {$msrcopt == 1} {
         $mwin.fr6.btn config -state active
         $mwin.fr6.rad config -fg $appfg -activeforeground $appfg
      } elseif {$msrcopt == 2} {
         $mwin.fr7.btn config -state active
         $mwin.fr7.rad config -fg $appfg -activeforeground $appfg
      } elseif {$msrcopt == 3} {
         $mwin.fr8.rad config -fg $appfg -activeforeground $appfg
      }
   } elseif {$option == 1} {
      $mwin.fr6.btn config -state active
      $mwin.fr6.rad config -text "Main window $myid"
      $mwin.fr6.rad config -fg $appfg -activeforeground $appfg
      set mtwin $myid
      set msrcopt 1
   } elseif {$option == 2} {
      $mwin.fr7.btn config -state active
      $mwin.fr7.rad config -text "Transliterator window $myid"
      $mwin.fr7.rad config -fg $appfg -activeforeground $appfg
      set rmtwin "$myid"
      set msrcopt 2
   } elseif {$option == 3} {
      $mwin.fr8.rad config -fg $appfg -activeforeground $appfg
      set msrcopt 3
   }

   bind $mwin.fr5.rad <ButtonPress-1> "
      $mwin.fr5.rad config -fg $appfg -activeforeground $appfg
      $mwin.fr5.btn config -state active
      $mwin.fr5.ent config -state normal -fg $appfg
      $mwin.fr6.rad config -fg #A2A2A2 -activeforeground #A2A2A2
      $mwin.fr6.btn config -state disabled
      $mwin.fr7.rad config -fg #A2A2A2 -activeforeground #A2A2A2
      $mwin.fr7.btn config -state disabled
      $mwin.fr8.rad config -fg #A2A2A2 -activeforeground #A2A2A2
   "
   bind $mwin.fr6.rad <ButtonPress-1> "
      $mwin.fr5.rad config -fg #A2A2A2 -activeforeground #A2A2A2
      $mwin.fr5.btn config -state disabled
      $mwin.fr5.ent config -state disabled -fg #A2A2A2
      $mwin.fr6.rad config -fg $appfg -activeforeground $appfg
      $mwin.fr6.btn config -state active
      $mwin.fr7.rad config -fg #A2A2A2 -activeforeground #A2A2A2
      $mwin.fr7.btn config -state disabled
      $mwin.fr8.rad config -fg #A2A2A2 -activeforeground #A2A2A2
   "
   bind $mwin.fr7.rad <ButtonPress-1> "
      $mwin.fr5.rad config -fg #A2A2A2 -activeforeground #A2A2A2
      $mwin.fr5.btn config -state disabled
      $mwin.fr5.ent config -state disabled -fg #A2A2A2
      $mwin.fr6.rad config -fg #A2A2A2 -activeforeground #A2A2A2
      $mwin.fr6.btn config -state disabled
      $mwin.fr7.rad config -fg $appfg -activeforeground $appfg
      $mwin.fr7.btn config -state active
      $mwin.fr8.rad config -fg #A2A2A2 -activeforeground #A2A2A2
   "
   bind $mwin.fr8.rad <ButtonPress-1> {
      .sendmail.fr5.rad config -fg #A2A2A2 -activeforeground #A2A2A2
      .sendmail.fr5.btn config -state disabled
      .sendmail.fr5.ent config -state disabled -fg #A2A2A2
      .sendmail.fr6.rad config -fg #A2A2A2 -activeforeground #A2A2A2
      .sendmail.fr6.btn config -state disabled
      .sendmail.fr7.rad config -fg #A2A2A2 -activeforeground #A2A2A2
      .sendmail.fr7.btn config -state disabled
      if {[winfo exists .readmail]} {
         .sendmail.fr8.rad config -fg $appfg -activeforeground $appfg
         if {![string compare $mailEditMode "off"]} {editMail}
      } else {
         set msrcopt -1
         .sendmail.fr8.rad config -fg #A2A2A2 -activeforeground #A2A2A2
         break
      }
   }

   bind $mwin.fr1.ent <Return> "focus $mwin.fr2.ent"
   bind $mwin.fr2.ent <Return> "focus $mwin.fr1.ent"
   bind $mwin <Alt-s> "$mwin.frA.send invoke"
   bind $mwin <Alt-S> "$mwin.frA.send invoke"
   bind $mwin <Alt-c> "$mwin.frA.close invoke; break"
   bind $mwin <Alt-C> "$mwin.frA.close invoke; break"
   bind $mwin <Escape> "$mwin.frA.close invoke; break"
}

proc sendThisMail { } {
   global bwmaildir mailcmd mimen mimed uun uud
   global msrcopt mtwin rmtwin mfname mailEditMode newTclTk

   if {![file exists $bwmaildir]} {
      exec mkdir $bwmaildir
      exec chmod 700 $bwmaildir
   }
   if {!([file exists $bwmaildir] && [file isdirectory $bwmaildir] && [file writable $bwmaildir])} {
      if {$msrcopt == 1} { errmsg $mtwin "Unable to access mail directory $bwmaildir" }
      if {$msrcopt == 2} { errmsg2 $rmtwin "Unable to access mail directory $bwmaildir" }
      return
   }

   set fno 1
   while {[file exists $bwmaildir/raw.$fno]} { incr fno 1 }

   if {$msrcopt == 0} {
      if {[string length $mfname] == 0} { return }
      if {[file exists $mfname] && [file isfile $mfname] && [file readable $mfname]} {
         exec cp $mfname $bwmaildir/raw.$fno
      } else { return }
   } elseif {$msrcopt == 1} {
      if {$mtwin <= 0} { return }
      if {![winfo exists ".main$mtwin"]} { return }
      if {($newTclTk)} {
         set t [encto [.main$mtwin.mainfr.editfr.textarea get 1.0 end]]
      } else {
         set t [.main$mtwin.mainfr.editfr.textarea get 1.0 end]
      }
      set rawfile [open $bwmaildir/raw.$fno w]
      puts -nonewline $rawfile $t
      close $rawfile
   } elseif {$msrcopt == 2} {
      if {$rmtwin <= 0} { return }
      if {![winfo exists ".roman$rmtwin"]} { return }
      set t [.roman$rmtwin.mainfr.editfr.textarea get 1.0 end]
      set rawfile [open $bwmaildir/raw.$fno w]
      puts -nonewline $rawfile $t
      close $rawfile
   } elseif {$msrcopt == 3} {
      if {![winfo exists .readmail]} {return}
      if {![string compare $mailEditMode "off"]} {return}
      set t [.readmail.dpyfr.textfr.t get 1.0 end]
      set rawfile [open $bwmaildir/raw.$fno w]
      puts -nonewline $rawfile $t
      close $rawfile
   } else { return }

   set mailto [.sendmail.fr1.ent get]
   set mailsub [.sendmail.fr2.ent get]
   set enctype [.sendmail.fr3.btn cget -text]
   if {![string compare $enctype "Plain text"]} {
      exec cp $bwmaildir/raw.$fno $bwmaildir/snd.$fno
   } elseif {![string compare $enctype "MIME encoding"]} {
      regsub -all "%f" $mimen $bwmaildir/raw.$fno enccmd
      set t [eval exec $enccmd]
      set sndfile [open $bwmaildir/snd.$fno w]
      puts $sndfile $t
      close $sndfile
   } elseif {![string compare $enctype "uuencode"]} {
      regsub -all "%f" $uun $bwmaildir/raw.$fno enccmd
      set t [eval exec $enccmd]
      set sndfile [open $bwmaildir/snd.$fno w]
      puts $sndfile $t
      close $sndfile
   } elseif {![string compare $enctype "bwencode"]} {
      if {$msrcopt == 1} {
         bwenc $bwmaildir/raw.$fno $bwmaildir/snd.$fno 0
      } else {
         bwenc $bwmaildir/raw.$fno $bwmaildir/snd.$fno 1
      }
   }
   regsub -all "%f" $mailcmd  $bwmaildir/snd.$fno emc
   regsub -all "%s" $emc "\"$mailsub\"" emc
   regsub -all "%r" $emc "\"$mailto\"" emc
   set mailto [string trim $mailto]
   if {[string length $mailto] > 0} {
      eval exec $emc
   } else {
      if {$msrcopt == 1} { errmsg $mtwin "No recipient given" }
      if {$msrcopt == 2} { errmsg2 $rmtwin "No recipient given" }
   }
}

proc hexdigit { decimal } {
   if { ($decimal < 0) || ($decimal >= 16) } {
      return "?";
   }
   if { $decimal < 10 } { return "$decimal" }
   if { $decimal == 10 } { return "A" }
   if { $decimal == 11 } { return "B" }
   if { $decimal == 12 } { return "C" }
   if { $decimal == 13 } { return "D" }
   if { $decimal == 14 } { return "E" }
   return "F";
}

proc bwenc { inf outf option } {
   global customfontno customfid mtwin

   set f [open $inf r]
   set t [read $f]
   close $f
   set f [open $outf w]
   set tt "begin bwenc\n$option\n"
   set len [string length $t]
   for {set i 0} {$i < $len} {incr i 1} {
      set nextch [string range $t $i $i]
      if {![string compare $nextch "\n"]} {
         set tt "$tt\n"
      } else {
         scan $nextch "%c" asciival
         set tt "$tt[hexdigit [expr $asciival / 16]][hexdigit [expr $asciival % 16]]"
      }
   }
   puts $f $tt
   puts $f "end bwenc"
   if {($option == 0)} {
      set mwin ".main$mtwin"
      foreach point {100 120 150 180 210 250 300 360} {
         set tagranges [$mwin.mainfr.editfr.textarea tag ranges bengali${point}o ]
         if {[llength $tagranges] > 0} { puts $f "bengali${point}o\t: $tagranges" }
         set tagranges [$mwin.mainfr.editfr.textarea tag ranges bengali${point}r ]
         if {[llength $tagranges] > 0} { puts $f "bengali${point}r\t: $tagranges" }
      }
      for {set i 0} {$i < $customfontno($mtwin)} {incr i 1} {
         set tagname customftag$i
         set tagranges [$mwin.mainfr.editfr.textarea tag ranges $tagname]
         if {[llength $tagranges] > 0} {
            set fid $customfid("$mtwin:$i")
            puts $f "customfont\t: $fid\t$tagranges"
         }
      }
      foreach tagname { english ultag suptag supsuptag subsuptag subtag subsubtag supsubtag } {
         set tagranges [$mwin.mainfr.editfr.textarea tag ranges $tagname]
         if {[llength $tagranges] > 0} { puts $f "$tagname\t: $tagranges" }
      }
   }
   close $f
}

proc readBW { option {myid 0} {fn ""} } {
   global dirtybit rdirtybit newTclTk

   if {![string compare $fn ""]} {
      set fn [getFileName "bwedit: read bwencoded file"]
   }
   if { [string compare $fn ""] != 0 } {
      if {![file readable $fn]} {
         if {$option == 1} {
            errmsg $myid "ERROR:\nI cannot load the file \"$fn\". The file does not exist or does not have read permission."
         } elseif {$option == 2} {
            errmsg2 $myid "ERROR:\nI cannot load the file \"$fn\". The file does not exist or does not have read permission."
         }
         return
      }
      if {![file isfile $fn]} {
         if {$option == 1} {
            errmsg $myid "ERROR:\nI cannot load the file. \"$fn\" is not a regular file."
         } elseif {$option == 2} {
            errmsg2 $myid "ERROR:\nI cannot load the file. \"$fn\" is not a regular file."
         }
         return
      }
      set f [open $fn r]
      set status 0
      set x ""
      while { [gets $f line] >= 0 } {
         switch -exact $status {
            "0" {
               if {![string compare $line "begin bwenc"]} {set status 1}
            }
            "1" {
               set status 2
               if {![string compare $line "0"]} {incr status 2}
            }
            "2" {
               if {![string compare $line "end bwenc"]} {
                  if {($option == 0) || ($option == 1)} { set myid [newRoman] }
                  set rwin ".roman$myid"
                  saveRomanConfirm $myid; if ($rdirtybit($myid)) { return }
                  $rwin.mainfr.editfr.textarea delete 1.0 end
                  $rwin.mainfr.editfr.textarea insert 1.0 $x
                  $rwin.mainfr.editfr.textarea see insert
                  set rdirtybit($myid) 1
                  set rfname($myid) ""
                  setbnstr $myid
                  set status 3
               } else {
                  set len [expr [string length $line] - 1]
                  for {set i 0} {$i < $len} {incr i 2} {
                     set x "$x[hextochar [string range $line $i [expr $i + 1]]]"
                  }
                  set x "$x\n"
               }
            }
            "3" { }
            "4" {
               if {![string compare $line "end bwenc"]} {
                  if {($option == 0) || ($option == 2)} { set myid [newMain] }
                  set mwin ".main$myid"
                  saveConfirm $myid; if ($dirtybit($myid)) { return }
                  $mwin.mainfr.editfr.textarea delete 1.0 end
                  if {($newTclTk)} {
                     $mwin.mainfr.editfr.textarea insert 1.0 [encfrom $x]
                  } else {
                     $mwin.mainfr.editfr.textarea insert 1.0 $x
                  }
                  $mwin.mainfr.editfr.textarea see insert
                  set dirtybit($myid) 1
                  set fname($myid) ""
                  set status 5
               } else {
                  set len [expr [string length $line] - 1]
                  for {set i 0} {$i < $len} {incr i 2} {
                     set x "$x[hextochar [string range $line $i [expr $i + 1]]]"
                  }
                  set x "$x\n"
               }
            }
            "5" {
               addTag $myid $line
            }
         }
      }
      if {$status >= 4} { $mwin.mainfr.editfr.textarea see insert }
   }
}

proc hextochar { hexval } {
   set hhex [string range $hexval 0 0]
   set lhex [string range $hexval 1 1]
   switch -exact $hhex {
      "A" { set hval 10 }
      "B" { set hval 11 }
      "C" { set hval 12 }
      "D" { set hval 13 }
      "E" { set hval 14 }
      "F" { set hval 15 }
      default { set hval $hhex }
   }
   switch -exact $lhex {
      "A" { set lval 10 }
      "B" { set lval 11 }
      "C" { set lval 12 }
      "D" { set lval 13 }
      "E" { set lval 14 }
      "F" { set lval 15 }
      default { set lval $lhex }
   }
   return [format "%c" [expr 16 * $hval + $lval]]
}

proc readMIME { option { myid 0 } { fn "" } } {
   global mimed dirtybit rdirtybit newTclTk

   if {$option == 1} {
      saveConfirm $myid
      if {$dirtybit($myid)} { return }
   } elseif {$option == 2} {
      saveRomanConfirm $myid
      if {$rdirtybit($myid)} { return }
   }

   if {![string compare $fn ""]} {
      set fn [getFileName "bwedit: read MIME encoded file"]
   }
   if {![string compare $fn ""]} { return }
   if {![file readable $fn]} {
      if {$option == 1} { errmsg $myid "ERROR:\nI cannot load the file \"$fn\". The file does not exist or does not have read permission." }
      elseif {$option == 2} { errmsg2 $myid "ERROR:\nI cannot load the file \"$fn\". The file does not exist or does not have read permission." }
      return
   }
   if {![file isfile $fn]} {
      if {$option == 1} { errmsg $myid "ERROR:\nI cannot load the file. \"$fn\" is not a regular file." }
      elseif {$option == 2} { errmsg2 $myid "ERROR:\nI cannot load the file. \"$fn\" is not a regular file." }
      return
   }

   if {$option == 0} {
      set myid [newMain]
      set twin ".main$myid"
      set dirtybit($myid) 1
   } elseif {$option == 1} {
      set twin ".main$myid"
      set dirtybit($myid) 1
      clearTextArea $myid
   } elseif {$option == 2} {
      set twin ".roman$myid"
      set rdirtybit($myid) 1
      rclearTextArea $myid
   } else { return }

   regsub -all "%f" $mimed $fn deccmd
   set x [eval exec $deccmd]
   if {($newTclTk) && ($option != 2)} {
      $twin.mainfr.editfr.textarea insert 1.0 [encfrom $x]
   } else {
      $twin.mainfr.editfr.textarea insert 1.0 $x
   }
   if {$option == 2} { setbnstr $myid }
   $twin.mainfr.editfr.textarea see insert
}

proc readUU { option { myid 0 } { fn "" } } {
   global uud dirtybit rdirtybit newTclTk

   if {$option == 1} {
      saveConfirm $myid
      if {$dirtybit($myid)} { return }
   } elseif {$option == 2} {
      saveRomanConfirm $myid
      if {$rdirtybit($myid)} { return }
   }

   if {![string compare $fn ""]} {
      set fn [getFileName "bwedit: read uuencoded file"]
   }
   if {![string compare $fn ""]} { return }
   if {![file readable $fn]} {
      if {$option == 1} { errmsg $myid "ERROR:\nI cannot load the file \"$fn\". The file does not exist or does not have read permission." }
      elseif {$option == 2} { errmsg2 $myid "ERROR:\nI cannot load the file \"$fn\". The file does not exist or does not have read permission." }
      return
   }
   if {![file isfile $fn]} {
      if {$option == 1} { errmsg $myid "ERROR:\nI cannot load the file. \"$fn\" is not a regular file." }
      elseif {$option == 2} { errmsg2 $myid "ERROR:\nI cannot load the file. \"$fn\" is not a regular file." }
      return
   }

   if {$option == 0} {
      set myid [newMain]
      set twin ".main$myid"
      set dirtybit($myid) 1
   } elseif {$option == 1} {
      set twin ".main$myid"
      set dirtybit($myid) 1
      clearTextArea $myid
   } elseif {$option == 2} {
      set twin ".roman$myid"
      set rdirtybit($myid) 1
      rclearTextArea $myid
   } else { return }

   regsub -all "%f" $uud $fn deccmd
   set x [eval exec $deccmd]
   if {($newTclTk) && ($option != 2)} {
      $twin.mainfr.editfr.textarea insert 1.0 [encfrom $x]
   } else {
      $twin.mainfr.editfr.textarea insert 1.0 $x
   }
   if {$option == 2} { setbnstr $myid }
   $twin.mainfr.editfr.textarea see insert
}

########################     End of mail.tcl    ##########################

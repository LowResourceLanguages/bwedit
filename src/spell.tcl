############################################################################
# spell.tcl: Implements the spell checking functions
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

proc rCheckSpell { myid } {
   global installdir

   set rwin ".roman$myid"
   $rwin.mainfr.editfr.textarea tag remove spe1 1.0 end
   $rwin.mainfr.editfr.textarea tag remove spe2 1.0 end
   $rwin.mainfr.editfr.textarea tag remove spe4 1.0 end
   set ipstr [$rwin.mainfr.editfr.textarea get 1.0 end]
   set splist [split [exec $installdir/bin/bwspell c2s $ipstr 2> /dev/null] "\n"]
   set splen [llength $splist]
   for {set i 0} {$i < $splen} {incr i 1} {
      set spinfo [split [lindex $splist $i] " "]
      if {[llength $spinfo] == 3} {
         set startidx [lindex $spinfo 0]
         set endidx [lindex $spinfo 1]
         set errtype [lindex $spinfo 2]
         if {$errtype == 1} {
            $rwin.mainfr.editfr.textarea tag add spe1 $startidx $endidx
         } elseif {$errtype == 2} {
            $rwin.mainfr.editfr.textarea tag add spe2 $startidx $endidx
         } elseif {$errtype == 4} {
            $rwin.mainfr.editfr.textarea tag add spe4 $startidx $endidx
         }
      }
   }
}

proc rClearSpell { myid } {
   set rwin ".roman$myid"
   $rwin.mainfr.editfr.textarea tag remove spe1 1.0 end
   $rwin.mainfr.editfr.textarea tag remove spe2 1.0 end
   $rwin.mainfr.editfr.textarea tag remove spe4 1.0 end
}

proc addwlbtn { fr txt lno } {
   global appbg appfg btnbg btnfg wlist newTclTk

   if ($newTclTk) {
      button $fr.$lno -text [encfrom $txt] -command "showList $lno" -relief flat \
         -bg $appbg -fg $appfg -activebackground $appbg -activeforeground #0000ff \
         -borderwidth 0 -padx 0 -pady 0 \
         -font "-*-bengali2-medium-r-*-*-*-120-*-*-*-*-iso10646-1"
   } else {
      button $fr.$lno -text $txt -command "showList $lno" -relief flat \
         -bg $appbg -fg $appfg -activebackground $appbg -activeforeground #0000ff \
         -borderwidth 0 -padx 0 -pady 0 \
         -font "-*-bengali-medium-r-*-*-*-120-*-*-*-*-*-fontspecific"
   }
   pack $fr.$lno -padx 0 -pady 0 -expand no -side top
}

proc viewWordList { } {
   global appbg appfg btnbg btnfg hdrfont textbg textfg newTclTk

   if {[winfo exists .wordlist]} {
      focus .wordlist
   } else {
      toplevel .wordlist
      .wordlist config -bg $appbg
      frame .wordlist.f1 -bg $appbg
      pack .wordlist.f1 -padx 5 -pady 5 -expand no -fill x -side top
      label .wordlist.f1.l -bg $appbg -fg $appfg -font $hdrfont -text "Bengali wordlist"
      pack .wordlist.f1.l -side left -padx 0 -pady 0
      label .wordlist.f1.logo  -image "bweditlogo" -relief flat -bg $appbg -fg $appfg -cursor hand2
      bind .wordlist.f1.logo <Button-1> { copyInfo }
      pack .wordlist.f1.logo -side right -padx 0 -pady 0

      frame .wordlist.f -bg $appbg
      pack .wordlist.f -padx 5 -pady 5 -expand yes -fill both -side top
      frame .wordlist.f.f -bg $appbg
      pack .wordlist.f.f -padx 0 -pady 0 -expand no -fill y -side left
      button .wordlist.f.f.done -text "Close" -command "destroy .wordlist" \
         -relief raised -bg $appbg -fg $appfg -activebackground $appbg \
         -activeforeground $appfg
      pack .wordlist.f.f.done -padx 0 -pady 0 -expand no -side bottom
      frame .wordlist.f.f.f -bg $appbg
      pack .wordlist.f.f.f -padx 0 -pady 5 -expand yes -fill y -side bottom

      frame .wordlist.f.f.f.f1 -bg $appbg
      pack .wordlist.f.f.f.f1 -padx 5 -pady 1 -expand yes -fill y -side left
      addwlbtn .wordlist.f.f.f.f1 "a" 1
      addwlbtn .wordlist.f.f.f.f1 "aA" 2
      addwlbtn .wordlist.f.f.f.f1 [format "%c" 1] 3
      addwlbtn .wordlist.f.f.f.f1 [format "%c" 2] 4
      addwlbtn .wordlist.f.f.f.f1 [format "%c" 3] 5
      addwlbtn .wordlist.f.f.f.f1 [format "%c" 4] 6
      addwlbtn .wordlist.f.f.f.f1 [format "%c" 5] 7
      addwlbtn .wordlist.f.f.f.f1 [format "%c" 6] 8
      addwlbtn .wordlist.f.f.f.f1 [format "%c" 7] 9
      addwlbtn .wordlist.f.f.f.f1 [format "%c" 8] 10
      addwlbtn .wordlist.f.f.f.f1 "o" 11

      frame .wordlist.f.f.f.f2 -bg $appbg
      pack .wordlist.f.f.f.f2 -padx 5 -pady 1 -expand yes -fill y -side left
      addwlbtn .wordlist.f.f.f.f2 "k" 12
      addwlbtn .wordlist.f.f.f.f2 "K" 13
      addwlbtn .wordlist.f.f.f.f2 "g" 14
      addwlbtn .wordlist.f.f.f.f2 "G" 15
      addwlbtn .wordlist.f.f.f.f2 "c" 16
      addwlbtn .wordlist.f.f.f.f2 "C" 17
      addwlbtn .wordlist.f.f.f.f2 "j" 18
      addwlbtn .wordlist.f.f.f.f2 "J" 19
      addwlbtn .wordlist.f.f.f.f2 "T" 20
      addwlbtn .wordlist.f.f.f.f2 "Z" 21
      addwlbtn .wordlist.f.f.f.f2 "D" 22
      addwlbtn .wordlist.f.f.f.f2 "X" 23
      addwlbtn .wordlist.f.f.f.f2 "N" 24
      addwlbtn .wordlist.f.f.f.f2 "t" 25
      addwlbtn .wordlist.f.f.f.f2 "z" 26
      addwlbtn .wordlist.f.f.f.f2 "d" 27
      addwlbtn .wordlist.f.f.f.f2 "x" 28
      addwlbtn .wordlist.f.f.f.f2 "n" 29
      addwlbtn .wordlist.f.f.f.f2 "p" 30
      addwlbtn .wordlist.f.f.f.f2 "f" 31
      addwlbtn .wordlist.f.f.f.f2 "b" 32
      addwlbtn .wordlist.f.f.f.f2 "v" 33
      addwlbtn .wordlist.f.f.f.f2 "m" 34
      addwlbtn .wordlist.f.f.f.f2 "Y" 35
      addwlbtn .wordlist.f.f.f.f2 "r" 36
      addwlbtn .wordlist.f.f.f.f2 "l" 37
      addwlbtn .wordlist.f.f.f.f2 "S" 38
      addwlbtn .wordlist.f.f.f.f2 "F" 39
      addwlbtn .wordlist.f.f.f.f2 "s" 40
      addwlbtn .wordlist.f.f.f.f2 "h" 41

      if ($newTclTk) {
         text .wordlist.f.t -relief flat -height 16 -width 32 -spacing3 5 \
            -font "-*-bengali2-medium-r-*-*-*-120-*-*-*-*-iso10646-1" \
            -yscroll ".wordlist.f.s set" -bg $textbg -fg $textfg -wrap none \
            -borderwidth 0 -selectbackground $textbg -selectforeground $textfg \
            -selectborderwidth 0 -state disabled
      } else {
         text .wordlist.f.t -relief flat -height 16 -width 32 -spacing3 5 \
            -font "-*-bengali-medium-r-*-*-*-120-*-*-*-*-*-fontspecific" \
            -yscroll ".wordlist.f.s set" -bg $textbg -fg $textfg -wrap none \
            -borderwidth 0 -selectbackground $textbg -selectforeground $textfg \
            -selectborderwidth 0 -state disabled
      }
      scrollbar .wordlist.f.s -relief sunken -orient vertical \
      -command ".wordlist.f.t yview" -bg $appbg -width 12 \
      -activebackground $appbg
      pack .wordlist.f.s -side right -padx 0 -pady 0 -expand no -fill y
      pack .wordlist.f.t -side right -padx 0 -pady 0 -expand yes -fill both

      bind .wordlist <Escape> {.wordlist.f.f.done invoke; break}
      readDict
   }
}

proc readDict { } {
   global wlist installdir wlconv

   if {![info exists wlist]} {
      set wlist [split [exec $installdir/bin/bwspell s 2>/dev/null] "%"]
      for {set i 1} {$i <= 41} {incr i} {set wlconv($i) 0}
   }
}

proc showList {lno} {
   global wlist newTclTk wlconv

   if {($lno > 0) && ($lno <= 41)} {
      .wordlist.f.t config -state normal
      .wordlist.f.t delete 1.0 end
      if {(!$wlconv($lno))} {
         set thislist [lindex $wlist $lno]
         set thislist [string range $thislist 1 [expr [string length $thislist] - 2]]
         if ($newTclTk) { set thislist [encfrom $thislist] }
         set wlist [lreplace $wlist $lno $lno $thislist]
         set wlconv($lno) 1
      }
      .wordlist.f.t insert end [lindex $wlist $lno]
      .wordlist.f.t config -state disabled
   }
}

########################     End of spell.tcl    ##########################

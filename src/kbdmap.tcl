############################################################################
# kbdmap.tcl: Implements the Keyboard map window
# Author: Abhijit Das (Barda) [ad_rab@yahoo.com]
# Last updated: July 04 2002
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

proc putChar { i j bch btxt flag } {
   global targetWin dirtybit rdirtybit invencmap newTclTk

   if {($targetWin > 0)} {
      if [ winfo exists .main$targetWin ] {
         if ($newTclTk) {
            .main$targetWin.mainfr.editfr.textarea insert insert [encfrom $btxt]
         } else {
            .main$targetWin.mainfr.editfr.textarea insert insert $btxt
         }
         incr dirtybit($targetWin) 1
      }
   } else {
      set twin [expr -$targetWin]
      if [ winfo exists .roman$twin ] {
         if {$flag} {
            switch -exact [string trim $bch] {
               "aA" { .roman$twin.mainfr.editfr.textarea insert insert "A" }
               "o" { .roman$twin.mainfr.editfr.textarea insert insert "ou" }
               "w" { .roman$twin.mainfr.editfr.textarea insert insert "^" }
               "^" { .roman$twin.mainfr.editfr.textarea insert insert "^r" }
               "_" { .roman$twin.mainfr.editfr.textarea insert insert "__" }
               default {
                  scan $bch "%c" asciival
                  if {$asciival == 15} {
                     .roman$twin.mainfr.editfr.textarea insert insert "^r"
                  } elseif {[info exists invencmap($asciival)]} {
                     .roman$twin.mainfr.editfr.textarea insert insert $invencmap($asciival)
                  } else {
                     .roman$twin.mainfr.editfr.textarea insert insert $bch
                  }
               }
            }
         } else {
            switch -exact $bch {
                 1 { .roman$twin.mainfr.editfr.textarea insert insert "i" }
                 2 { .roman$twin.mainfr.editfr.textarea insert insert "I" }
                 3 { .roman$twin.mainfr.editfr.textarea insert insert "u" }
                 4 { .roman$twin.mainfr.editfr.textarea insert insert "U" }
                 5 { .roman$twin.mainfr.editfr.textarea insert insert "R" }
                 6 { .roman$twin.mainfr.editfr.textarea insert insert "e" }
                 7 { .roman$twin.mainfr.editfr.textarea insert insert "oi" }
                 8 { .roman$twin.mainfr.editfr.textarea insert insert "o" }
                14 { .roman$twin.mainfr.editfr.textarea insert insert "^y" }
               105 { .roman$twin.mainfr.editfr.textarea insert insert "i" }
                73 { .roman$twin.mainfr.editfr.textarea insert insert "I" }
               117 { .roman$twin.mainfr.editfr.textarea insert insert "u" }
                85 { .roman$twin.mainfr.editfr.textarea insert insert "U" }
                87 { .roman$twin.mainfr.editfr.textarea insert insert "R" }
               101 { .roman$twin.mainfr.editfr.textarea insert insert "e" }
                69 { .roman$twin.mainfr.editfr.textarea insert insert "oi" }
               111 { .roman$twin.mainfr.editfr.textarea insert insert "o" }
               179 { .roman$twin.mainfr.editfr.textarea insert insert "^^tr" }
               193 { .roman$twin.mainfr.editfr.textarea insert insert "^^nt" }
               227 { .roman$twin.mainfr.editfr.textarea insert insert "^^lg" }
               254 { .roman$twin.mainfr.editfr.textarea insert insert "^^st" }
               default {
                  if {[info exists invencmap($bch)]} {
                     .roman$twin.mainfr.editfr.textarea insert insert $invencmap($bch)
                  } else {
                     .roman$twin.mainfr.editfr.textarea insert insert $bch
                  }
               }
            }
         }
         incr rdirtybit($twin) 1
         setbnstr $twin
      }
   }
}

proc setKbdText { i j bch etxt {flag 0} } {
   global appbg appfg dpyfont btnbg btnfg targetWin dirtybit newTclTk

   set kwin .kbdmap
   frame $kwin.row$i.$j -relief raised -borderwidth 1 -bg $appbg -cursor hand2
   pack $kwin.row$i.$j -side left -expand no -padx 0 -pady 0 -expand yes -fill x
   if {$flag} {
      set btxt $bch
   } else {
      set btxt [format "%c" $bch]
   }
   if ($newTclTk) {
      label $kwin.row$i.$j.b -text [encfrom $btxt] -bg $appbg -fg #880088 -relief flat \
         -font "-*-bengali2-medium-r-*-*-*-120-*-*-*-*-iso10646-1"
   } else {
      label $kwin.row$i.$j.b -text $btxt -bg $appbg -fg #880088 -relief flat \
         -font "-*-bengali-medium-r-*-*-*-120-*-*-*-*-*-fontspecific"
   }
   label $kwin.row$i.$j.e -text $etxt -bg $appbg -fg $appfg -relief flat -font $dpyfont
   pack $kwin.row$i.$j.b $kwin.row$i.$j.e -padx 0 -pady 0 -side left -expand yes -fill x

   bind $kwin.row$i.$j <Enter> "
      $kwin.row$i.$j.b config -fg #0000ff
      $kwin.row$i.$j.e config -fg #0000ff
   "
   bind $kwin.row$i.$j <Leave> "
      $kwin.row$i.$j.b config -fg #880088
      $kwin.row$i.$j.e config -fg $appfg
   "
   bind $kwin.row$i.$j <ButtonPress-1> "putChar $i $j $bch $btxt $flag"
   bind $kwin.row$i.$j.b <ButtonPress-1> "putChar $i $j $bch $btxt $flag"
   bind $kwin.row$i.$j.e <ButtonPress-1> "putChar $i $j $bch $btxt $flag"
}

proc setKbdText2 { i j txt1 txt2 } {
   global appbg appfg dpyfont btnbg btnfg targetWin dirtybit newTclTk

   set kwin .kbdmap
   frame $kwin.row$i.$j -relief raised -borderwidth 1 -bg $appbg -cursor hand2
   pack $kwin.row$i.$j -side left -expand no -padx 0 -pady 0 -expand yes -fill x
   if ($newTclTk) {
      label $kwin.row$i.$j.b -text [encfrom $txt1] -bg $appbg -fg #880088 -relief flat \
         -font "-*-bengali2-medium-r-*-*-*-120-*-*-*-*-iso10646-1"
   } else {
      label $kwin.row$i.$j.b -text $txt1 -bg $appbg -fg #880088 -relief flat \
         -font "-*-bengali-medium-r-*-*-*-120-*-*-*-*-*-fontspecific"
   }
   label $kwin.row$i.$j.e -text $txt1 -bg $appbg -fg $appfg -relief flat -font $dpyfont
   pack $kwin.row$i.$j.b $kwin.row$i.$j.e -padx 0 -pady 0 -side left -expand yes -fill x

   bind $kwin.row$i.$j <Enter> "
      $kwin.row$i.$j.b config -fg #0000ff
      $kwin.row$i.$j.e config -fg #0000ff
   "
   bind $kwin.row$i.$j <Leave> "
      $kwin.row$i.$j.b config -fg #880088
      $kwin.row$i.$j.e config -fg $appfg
   "
   bind $kwin.row$i.$j <ButtonPress-1> "putChar $i $j $txt2 $txt2 1"
   bind $kwin.row$i.$j.b <ButtonPress-1> "putChar $i $j $txt2 $txt2 1"
   bind $kwin.row$i.$j.e <ButtonPress-1> "putChar $i $j $txt2 $txt2 1"
}

proc setBindText { i j txt1 txt2 } {
   global appbg appfg dpyfont

   set kwin .kbdmap
   frame $kwin.row$i.$j -relief raised -borderwidth 1 -bg $appbg
   pack $kwin.row$i.$j -side left -expand no -padx 0 -pady 0 -expand yes -fill x
   label $kwin.row$i.$j.l1 -text $txt1 -bg $appbg -fg #660000 -relief flat -font $dpyfont
   label $kwin.row$i.$j.l2 -text $txt2 -bg $appbg -fg $appfg -relief flat -font $dpyfont
   pack $kwin.row$i.$j.l1 $kwin.row$i.$j.l2 -padx 0 -pady 0 -side left -expand yes -fill x -expand yes -fill x
}

proc setEnglishText { i j txt } {
   global appbg appfg btnbg dirtybit

   set kwin .kbdmap
   label $kwin.row$i.$j -relief raised -borderwidth 1 -bg $appbg -fg $appfg -text $txt -cursor hand1
   pack $kwin.row$i.$j -side left -expand no -padx 0 -pady 0 -expand yes -fill x
   bind $kwin.row$i.$j <Enter> "$kwin.row$i.$j config -fg #0000ff"
   bind $kwin.row$i.$j <Leave> "$kwin.row$i.$j config -fg $appfg"
   bind $kwin.row$i.$j <ButtonPress-1> "[list eval if \{ (\$targetWin > 0) && \[ winfo exists .main\$targetWin \] \} \{ .main\$targetWin.mainfr.editfr.textarea insert insert $txt english \; incr dirtybit(\$targetWin) 1 \} ]"
}

proc setEnglishText2 { i j txt1 txt2 } {
   global appbg appfg btnbg

   set kwin .kbdmap
   label $kwin.row$i.$j -relief raised -borderwidth 1 -bg $appbg -fg $appfg -text $txt1 -cursor hand1
   pack $kwin.row$i.$j -side left -expand no -padx 0 -pady 0 -expand yes -fill x
   bind $kwin.row$i.$j <Enter> "$kwin.row$i.$j config -fg #0000ff"
   bind $kwin.row$i.$j <Leave> "$kwin.row$i.$j config -fg $appfg"
   bind $kwin.row$i.$j <ButtonPress-1> "[list eval if \{ (\$targetWin > 0) && \[ winfo exists .main\$targetWin \] \} \{ .main\$targetWin.mainfr.editfr.textarea insert insert $txt2 english \; incr dirtybit(\$targetWin) 1 \} ]"
}

proc postTargetList { } {
   set posx [winfo x .kbdmap]
   incr posx [winfo x .kbdmap.row0]
   incr posx [winfo x .kbdmap.row0.target]
   set posy [winfo y .kbdmap]
   incr posy [winfo y .kbdmap.row0]
   incr posy [winfo y .kbdmap.row0.target]
   incr posy [winfo height .kbdmap.row0.target]
   .kbdmap.row0.target.m post $posx $posy
   .kbdmap.row0.target.m activate 0
   grab set -global .kbdmap.row0.target.m
   focus .kbdmap.row0.target.m
}

proc viewKbdMap {} {
   global appbg appfg dpyfont hdrfont targetWin

   if {[winfo exists .kbdmap]} { focus .kbdmap ; return }
   set mapwin [toplevel .kbdmap]

   for {set i 0} {$i <= 23} {incr i 1} {
      frame $mapwin.row$i -bg $appbg
      pack $mapwin.row$i -padx 3 -pady 0 -expand yes -fill x
   }

   label $mapwin.row0.hdr -text "bwedit : Keyboard map" -font $hdrfont \
      -relief flat -bg $appbg -fg #006600
   label $mapwin.row0.spc -text "" -relief flat -bg $appbg -fg #006600
   menubutton $mapwin.row0.target -text " Target window : (None) " -height 1 \
      -relief raised -menu $mapwin.row0.target.m -bg $appbg -fg $appfg \
      -activeforeground $appfg -activebackground $appbg \
      -highlightthickness 0 -underline 1
   menu $mapwin.row0.target.m -tearoff false -bg $appbg -fg $appfg
   updateWinMenu
   bind $mapwin <Alt-t> "postTargetList"
   bind $mapwin <Alt-T> "postTargetList"
   set targetWin 0
   button $mapwin.row0.done -text "Close window" -command "destroy $mapwin" \
      -bg $appbg -fg $appfg -activebackground $appbg -activeforeground $appfg \
      -underline 0
   bind $mapwin <Alt-c> "$mapwin.row0.done invoke; break"
   bind $mapwin <Alt-C> "$mapwin.row0.done invoke; break"

   pack $mapwin.row0.hdr -expand no -padx 0 -pady 5 -side left
   pack $mapwin.row0.spc -expand yes -fill x -padx 0 -pady 5 -side left
   pack $mapwin.row0.target -expand no -padx 0 -pady 5 -side left
   pack $mapwin.row0.done -expand no -padx 0 -pady 5 -side left

   setKbdText 1 1 "a" "a" 1
   setKbdText 1 2 "aA" "^A" 1
   setKbdText 1 3 1 "^i"
   setKbdText 1 4 2 "^I"
   setKbdText 1 5 3 "^u"
   setKbdText 1 6 4 "^U"
   setKbdText 1 7 5 "^R"
   setKbdText 1 8 6 "^e"
   setKbdText 1 9 7 "^E"
   setKbdText 1 10 8 "^o"
   setKbdText 1 11 "o" "o" 1
   setKbdText 1 12 "A" "A" 1
   setKbdText 1 13 "i " "i" 1
   setKbdText 1 14 " I" "I" 1
   setKbdText 1 15 " u" "u" 1
   setKbdText 1 16 " U" "U" 1
   setKbdText 1 17 " W" "W" 1
   setKbdText 1 18 "e" "e" 1
   setKbdText 1 19 "E" "E" 1
   setKbdText 1 20 " O" "O" 1

   setKbdText 2 1 "k" "k" 1
   setKbdText 2 2 "K" "K" 1
   setKbdText 2 3 "g" "g" 1
   setKbdText 2 4 "G" "G" 1
   setKbdText 2 5 "q" "q" 1
   setKbdText 2 6 "c" "c" 1
   setKbdText 2 7 "C" "C" 1
   setKbdText 2 8 "j" "j" 1
   setKbdText 2 9 "J" "J" 1
   setKbdText 2 10 "Q" "Q" 1
   setKbdText 2 11 "T" "T" 1
   setKbdText 2 12 "Z" "Z" 1
   setKbdText 2 13 "D" "D" 1
   setKbdText 2 14 "X" "X" 1
   setKbdText 2 15 "N" "N" 1
   setKbdText 2 16 "t" "t" 1
   setKbdText 2 17 "z" "z" 1
   setKbdText 2 18 "d" "d" 1
   setKbdText 2 19 "x" "x" 1
   setKbdText 2 20 "n" "n" 1

   setKbdText 3 1 "p" "p" 1
   setKbdText 3 2 "f" "f" 1
   setKbdText 3 3 "b" "b" 1
   setKbdText 3 4 "v" "v" 1
   setKbdText 3 5 "m" "m" 1
   setKbdText 3 6 "Y" "Y" 1
   setKbdText 3 7 "r" "r" 1
   setKbdText 3 8 "l" "l" 1
   setKbdText 3 9 "b" "b" 1
   setKbdText 3 10 "S" "S" 1
   setKbdText 3 11 "F" "F" 1
   setKbdText 3 12 "s" "s" 1
   setKbdText 3 13 "h" "h" 1
   setKbdText 3 14 "R" "R" 1
   setKbdText 3 15 "V" "V" 1
   setKbdText 3 16 "y" "y" 1
   setKbdText 3 17 "B" "B" 1
   setKbdText 3 18 "M" "M" 1
   setKbdText 3 19 "H" "H" 1
   setKbdText 3 20 " w" "w" 1

   setKbdText 4 1 25 "\[25\]"
   setKbdText 4 2 26 "\[26\]"
   setKbdText 4 3 27 "\[27\]"
   setKbdText 4 4 28 "\[28\]"
   setKbdText 4 5 29 "\[29\]"
   setKbdText 4 6 30 "\[30\]"
   for {set i 0} {$i < 10} {incr i 1} {
      setKbdText 4 [expr $i + 7] $i $i 1
   }

   for {set i 1} {$i <= 13} {incr i 1} {
      setKbdText 5 $i [expr $i + 127] "\[[expr $i + 127]\]"
   }

   for {set i 1} {$i <= 13} {incr i 1} {
      setKbdText 6 $i [expr $i + 140] "\[[expr $i + 140]\]"
   }

   for {set i 1} {$i <= 6} {incr i 1} {
      setKbdText 7 $i [expr $i + 153] "\[[expr $i + 153]\]"
   }
   setKbdText 7 7 80 "P"
   for {set i 8} {$i <= 13} {incr i 1} {
      setKbdText 7 $i [expr $i + 153] "\[[expr $i + 153]\]"
   }
   for {set i 1} {$i <= 13} {incr i 1} {
      setKbdText 8 $i [expr $i + 166] "\[[expr $i + 166]\]"
   }

   setKbdText 9 1 38 "&"
   for {set i 2} {$i <= 13} {incr i 1} {
      setKbdText 9 $i [expr $i + 178] "\[[expr $i + 178]\]"
   }

   for {set i 1} {$i <= 6} {incr i 1} {
      setKbdText 10 $i [expr $i + 191] "\[[expr $i + 191]\]"
   }
   setKbdText 10 7 64 "@"
   for {set i 8} {$i <= 13} {incr i 1} {
      setKbdText 10 $i [expr $i + 190] "\[[expr $i + 190]\]"
   }

   for {set i 1} {$i <= 13} {incr i 1} {
      setKbdText 11 $i [expr $i + 203] "\[[expr $i + 203]\]"
   }

   for {set i 1} {$i <= 13} {incr i 1} {
      setKbdText 12 $i [expr $i + 216] "\[[expr $i + 216]\]"
   }

   for {set i 1} {$i <= 13} {incr i 1} {
      setKbdText 13 $i [expr $i + 229] "\[[expr $i + 229]\]"
   }

   for {set i 1} {$i <= 13} {incr i 1} {
      setKbdText 14 $i [expr $i + 242] "\[[expr $i + 242]\]"
   }

   for {set i 1} {$i <= 9} {incr i 1} {
      setKbdText 15 $i [expr $i + 15] "\[[expr $i + 15]\]"
   }
   setKbdText 15 10 31 "\[31\]"
   setKbdText 15 11 62 ">"
   setKbdText 15 12 76 "L"
   setKbdText 15 13 125 "\}"
   setKbdText 15 14 14 "^y"
   set btxt " [format "%c" 15]"
   setKbdText 15 15 $btxt "^r" 1
   setKbdText 15 16 "^ " "^" 1
   setKbdText 15 17 "_ " "_" 1

   setKbdText2 16 1 "." "."
   setKbdText2 16 2 "<" "<"
   setKbdText2 16 3 "," ","
   setKbdText2 16 4 ";" "\\;"
   setKbdText2 16 5 ":" ":"
   setKbdText2 16 6 "?" "?"
   setKbdText2 16 7 "!" "!"
   setKbdText2 16 8 "/" "/"
   setKbdText2 16 9 "%" "%%"
   setKbdText2 16 10 "~" "~"
   setKbdText2 16 11 "`" "`"
   setKbdText2 16 12 "'" "'"
   setKbdText2 16 13 "\\" "\\\\"
   setKbdText2 16 14 "\"" "\\\""
   setKbdText2 16 15 "#" "#"
   setKbdText2 16 16 "$" "$"
   setKbdText2 16 17 "+" "+"
   setKbdText2 16 18 "-" "-"
   setKbdText2 16 19 "*" "*"
   setKbdText2 16 20 "=" "="
   setKbdText2 16 21 "\{" "\\\{"
   setKbdText2 16 22 "|" "|"
   setKbdText2 16 23 "(" "("
   setKbdText2 16 24 ")" ")"
   setKbdText2 16 25 "\[" "\\\["
   setKbdText2 16 26 "\]" "\\\]"

   for {set i 1} {$i <= 26} {incr i 1} {
      setEnglishText 17 $i [format "%c" [expr $i + 64]]
      setEnglishText 18 $i [format "%c" [expr $i + 96]]
   }

   setEnglishText 19 1 "."
   setEnglishText 19 2 "$"
   setEnglishText2 19 3 "\{" "\\\{"
   setEnglishText2 19 4 "\}" "\\\}"
   setEnglishText 19 5 "<"
   setEnglishText 19 6 ">"
   setEnglishText2 19 7 "\\" "\\\\"
   setEnglishText 19 8 "@"
   setEnglishText 19 9 "&"
   setEnglishText 19 10 "^"
   setEnglishText 19 11 "_"
   setEnglishText 19 12 "0"
   setEnglishText 19 13 "1"
   setEnglishText 19 14 "2"
   setEnglishText 19 15 "3"
   setEnglishText 19 16 "4"
   setEnglishText 19 17 "5"
   setEnglishText 19 18 "6"
   setEnglishText 19 19 "7"
   setEnglishText 19 20 "8"
   setEnglishText 19 21 "9"

   setBindText 20 1 "^DEL" "Delete from cursor to end of word"
   setBindText 20 2 "^BS" "Delete from start of word to cursor"
   setBindText 20 3 "^w" "Delete word"
   setBindText 20 4 "^j" "Join two words"

   setBindText 21 1 "^(DEL)" "Delete from cursor to end of line"
   setBindText 21 2 "^(BS)" "Delete from start of line to cursor"
   setBindText 21 3 "^L" "Delete line"
   setBindText 21 4 "^J" "Join two lines"

   setBindText 22 1 "F1" "Help"
   setBindText 22 2 "F2" "Load"
   setBindText 22 3 "F3" "Save"
   setBindText 22 4 "F4" "Cut"
   setBindText 22 5 "F5" "Copy"
   setBindText 22 6 "F6" "Paste"
   setBindText 22 7 "F7" "Start marking"
   setBindText 22 8 "F8" "End marking"
   setBindText 22 9 "F9" "Send mail"
   setBindText 22 10 "F10" "Menu"

   label $mapwin.row23.legend -relief flat -bg $appbg -fg #000088 \
      -text "Notations : ^ = CONTROL, \[<num>\] = ESCAPE<num>ESCAPE, DEL = DELETE, BS = BACKSPACE, (<key>) = SHIFT<key>"
   pack $mapwin.row23.legend -padx 0 -pady 5

   $mapwin config -bg $appbg
   bind $mapwin <Escape> "destroy $mapwin"

   wm title $mapwin "bwedit: character map"
   wm resizable $mapwin false false
}

########################     End of kbdmap.tcl    ##########################

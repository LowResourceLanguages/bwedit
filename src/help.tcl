############################################################################
# help.tcl: Implements the help routines
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

set cwinid -1
proc copyInfo {} {
   global bweditlogo installdir appbg appfg btnbg btnfg cwinid

   if {[winfo exists $cwinid]} {destroy $cwinid; set cwinid -1; return}
   set cwin [toplevel .copyright]
   set cwinid $cwin
   label $cwin.hdr -relief flat -fg $appfg -bg $appbg -image "bweditlogo" -cursor hand2
   bind $cwin.hdr <Button-1> { copyInfo }
   label $cwin.ver -relief ridge -fg #000000 -bg #ddddaa \
      -text " Version 3.0, July 2002 "
   message $cwin.cpy -relief ridge -fg #000000 -bg #ddddaa -width 800 -text \
"Copyright (C) 1998-2002 by Abhijit Das \[ad_rab@yahoo.com\]

BWEDIT is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

BWEDIT is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with BWEDIT; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA"

   label $cwin.aut -relief ridge -fg #000000 -bg #ddddaa -text " Author: "
   message $cwin.add -relief ridge -fg #000000 -bg #ddddaa -width 500 -text \
"Dr. Abhijit Das (Barda)
Department of Mathematics
Indian Institute of Technology
Kanpur 208 016 UP
INDIA

E-mail: ad_rab@yahoo.com"

   button $cwin.btn -fg $btnfg -bg "$btnbg" -text " Dismiss " \
      -command "destroy $cwin" -activeforeground $btnfg -activebackground $btnbg

   pack $cwin.hdr -padx 0 -pady 5
   pack $cwin.ver -padx 0 -pady 5
   pack $cwin.cpy -padx 5 -pady 5
   pack $cwin.aut -padx 0 -pady 5
   pack $cwin.add -padx 0 -pady 5
   pack $cwin.btn -padx 0 -pady 5
   $cwin config -bg $appbg
   bind $cwin <Escape> "destroy $cwin"

   wm title $cwin "bwedit: copyright notice"
   wm resizable $cwin false false
   wm iconname $cwin "bwedit: copyright notice"
   wm iconbitmap $cwin @$installdir/images/bwedit-logo.xbm
}

proc adddoc { twin fn } {
   global installdir newTclTk

   $twin config -state normal
   if ($newTclTk) {
      $twin tag configure bntag -font "-*-bengali2-medium-r-*-*-*-120-*-*-*-*-iso10646-1"
   } else {
      $twin tag configure bntag -font "-*-bengali-medium-r-*-*-*-120-*-*-*-*-*-fontspecific"
   }
   set bngmode 0
   $twin delete 1.0 end
   if {![file readable "$installdir/help/$fn.hlp"]} {
      $twin insert end "ERROR:\nI am unable to read the help file\n$installdir/help/$fn.hlp\n"
   } else {
      set bngmode 0
      set f [open "$installdir/help/$fn.hlp" r]
      while {![eof $f]} {
         set nextchar [read $f 1]
         if {$bngmode == 0} {
            if {![string compare "#" $nextchar]} {
               set bngmode 1
               set bnstr ""
            } else { $twin insert end $nextchar }
         } else {
            if {![string compare "#" $nextchar]} {
               if {[string length $bnstr] > 0} {
                  if {![string compare [string index $bnstr 0] "\\"]} {
                        $twin insert end [encfrom [format "%c" [string range $bnstr 1 [expr [string length $bnstr] - 1]]]] bntag
                     if ($newTclTk) {
                     } else {
                        $twin insert end [format "%c" [string range $bnstr 1 [expr [string length $bnstr] - 1]]] bntag
                     }
                  } else {
                     if ($newTclTk) {
                        $twin insert end [encfrom $bnstr] bntag
                     } else {
                        $twin insert end $bnstr bntag
                     }
                  }
               }
               set bngmode 0
            } else { set bnstr "$bnstr$nextchar" }
         }
      }
   }
   $twin config -state disabled
}

set htnr 0

proc addHelpBtn1 { expflag txt hfile } {
   global appbg appfg dpyfont dpyfont htnr hstnr

   incr htnr

   set win .help.ctfr.tfr.$htnr
   set swin .help.ctfr.tfr.sm$htnr

   frame $win -bg $appbg -relief flat
   pack $win -expand no -fill x -side top -fill x -padx 0 -pady 3

   label $win.b1 -width 2 -text " $expflag" -relief flat \
      -fg $appfg -bg $appbg -font $dpyfont -borderwidth 0 -anchor e
   if {[string compare $expflag " "] != 0} {
      set hstnr 0
      $win.b1 config -cursor hand2
      frame $swin -bg $appbg -relief flat
      pack $swin -side top -expand no -fill x -padx 0 -pady 0
      frame $swin.blank -bg $appbg -width 0 -height 0 -relief flat
      pack $swin.blank -expand no -fill x

      bind $win.b1 <Enter> "$win.b1 config -fg #0000ff"
      bind $win.b1 <Leave> "$win.b1 config -fg $appfg"
      bind $win.b1 <Button-1> "toggleHelpMenu1 $htnr"
   }

   label $win.b2 -text $txt -fg $appfg -bg $appbg \
      -font $dpyfont -relief flat -borderwidth 0  -cursor hand2
   bind $win.b2 <Enter> "$win.b2 config -fg #0000ff"
   bind $win.b2 <Leave> "$win.b2 config -fg $appfg"
   bind $win.b2 <Button-1> "adddoc .help.dpyfr.textarea $hfile"

   pack $win.b1 -side left -padx 0 -pady 0 -expand no
   pack $win.b2 -side left -padx 5 -pady 0 -expand no -fill x
}

proc addHelpBtn2 { expflag txt hfile } {
   global appbg appfg dpyfont dpyfont htnr hstnr hsstnr

   incr hstnr
   set win .help.ctfr.tfr.sm$htnr.$hstnr
   set swin .help.ctfr.tfr.sm$htnr.ssm$hstnr

   frame $win -bg $appbg -relief flat

   label $win.b0 -width 2 -text "  " -relief flat \
      -fg $appfg -bg $appbg -font $dpyfont -borderwidth 0 -anchor e

   label $win.b1 -width 2 -text " $expflag" -relief flat \
      -fg $appfg -bg $appbg -font $dpyfont -borderwidth 0 -anchor e

   if {[string compare $expflag " "] != 0} {
      set hsstnr 0
      $win.b1 config -cursor hand2

      frame $swin -bg $appbg -relief flat
      frame $swin.blank -bg $appbg -width 0 -height 0 -relief flat
      pack $swin.blank -expand no -fill x

      bind $win.b1 <Enter> "$win.b1 config -fg #0000ff"
      bind $win.b1 <Leave> "$win.b1 config -fg $appfg"
      bind $win.b1 <Button-1> "toggleHelpMenu2 $htnr $hstnr"
   }

   label $win.b2 -text $txt -fg $appfg -bg $appbg \
      -font $dpyfont -relief flat -borderwidth 0  -cursor hand2
   bind $win.b2 <Enter> "$win.b2 config -fg #0000ff"
   bind $win.b2 <Leave> "$win.b2 config -fg $appfg"
   bind $win.b2 <Button-1> "adddoc .help.dpyfr.textarea $hfile"

   pack $win.b0 -side left -padx 0 -pady 0 -expand no
   pack $win.b1 -side left -padx 0 -pady 0 -expand no
   pack $win.b2 -side left -padx 5 -pady 0 -expand no -fill x
}

proc addHelpBtn3 { txt hfile } {
   global appbg appfg dpyfont dpyfont htnr hstnr hsstnr

   incr hsstnr
   set win .help.ctfr.tfr.sm$htnr.ssm$hstnr.$hsstnr

   frame $win -bg $appbg -relief flat

   label $win.b0 -width 2 -text "  " -fg $appfg -bg $appbg \
      -font $dpyfont -borderwidth 0 -anchor e
   label $win.b1 -width 2 -text "  " -fg $appfg -bg $appbg \
      -font $dpyfont -borderwidth 0 -anchor e
   label $win.b2 -text "     $txt" -fg $appfg -bg $appbg \
      -font $dpyfont -relief flat -borderwidth 0  -cursor hand2
   bind $win.b2 <Enter> "$win.b2 config -fg #0000ff"
   bind $win.b2 <Leave> "$win.b2 config -fg $appfg"
   bind $win.b2 <Button-1> "adddoc .help.dpyfr.textarea $hfile"

   pack $win.b0 -side left -padx 0 -pady 0 -expand no
   pack $win.b1 -side left -padx 0 -pady 0 -expand no
   pack $win.b2 -side left -padx 5 -pady 0 -expand no -fill x
}

proc toggleHelpMenu1 { itemnr } {
   set win .help.ctfr.tfr.$itemnr
   set swin .help.ctfr.tfr.sm$itemnr
   if {![string compare [$win.b1 cget -text] " +"]} {
      for {set i 1} {[winfo exists $swin.$i]} {incr i} {
         pack $swin.$i -expand no -fill x -side top -fill x -padx 0 -pady 1
         if {[winfo exists $swin.ssm$i]} {
            pack $swin.ssm$i -expand no -fill x -side top -fill x -padx 0 -pady 0
         }
      }
      $win.b1 config -text " -"
   } elseif {![string compare [$win.b1 cget -text] " -"]} {
      for {set i 1} {[winfo exists $swin.$i]} {incr i} {
         pack forget $swin.$i
         if {[winfo exists $swin.ssm$i]} {
            pack forget $swin.ssm$i
         }
      }
      $win.b1 config -text " +"
   }
}

proc toggleHelpMenu2 { htnr hstnr } {
   set win .help.ctfr.tfr.sm$htnr.$hstnr
   set swin .help.ctfr.tfr.sm$htnr.ssm$hstnr
   if {![string compare [$win.b1 cget -text] " +"]} {
      for {set i 1} {[winfo exists $swin.$i]} {incr i} {
         pack $swin.$i -expand no -fill x -side top -fill x -padx 0 -pady 1
      }
      $win.b1 config -text " -"
   } elseif {![string compare [$win.b1 cget -text] " -"]} {
      for {set i 1} {[winfo exists $swin.$i]} {incr i} {
         pack forget $swin.$i
      }
      $win.b1 config -text " +"
   }
}

set hwinid -1
proc helpWin { } {
   global installdir bweditlogo dpyfont hdrfont appbg appfg hwinid

   if {[winfo exists $hwinid]} {focus $hwinid; return}
   set hwin [toplevel .help]
   set hwinid $hwin
   $hwin config -bg $appbg
   frame $hwin.ctfr -bg $appbg -borderwidth 2 -relief raised
   frame $hwin.dpyfr -bg $appbg
   label $hwin.ctfr.logo -image "bweditlogo" -bg $appbg -cursor hand2
   bind $hwin.ctfr.logo <Button-1> { copyInfo }
   label $hwin.ctfr.hdr -text "Help topics" -bg $appbg -fg #990099 -font $hdrfont
   pack $hwin.ctfr.logo -pady 5
   pack $hwin.ctfr.hdr -pady 5 -fill x
   frame $hwin.ctfr.tfr -bg $appbg -borderwidth 0 -relief flat
   pack $hwin.ctfr.tfr -side top -padx 0 -pady 0 -fill y -expand yes

   addHelpBtn1 " " "Introduction" intro
   addHelpBtn1 " " "Coordinator window" coordinator
   addHelpBtn1 "+" "Main editor window" main
   addHelpBtn2 "+" "Toolbar" toolbar
   addHelpBtn3 "File menu" file
   addHelpBtn3 "Edit menu" edit
   addHelpBtn3 "Tag menu" tag
   addHelpBtn3 "Import menu" import
   addHelpBtn3 "Export menu" export
   addHelpBtn3 "Mail menu" mail
   addHelpBtn3 "Option menu" option
   addHelpBtn3 "Help menu" help
   addHelpBtn2 " " "File name" fname
   addHelpBtn2 " " "Textarea" textarea
   addHelpBtn1 "+" "Transliterator window" trans
   addHelpBtn2 "+" "Toolbar" rtoolbar
   addHelpBtn3 "File menu" rfile
   addHelpBtn3 "Edit menu" redit
   addHelpBtn3 "Export menu" rexport
   addHelpBtn3 "Mail menu" rmail
   addHelpBtn3 "Option menu" roption
   addHelpBtn3 "Help menu" rhelp
   addHelpBtn2 " " "Text area" rtext
   addHelpBtn2 " " "Online view" rolview
   addHelpBtn1 " " "Keyboard map" kbdmap
   addHelpBtn1 " " "Word list" wordlist
   addHelpBtn1 "+" "Read mails" readmail
   addHelpBtn2 "+" "Toolbar" mtool
   addHelpBtn3 "File menu" mfile
   addHelpBtn3 "Mail menu" mmail
   addHelpBtn3 "Option menu" moption
   addHelpBtn3 "Help menu" mhelp
   addHelpBtn2 " " "List of headers" maillist
   addHelpBtn2 " " "Mail display" maildpy
   addHelpBtn1 " " "Send mails" sendmail
   addHelpBtn1 " " "Command line options" cmdline
   addHelpBtn1 " " "Keyboard / mouse bindings" binding
   addHelpBtn1 " " "Copyright info" copyright

   button $hwin.ctfr.transrule -text "Transliteration rules" -fg $appfg -bg $appbg \
      -activeforeground $appfg -activebackground $appbg \
      -command "helpWinRoman" -underline 0
   pack $hwin.ctfr.transrule -side top -padx 2 -pady 1 -fill x

   button $hwin.ctfr.close -text "Close window" -fg $appfg -bg $appbg \
      -activeforeground $appfg -activebackground $appbg \
      -command "destroy $hwin" -underline 0
   pack $hwin.ctfr.close -side top -padx 2 -pady 1 -fill x

   text $hwin.dpyfr.textarea -relief sunken -height 45 -width 60 \
      -yscroll "$hwin.dpyfr.vscroll set" -state disabled -spacing3 2 \
      -wrap none -relief flat -highlightthickness 0 -font $dpyfont \
      -background #000000 -foreground #ffffff -borderwidth 2 \
      -selectbackground #ffffff -selectforeground #000000 -selectborderwidth 0
   scrollbar $hwin.dpyfr.vscroll -relief sunken -orient vertical \
      -command "$hwin.dpyfr.textarea yview" -bg $appbg -width 12 \
      -activebackground $appbg

   pack $hwin.dpyfr.vscroll -side right -padx 0 -pady 0 -expand no -fill y
   pack $hwin.dpyfr.textarea -side right -padx 0 -pady 0 -expand yes -fill both
   pack $hwin.ctfr -side left -padx 0 -pady 0 -expand no -fill y
   pack $hwin.dpyfr -side left -padx 0 -pady 0 -expand yes -fill both

   bind $hwin <Escape> "destroy $hwin"
   bind $hwin <Alt-c> "destroy $hwin; break"
   bind $hwin <Alt-C> "destroy $hwin; break"
   bind $hwin <Alt-t> "helpWinRoman"
   bind $hwin <Alt-T> "helpWinRoman"
   adddoc $hwin.dpyfr.textarea intro
   wm title $hwin "bwedit: Help"
   focus $hwin.dpyfr.textarea
   bind $hwin.dpyfr.textarea <Up> {break}
   bind $hwin.dpyfr.textarea <Down> {break}
   bind $hwin.dpyfr.textarea <Left> {break}
   bind $hwin.dpyfr.textarea <Right> {break}
}

proc addHelpBtnRoman { btn txt } {
   global appbg appfg

   button .rhelp.ctfr.$btn -text $txt -fg $appfg -bg $appbg \
      -activeforeground #0000ff -activebackground $appbg \
      -command "adddoc .rhelp.dpyfr.textarea $btn" -anchor w \
      -relief flat -borderwidth -1 -highlightthickness 0 -cursor hand2
   pack .rhelp.ctfr.$btn -side top -fill x -padx 0 -pady 0 -expand no
}

set hwinrid -1
proc helpWinRoman { } {
   global installdir bweditlogo hdrfont dpyfont appbg appfg hwinrid

   if {[winfo exists $hwinrid]} {focus $hwinrid; return}
   set hwin [toplevel .rhelp]
   set hwinrid $hwin
   $hwin config -bg $appbg
   frame $hwin.ctfr -bg $appbg -borderwidth 2 -relief raised
   frame $hwin.dpyfr -bg $appbg
   label $hwin.ctfr.logo -image "bweditlogo" -bg $appbg -cursor hand2
   bind $hwin.ctfr.logo <Button-1> { copyInfo }
   label $hwin.ctfr.hdr -text "Transliteration rules" -bg $appbg -fg #990099 -font $hdrfont
   pack $hwin.ctfr.logo -pady 5
   pack $hwin.ctfr.hdr -pady 5 -fill x

   addHelpBtnRoman cr1     "1. Introduction"
   addHelpBtnRoman cr2     "2. General rules"
   addHelpBtnRoman cr3     "3. The default encoding"
   addHelpBtnRoman cr3_1   "    3.1 Vowels"
   addHelpBtnRoman cr3_2   "    3.2 Consonants"
   addHelpBtnRoman cr3_3   "    3.3 Conjunct consonants"
   addHelpBtnRoman cr3_4   "    3.4 Digits and punctuation"
   addHelpBtnRoman cr4     "4. Customize encoding"
   addHelpBtnRoman cr5     "5. Inserting text in Roman font"
   addHelpBtnRoman cr6     "6. Conclusion"

   label $hwin.ctfr.space -text "" -fg $appfg -bg $appbg
   pack $hwin.ctfr.space -side top -padx 0 -pady 0 -fill y -expand yes

   button $hwin.ctfr.about -text "About bwedit" -fg $appfg -bg $appbg \
      -activeforeground $appfg -activebackground $appbg \
      -command "helpWin" -underline 0
   pack $hwin.ctfr.about -side top -padx 2 -pady 1 -fill x

   button $hwin.ctfr.close -text "Close window" -fg $appfg -bg $appbg \
      -activeforeground $appfg -activebackground $appbg \
      -command "destroy $hwin" -underline 0
   pack $hwin.ctfr.close -side top -padx 2 -pady 1 -fill x

   text $hwin.dpyfr.textarea -relief sunken -height 45 -width 60 \
      -yscroll "$hwin.dpyfr.vscroll set" -state disabled -spacing3 2 \
      -wrap none -relief flat -highlightthickness 0 -font $dpyfont \
      -background #ffffff -foreground #000000 -borderwidth 2 \
      -selectbackground #000000 -selectforeground #ffffff -selectborderwidth 0
   scrollbar $hwin.dpyfr.vscroll -relief sunken -orient vertical \
      -command "$hwin.dpyfr.textarea yview" -bg $appbg -width 12 \
      -activebackground $appbg

   pack $hwin.dpyfr.vscroll -side right -padx 0 -pady 0 -expand no -fill y
   pack $hwin.dpyfr.textarea -side right -padx 0 -pady 0 -expand yes -fill both
   pack $hwin.ctfr -side left -padx 0 -pady 0 -expand no -fill y
   pack $hwin.dpyfr -side left -padx 0 -pady 0 -expand yes -fill both

   bind $hwin <Escape> "destroy $hwin"
   bind $hwin <Alt-c> "destroy $hwin; break"
   bind $hwin <Alt-C> "destroy $hwin"
   bind $hwin <Alt-a> "helpWin"
   bind $hwin <Alt-A> "helpWin"
   adddoc $hwin.dpyfr.textarea cr1
   wm title $hwin "bwedit: Roman-to-Bengali transliteration scheme"
   focus $hwin.dpyfr.textarea
   bind $hwin.dpyfr.textarea <Up> {break}
   bind $hwin.dpyfr.textarea <Down> {break}
   bind $hwin.dpyfr.textarea <Left> {break}
   bind $hwin.dpyfr.textarea <Right> {break}
}

########################     End of help.tcl    ##########################

############################################################################
# option.tcl: Implements the option functions
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

###### Default main window options #######
set textbg "#000000"
set textfg "#ffffff"
set textsbg "#ffffff"
set textsfg "#000000"
set textibg "#d0f080"
set textht 16
set textwd 120
set ptsize 120
set slant "r"
set mwno 0
set openkbdmap 0


###### Default transliterator window options #######
set textbg2 "#ffffff"
set textfg2 "#000000"
set textsbg2 "#ffffaa"
set textsfg2 "#000000"
set textibg2 "#CC00CC"
set textht2 24
set textwd2 80
set olbg "#000000"
set olfg "#00ffff"
set twno 0
set readencopt "0"
set encfnm "$installdir/lib/bn.enc"

###### Default mail options ######
regsub "~" "~/bwmail" [glob -nocomplain "~"] bwmaildir
set mailcmd "elm -s %s %r < %f"
set mimen "mimencode %f"
set mimed "mimencode -u %f"
set uun "uuencode %f %f"
set uud "uudecode %f -o /dev/stdout"
set inbox "/var/spool/mail/[exec whoami]"
set openmail 0

proc readOptions {} {
   global textbg textfg textsbg textsfg textibg textht textwd ptsize slant mwno openkbdmap
   global textbg2 textfg2 textsbg2 textsfg2 textibg2 textht2 textwd2 twno readencopt encfnm olbg olfg
   global bwmaildir mailcmd mimen mimed uun uud inbox openmail

   set rcfile "~/.bweditrc"
   if [file exists $rcfile] {
      set rcf [open $rcfile r]
      while { [gets $rcf rcline] >= 0 } {
         set rcline [string trim $rcline]
         set cidx [string first ":" $rcline]
         if {($cidx >= 0) && [string compare "#" [string index $rcline 0]]} {
            set rcName [ string range $rcline 0 [expr $cidx - 1] ]
            set rcVal [ string range $rcline [expr $cidx + 1] [expr [string length $rcline] - 1] ]
            set rcName [string tolower [string trim $rcName]]
            set rcVal [string trim $rcVal]
            switch -exact $rcName {
               "textbackground" { set textbg $rcVal }
               "textforeground" { set textfg $rcVal }
               "selectionbackground" { set textsbg $rcVal }
               "selectionforeground" { set textsfg $rcVal }
               "cursorcolor" { set textibg $rcVal }
               "textheight" { set textht $rcVal }
               "textwidth" { set textwd $rcVal }
               "defaultpointsize" { set ptsize $rcVal }
               "slant" { set slant $rcVal }
               "numwin" { set mwno $rcVal }
               "viewkbdmap" { set openkbdmap $rcVal }
               "textbackground2" { set textbg2 $rcVal }
               "textforeground2" { set textfg2 $rcVal }
               "selectionbackground2" { set textsbg2 $rcVal }
               "selectionforeground2" { set textsfg2 $rcVal }
               "cursorcolor2" { set textibg2 $rcVal }
               "textheight2" { set textht2 $rcVal }
               "textwidth2" { set textwd2 $rcVal }
               "onlineforeground" { set olfg $rcVal }
               "onlinebackground" { set olbg $rcVal }
               "numwin2" { set twno $rcVal }
               "encfile" { set encfnm $rcVal ; set readencopt 2 }
               "bwmaildir" { regsub "~" $rcVal [glob -nocomplain "~"] bwmaildir }
               "mailcommand" { set mailcmd $rcVal }
               "mimencommand" { set mimen $rcVal }
               "mimedcommand" { set mimed $rcVal }
               "uuncommand" { set uun $rcVal }
               "uudcommand" { set uud $rcVal }
               "mailinbox" { set inbox $rcVal }
               "readmail" { set openmail $rcVal }
            }
         }
      }
      close $rcf
   }
}

readOptions

proc saveOptions { flag { myid 0 } } {
   global textbg textfg textsbg textsfg textibg textht textwd ptsize slant mwno openkbdmap
   global textbg2 textfg2 textsbg2 textsfg2 textibg2 textht2 textwd2 olfg olbg twno encfnm
   global bwmaildir mailcmd mimen mimed uun uud inbox openmail

   set rcfile "~/.bweditrc"
   set rcf [open $rcfile w]
   puts $rcf "# Resource file for bwedit version 3.0"
   puts $rcf "# Do not edit. Use the \"Edit options\" menu of bwedit\n"
   puts $rcf "# Main window"
   puts $rcf "TextBackGround\t\t: $textbg"
   puts $rcf "TextForeGround\t\t: $textfg"
   puts $rcf "SelectionBackGround\t: $textsbg"
   puts $rcf "SelectionForeGround\t: $textsfg"
   puts $rcf "CursorColor\t\t: $textibg"
   puts $rcf "TextHeight\t\t: $textht"
   puts $rcf "TextWidth\t\t: $textwd"
   puts $rcf "DefaultPointSize\t: $ptsize"
   puts $rcf "Slant\t\t\t: $slant"
   puts $rcf "NumWin\t\t\t: $mwno"
   puts $rcf "ViewKbdMap\t\t: $openkbdmap"
   puts $rcf "\n# Roman window"
   puts $rcf "TextBackGround2\t\t: $textbg2"
   puts $rcf "TextForeGround2\t\t: $textfg2"
   puts $rcf "SelectionBackGround2\t: $textsbg2"
   puts $rcf "SelectionForeGround2\t: $textsfg2"
   puts $rcf "CursorColor2\t\t: $textibg2"
   puts $rcf "TextHeight2\t\t: $textht2"
   puts $rcf "TextWidth2\t\t: $textwd2"
   puts $rcf "OnlineForeGround\t: $olfg"
   puts $rcf "OnlineBackGround\t: $olbg"
   puts $rcf "NumWin2\t\t\t: $twno"
   puts $rcf "EncFile\t\t\t: $encfnm"
   puts $rcf "\n# Mail options"
   puts $rcf "BWMailDir\t\t: $bwmaildir"
   puts $rcf "MailCommand\t\t: $mailcmd"
   puts $rcf "MIMENCommand\t\t: $mimen"
   puts $rcf "MIMEDCommand\t\t: $mimed"
   puts $rcf "UUNCommand\t\t: $uun"
   puts $rcf "UUDCommand\t\t: $uud"
   puts $rcf "MailInBox\t\t: $inbox"
   puts $rcf "ReadMail\t\t: $openmail"
   puts $rcf "\n# End of .bweditrc"
   close $rcf

   if {($flag == 1)} {
      errmsg $myid "Options saved"
   } elseif {($flag == 2)} {
      errmsg2 $myid "Options saved"
   }
}

proc editOptions { flag { myid 0 } } {
   global appfg appbg btnfg btnbg opttype hdrtxt
   global textbg textfg textsbg textsfg textibg textht textwd ptsize slant
   global oldtextbg oldtextfg oldtextsbg oldtextsfg oldtextibg oldtextht oldtextwd oldptsize oldslant
   global textbg2 textfg2 textsbg2 textsfg2 textibg2 textht2 textwd2
   global oldtextbg2 oldtextfg2 oldtextsbg2 oldtextsfg2 oldtextibg2 oldtextht2 oldtextwd2
   global oldolfg oldolbg olfg olbg
   global bwmaildir mailcmd mimen mimed uun uud inbox
   global oldbwmaildir oldmailcmd oldmimen oldmimed olduun olduud oldinbox
   global mwno twno openmail openkbdmap encfnm
   global oldmwno oldtwno oldopenmail oldopenkbdmap oldencfnm
   global hdrfont

   if {[winfo exists .option]} {
     switch -exact $opttype {
         "1" {
            pack forget .option.roman .option.mail .option.sep2 .option.btnfr
            pack .option.main -expand yes -fill both -pady 5
            pack .option.sep2 -expand yes -fill x -padx 5 -pady 5
            pack .option.btnfr -expand no -pady 5
            set hdrtxt "Main window options"
         }
         "2" {
            pack forget .option.main .option.mail .option.sep2 .option.btnfr
            pack .option.roman -expand yes -fill both -pady 5
            pack .option.sep2 -expand yes -fill x -padx 5 -pady 5
            pack .option.btnfr -expand no -pady 5
            set hdrtxt "Transliterator window options"
         }
         "3" {
            pack forget .option.main .option.roman .option.sep2 .option.btnfr
            pack .option.mail -expand yes -fill both -pady 5
            pack .option.sep2 -expand yes -fill x -padx 5 -pady 5
            pack .option.btnfr -expand no -pady 5
            set hdrtxt "Mail options"
         }
      }
      focus .option; return
   }

   set oldtextbg $textbg
   set oldtextfg $textfg
   set oldtextsbg $textsbg
   set oldtextsfg $textsfg
   set oldtextibg $textibg
   set oldtextht $textht
   set oldtextwd $textwd
   set oldptsize $ptsize
   set oldslant $slant
   set oldtextbg2 $textbg2
   set oldtextfg2 $textfg2
   set oldtextsbg2 $textsbg2
   set oldtextsfg2 $textsfg2
   set oldtextibg2 $textibg2
   set oldtextht2 $textht2
   set oldtextwd2 $textwd2
   set oldolfg $olfg
   set oldolbg $olbg
   set oldbwmaildir $bwmaildir
   set oldmailcmd $mailcmd
   set oldmimen $mimen
   set oldmimed $mimed
   set olduun $uun
   set olduud $uud
   set oldinbox $inbox
   set oldmwno $mwno
   set oldtwno $twno
   set oldopenmail $openmail
   set oldopenkbdmap $openkbdmap
   set oldencfnm $encfnm

   set dbox [toplevel .option]
   $dbox config -bg $appbg
   wm title $dbox "bwedit: Edit options"
   wm resizable $dbox false false

   frame $dbox.selfr -bg $appbg -relief raised
   radiobutton $dbox.selfr.main -relief flat -highlightthickness 0 \
      -selectcolor #bbff00 -fg $appfg -bg $appbg \
      -activebackground $appbg -activeforeground $appfg \
      -variable opttype -value 1 -text "Main"
   radiobutton $dbox.selfr.roman -relief flat -highlightthickness 0 \
      -selectcolor #bbff00 -fg $appfg -bg $appbg \
      -activebackground $appbg -activeforeground $appfg \
      -variable opttype -value 2 -text "Transliterator"
   radiobutton $dbox.selfr.mail -relief flat -highlightthickness 0 \
      -selectcolor #bbff00 -fg $appfg -bg $appbg \
      -activebackground $appbg -activeforeground $appfg \
      -variable opttype -value 3 -text "Mail"

   bind $dbox.selfr.main <ButtonPress-1> {
      if {$opttype != 1} {
         pack forget .option.roman .option.mail .option.sep2 .option.btnfr
         pack .option.main -expand yes -fill both -pady 5
         pack .option.sep2 -expand yes -fill x -padx 5 -pady 5
         pack .option.btnfr -expand no -pady 5
         set hdrtxt "Main window options"
         set opttype 1
      }
   }
   bind $dbox.selfr.roman <ButtonPress-1> {
      if {$opttype != 2} {
         pack forget .option.main .option.mail .option.sep2 .option.btnfr
         pack .option.roman -expand yes -fill both -pady 5
         pack .option.sep2 -expand yes -fill x -padx 5 -pady 5
         pack .option.btnfr -expand no -pady 5
         set hdrtxt "Transliterator window options"
         set opttype 2
      }
   }
   bind $dbox.selfr.mail <ButtonPress-1> {
      if {$opttype != 3} {
         pack forget .option.main .option.roman .option.sep2 .option.btnfr
         pack .option.mail -expand yes -fill both -pady 5
         pack .option.sep2 -expand yes -fill x -padx 5 -pady 5
         pack .option.btnfr -expand no -pady 5
         set hdrtxt "Mail options"
         set opttype 3
      }
   }

   frame $dbox.sep1 -bg $appfg -height 3 -relief flat
   frame $dbox.sep2 -bg $appfg -height 3 -relief flat

   switch -exact $opttype {
      2 { set hdrtxt "Transliterator window options" }
      3 { set hdrtxt "Mail options" }
      default { set hdrtxt "Main window options" }
   }
   label $dbox.hdr -bg $appbg -fg #8800AA -relief flat -textvariable hdrtxt -font $hdrfont

   frame $dbox.main -bg $appbg
   frame $dbox.main.fr1 -bg $appbg
   frame $dbox.main.fr2 -bg $appbg
   frame $dbox.main.fr3 -bg $appbg
   frame $dbox.main.fr4 -bg $appbg
   frame $dbox.main.fr5 -bg $appbg
   frame $dbox.main.fr6 -bg $appbg
   frame $dbox.main.fr7 -bg $appbg
   frame $dbox.main.fr8 -bg $appbg
   frame $dbox.main.fr9 -bg $appbg
   frame $dbox.main.frA -bg $appbg
   frame $dbox.main.frB -bg $appbg
   label $dbox.main.fr1.lbl -text "Text background color: " -relief flat -anchor e -fg $appfg -bg $appbg
   entry $dbox.main.fr1.ent -textvariable textbg -bg #ddaaaa -fg #000000
   label $dbox.main.fr2.lbl -text "Text foreground color: " -relief flat -anchor e -fg $appfg -bg $appbg
   entry $dbox.main.fr2.ent -textvariable textfg -bg #ddaaaa -fg #000000
   label $dbox.main.fr3.lbl -text "Selection background color: " -relief flat -anchor e -fg $appfg -bg $appbg
   entry $dbox.main.fr3.ent -textvariable textsbg -bg #ddaaaa -fg #000000
   label $dbox.main.fr4.lbl -text "Selection foreground color: " -relief flat -anchor e -fg $appfg -bg $appbg
   entry $dbox.main.fr4.ent -textvariable textsfg -bg #ddaaaa -fg #000000
   label $dbox.main.fr5.lbl -text "Cursor color: " -relief flat -anchor e -fg $appfg -bg $appbg
   entry $dbox.main.fr5.ent -textvariable textibg -bg #ddaaaa -fg #000000
   label $dbox.main.fr6.lbl -text "Text height (number of lines): " -relief flat -anchor e -fg $appfg -bg $appbg
   entry $dbox.main.fr6.ent -textvariable textht -bg #ddaaaa -fg #000000
   label $dbox.main.fr7.lbl -text "Text width (in avg char width): " -relief flat -anchor e -fg $appfg -bg $appbg
   entry $dbox.main.fr7.ent -textvariable textwd -bg #ddaaaa -fg #000000
   label $dbox.main.fr8.lbl -text "Default point size: " -relief flat -anchor e -fg $appfg -bg $appbg
   menubutton $dbox.main.fr8.pt -textvariable ptsize -height 1 -width 8 \
      -relief raised -menu $dbox.main.fr8.pt.m -bg $appbg -fg $appfg \
      -activebackground $appbg -activeforeground $appfg
   menu $dbox.main.fr8.pt.m -tearoff false -bg $appbg -fg $appfg
   $dbox.main.fr8.pt.m add command -label " 100 " -command {set ptsize 100}
   $dbox.main.fr8.pt.m add command -label " 120 " -command {set ptsize 120}
   $dbox.main.fr8.pt.m add command -label " 150 " -command {set ptsize 150}
   $dbox.main.fr8.pt.m add command -label " 180 " -command {set ptsize 180}
   $dbox.main.fr8.pt.m add command -label " 210 " -command {set ptsize 210}
   $dbox.main.fr8.pt.m add command -label " 250 " -command {set ptsize 250}
   $dbox.main.fr8.pt.m add command -label " 300 " -command {set ptsize 300}
   $dbox.main.fr8.pt.m add command -label " 360 " -command {set ptsize 360}
   checkbutton $dbox.main.fr9.cb1 -text " Use slanted font " \
      -variable slant -onvalue "o" -offvalue "r" -relief ridge \
      -selectcolor #bbff00 -fg $appfg -bg $appbg \
      -activeforeground $appfg -activebackground $appbg
   label $dbox.main.frA.lbl -text "Number of windows to launch: " -relief flat -anchor e -fg $appfg -bg $appbg
   entry $dbox.main.frA.ent -textvariable mwno -bg #ddaaaa -fg #000000
   checkbutton $dbox.main.frB.cb1 -text " Show keyboard map " \
      -variable openkbdmap -onvalue "1" -offvalue "0" -relief ridge \
      -selectcolor #bbff00 -fg $appfg -bg $appbg \
      -activeforeground $appfg -activebackground $appbg

   for {set i 1} {$i <= 7} {incr i 1} {
      pack $dbox.main.fr$i.lbl -padx 5 -pady 5 -side left -expand yes -fill x
      pack $dbox.main.fr$i.ent -padx 5 -pady 5
      pack $dbox.main.fr$i -padx 5 -pady 2 -expand yes -fill x
   }
   pack $dbox.main.fr8.lbl $dbox.main.fr8.pt -padx 5 -pady 5 -side left
   pack $dbox.main.fr8 -padx 5 -pady 2
   pack $dbox.main.fr9.cb1 -padx 5 -pady 5 -side left
   pack $dbox.main.fr9 -padx 5 -pady 2
   pack $dbox.main.frA.lbl -padx 5 -pady 5 -side left -expand yes -fill x
   pack $dbox.main.frA.ent -padx 5 -pady 5
   pack $dbox.main.frA -padx 5 -pady 2 -expand yes -fill x
   pack $dbox.main.frB.cb1 -padx 5 -pady 5 -side left
   pack $dbox.main.frB -padx 5 -pady 2
   bind $dbox.main.fr1.ent <Return>  "focus $dbox.main.fr2.ent"
   bind $dbox.main.fr2.ent <Return>  "focus $dbox.main.fr3.ent"
   bind $dbox.main.fr3.ent <Return>  "focus $dbox.main.fr4.ent"
   bind $dbox.main.fr4.ent <Return>  "focus $dbox.main.fr5.ent"
   bind $dbox.main.fr5.ent <Return>  "focus $dbox.main.fr6.ent"
   bind $dbox.main.fr6.ent <Return>  "focus $dbox.main.fr7.ent"
   bind $dbox.main.fr7.ent <Return>  "focus $dbox.main.frA.ent"
   bind $dbox.main.frA.ent <Return>  "focus $dbox.main.fr1.ent"

   frame $dbox.roman -bg $appbg
   frame $dbox.roman.fr1 -bg $appbg
   frame $dbox.roman.fr2 -bg $appbg
   frame $dbox.roman.fr3 -bg $appbg
   frame $dbox.roman.fr4 -bg $appbg
   frame $dbox.roman.fr5 -bg $appbg
   frame $dbox.roman.fr6 -bg $appbg
   frame $dbox.roman.fr7 -bg $appbg
   frame $dbox.roman.fr8 -bg $appbg
   frame $dbox.roman.fr9 -bg $appbg
   frame $dbox.roman.fr10 -bg $appbg
   frame $dbox.roman.fr11 -bg $appbg
   label $dbox.roman.fr1.lbl -text "Text background color: " -relief flat -anchor e -fg $appfg -bg $appbg
   entry $dbox.roman.fr1.ent -textvariable textbg2 -bg #ddaaaa -fg #000000
   label $dbox.roman.fr2.lbl -text "Text foreground color: " -relief flat -anchor e -fg $appfg -bg $appbg
   entry $dbox.roman.fr2.ent -textvariable textfg2 -bg #ddaaaa -fg #000000
   label $dbox.roman.fr3.lbl -text "Selection background color: " -relief flat -anchor e -fg $appfg -bg $appbg
   entry $dbox.roman.fr3.ent -textvariable textsbg2 -bg #ddaaaa -fg #000000
   label $dbox.roman.fr4.lbl -text "Selection foreground color: " -relief flat -anchor e -fg $appfg -bg $appbg
   entry $dbox.roman.fr4.ent -textvariable textsfg2 -bg #ddaaaa -fg #000000
   label $dbox.roman.fr5.lbl -text "Cursor color: " -relief flat -anchor e -fg $appfg -bg $appbg
   entry $dbox.roman.fr5.ent -textvariable textibg2 -bg #ddaaaa -fg #000000
   label $dbox.roman.fr6.lbl -text "Text height (number of lines): " -relief flat -anchor e -fg $appfg -bg $appbg
   entry $dbox.roman.fr6.ent -textvariable textht2 -bg #ddaaaa -fg #000000
   label $dbox.roman.fr7.lbl -text "Text width (in avg char width): " -relief flat -anchor e -fg $appfg -bg $appbg
   entry $dbox.roman.fr7.ent -textvariable textwd2 -bg #ddaaaa -fg #000000
   label $dbox.roman.fr8.lbl -text "Background color for online text: " -relief flat -anchor e -fg $appfg -bg $appbg
   entry $dbox.roman.fr8.ent -textvariable olbg -bg #ddaaaa -fg #000000
   label $dbox.roman.fr9.lbl -text "Foreground color for online text: " -relief flat -anchor e -fg $appfg -bg $appbg
   entry $dbox.roman.fr9.ent -textvariable olfg -bg #ddaaaa -fg #000000
   label $dbox.roman.fr10.lbl -text "Number of windows to launch: " -relief flat -anchor e -fg $appfg -bg $appbg
   entry $dbox.roman.fr10.ent -textvariable twno -bg #ddaaaa -fg #000000
   label $dbox.roman.fr11.lbl -text "Read encoding from file: " -relief flat -anchor e -fg $appfg -bg $appbg
   entry $dbox.roman.fr11.ent -textvariable encfnm -bg #ddaaaa -fg #000000

   for {set i 1} {$i <= 11} {incr i 1} {
      pack $dbox.roman.fr$i.lbl -padx 5 -pady 5 -side left -expand yes -fill x
      pack $dbox.roman.fr$i.ent -padx 5 -pady 5
      pack $dbox.roman.fr$i -padx 5 -pady 2 -expand yes -fill x
   }

   bind $dbox.roman.fr1.ent <Return> "focus $dbox.roman.fr2.ent"
   bind $dbox.roman.fr2.ent <Return> "focus $dbox.roman.fr3.ent"
   bind $dbox.roman.fr3.ent <Return> "focus $dbox.roman.fr4.ent"
   bind $dbox.roman.fr4.ent <Return> "focus $dbox.roman.fr5.ent"
   bind $dbox.roman.fr5.ent <Return> "focus $dbox.roman.fr6.ent"
   bind $dbox.roman.fr6.ent <Return> "focus $dbox.roman.fr7.ent"
   bind $dbox.roman.fr7.ent <Return> "focus $dbox.roman.fr8.ent"
   bind $dbox.roman.fr8.ent <Return> "focus $dbox.roman.fr9.ent"
   bind $dbox.roman.fr9.ent <Return> "focus $dbox.roman.fr10.ent"
   bind $dbox.roman.fr10.ent <Return> "focus $dbox.roman.fr11.ent"
   bind $dbox.roman.fr11.ent <Return> "focus $dbox.roman.fr1.ent"

   frame $dbox.mail -bg $appbg
   frame $dbox.mail.fr1 -bg $appbg
   frame $dbox.mail.fr2 -bg $appbg
   frame $dbox.mail.fr3 -bg $appbg
   frame $dbox.mail.fr4 -bg $appbg
   frame $dbox.mail.fr5 -bg $appbg
   frame $dbox.mail.fr6 -bg $appbg
   frame $dbox.mail.fr7 -bg $appbg
   frame $dbox.mail.fr8 -bg $appbg

   label $dbox.mail.fr1.lbl -text "Mail cache directory: " -relief flat -anchor e -fg $appfg -bg $appbg
   entry $dbox.mail.fr1.ent -textvariable bwmaildir -bg #ddaaaa -fg #000000 -width 30
   label $dbox.mail.fr2.lbl -text "Send mail command: " -relief flat -anchor e -fg $appfg -bg $appbg
   entry $dbox.mail.fr2.ent -textvariable mailcmd -bg #ddaaaa -fg #000000 -width 30
   label $dbox.mail.fr3.lbl -text "MIME encoding command: " -relief flat -anchor e -fg $appfg -bg $appbg
   entry $dbox.mail.fr3.ent -textvariable mimen -bg #ddaaaa -fg #000000 -width 30
   label $dbox.mail.fr4.lbl -text "MIME decoding command: " -relief flat -anchor e -fg $appfg -bg $appbg
   entry $dbox.mail.fr4.ent -textvariable mimed -bg #ddaaaa -fg #000000 -width 30
   label $dbox.mail.fr5.lbl -text "uuencoding command: " -relief flat -anchor e -fg $appfg -bg $appbg
   entry $dbox.mail.fr5.ent -textvariable uun -bg #ddaaaa -fg #000000 -width 30
   label $dbox.mail.fr6.lbl -text "uudecoding command: " -relief flat -anchor e -fg $appfg -bg $appbg
   entry $dbox.mail.fr6.ent -textvariable uud -bg #ddaaaa -fg #000000 -width 30
   label $dbox.mail.fr7.lbl -text "Mail inbox: " -relief flat -anchor e -fg $appfg -bg $appbg
   entry $dbox.mail.fr7.ent -textvariable inbox -bg #ddaaaa -fg #000000 -width 30
   checkbutton $dbox.mail.fr8.cb1 -text " Launch read mail window " \
      -variable openmail -onvalue "1" -offvalue "0" -relief ridge \
      -selectcolor #bbff00 -fg $appfg -bg $appbg \
      -activeforeground $appfg -activebackground $appbg
   button $dbox.mail.clear -text "Clear mail cache" -relief raised -command {
      foreach file [glob -nocomplain $bwmaildir/raw.* $bwmaildir/snd.*] {
         exec rm -f $file
      }
   } -fg $appfg -bg $appbg -activeforeground $appfg -activebackground $appbg

   for {set i 1} {$i <= 7} {incr i 1} {
      pack $dbox.mail.fr$i.lbl -padx 5 -pady 5 -side left -expand yes -fill x
      pack $dbox.mail.fr$i.ent -padx 5 -pady 5
      pack $dbox.mail.fr$i -padx 5 -pady 2 -expand yes -fill x
   }
   pack $dbox.mail.fr8.cb1 -padx 5 -pady 5 -side left
   pack $dbox.mail.fr8 -padx 5 -pady 2
   pack $dbox.mail.clear -pady 2 -expand no

   bind $dbox.mail.fr1.ent <Return>  "focus $dbox.mail.fr2.ent"
   bind $dbox.mail.fr2.ent <Return>  "focus $dbox.mail.fr3.ent"
   bind $dbox.mail.fr3.ent <Return>  "focus $dbox.mail.fr4.ent"
   bind $dbox.mail.fr4.ent <Return>  "focus $dbox.mail.fr5.ent"
   bind $dbox.mail.fr5.ent <Return>  "focus $dbox.mail.fr6.ent"
   bind $dbox.mail.fr6.ent <Return>  "focus $dbox.mail.fr1.ent"

   frame $dbox.btnfr -bg $appbg -relief flat
   button $dbox.btnfr.apply -text "Apply" -relief raised -command {
      switch -exact $opttype {
         2 {
            applyRomanOptions
            set oldtextbg2 $textbg2
            set oldtextfg2 $textfg2
            set oldtextsbg2 $textsbg2
            set oldtextsfg2 $textsfg2
            set oldtextibg2 $textibg2
            set oldtextht2 $textht2
            set oldtextwd2 $textwd2
            set oldolbg $olbg
            set oldolfg $olfg
            set oldtwno $twno
            set oldencfnm $encfnm
         }
         3 {
            set oldbwmaildir $bwmaildir
            set oldmailcmd $mailcmd
            set oldmimen $mimen
            set oldmimed $mimed
            set olduun $uun
            set olduud $uud
            set oldinbox $inbox
            set oldopenmail $openmail
         }
         default {
            applyMainOptions
            set oldtextbg $textbg
            set oldtextfg $textfg
            set oldtextsbg $textsbg
            set oldtextsfg $textsfg
            set oldtextibg $textibg
            set oldtextht $textht
            set oldtextwd $textwd
            set oldptsize $ptsize
            set oldslant $slant
            set oldmwno $mwno
            set oldopenkbdmap $openkbdmap
         }
      }
   } -fg $btnfg -bg $btnbg -activeforeground $btnfg -activebackground $btnbg -underline 0

   button $dbox.btnfr.default -text "Default" -relief raised -command {
      readOptions
   } -fg $btnfg -bg $btnbg -activeforeground $btnfg -activebackground $btnbg -underline 0

   button $dbox.btnfr.save -text "Save" -relief raised -command {
      saveOptions 0
   } -fg $btnfg -bg $btnbg -activeforeground $btnfg -activebackground $btnbg -underline 0

   button $dbox.btnfr.cancel -text "Cancel" -relief raised -command {
      set textbg $oldtextbg
      set textfg $oldtextfg
      set textsbg $oldtextsbg
      set textsfg $oldtextsfg
      set textibg $oldtextibg
      set textht $oldtextht
      set textwd $oldtextwd
      set ptsize $oldptsize
      set slant $oldslant
      set mwno $oldmwno
      set openkbdmap $oldopenkbdmap
      set textbg2 $oldtextbg2
      set textfg2 $oldtextfg2
      set textsbg2 $oldtextsbg2
      set textsfg2 $oldtextsfg2
      set textibg2 $oldtextibg2
      set textht2 $oldtextht2
      set textwd2 $oldtextwd2
      set olbg $oldolbg
      set olfg $oldolfg
      set twno $oldtwno
      set encfnm $oldencfnm
      set bwmaildir $oldbwmaildir
      set mailcmd $oldmailcmd
      set mimen $oldmimen
      set mimed $oldmimed
      set uun $olduun
      set uud $olduud
      set inbox $oldinbox
      set openmail $oldopenmail
      destroy .option
   } -fg $btnfg -bg $btnbg -activeforeground $btnfg -activebackground $btnbg -underline 0

   button $dbox.btnfr.done -text "Done" -relief raised -command {
      if {$opttype == 1} {applyMainOptions}
      if {$opttype == 2} {applyRomanOptions}
      destroy .option
   } -fg $btnfg -bg $btnbg -activeforeground $btnfg -activebackground $btnbg -underline 2

   pack $dbox.selfr.main $dbox.selfr.roman $dbox.selfr.mail -padx 10 -expand no -side left
   pack $dbox.btnfr.apply $dbox.btnfr.default $dbox.btnfr.save $dbox.btnfr.cancel $dbox.btnfr.done -padx 5 -side left
   pack $dbox.selfr -expand no -pady 5
   pack $dbox.sep1 -expand yes -fill x -padx 5 -pady 5
   pack $dbox.hdr -expand no -pady 5
   switch -exact $opttype {
      2 { pack $dbox.roman -expand yes -fill both -pady 5 }
      3 { pack $dbox.mail -expand yes -fill both -pady 5 }
      default { pack $dbox.main -expand yes -fill both -pady 5 }
   }
   pack $dbox.sep2 -expand yes -fill x -padx 5 -pady 5
   pack $dbox.btnfr -expand no -pady 5

   bind $dbox <Escape> "destroy $dbox"
   bind $dbox <Alt-a> "$dbox.btnfr.apply invoke; break"
   bind $dbox <Alt-A> "$dbox.btnfr.apply invoke; break"
   bind $dbox <Alt-d> "$dbox.btnfr.default invoke; break"
   bind $dbox <Alt-D> "$dbox.btnfr.default invoke; break"
   bind $dbox <Alt-s> "$dbox.btnfr.save invoke; break"
   bind $dbox <Alt-S> "$dbox.btnfr.save invoke; break"
   bind $dbox <Alt-c> "$dbox.btnfr.cancel invoke; break"
   bind $dbox <Alt-C> "$dbox.btnfr.cancel invoke; break"
   bind $dbox <Alt-n> "$dbox.btnfr.done invoke; break"
   bind $dbox <Alt-N> "$dbox.btnfr.done invoke; break"
}
proc applyMainOptions { } {
   global mavail textbg textfg textsbg textsfg textibg textht textwd ptsize slant textsp3 openkbdmap

   switch -exact $ptsize {
      100 {set textsp3 4}
      120 {set textsp3 5}
      150 {set textsp3 6}
      180 {set textsp3 7}
      210 {set textsp3 8}
      250 {set textsp3 10}
      300 {set textsp3 12}
      360 {set textsp3 15}
      default {set textsp3 5}
   }

   for {set i 1} {$i < $mavail} {incr i 1} {
      if {[winfo exists .main$i]} {
         .main$i.mainfr.editfr.textarea config -height $textht -width $textwd \
             -font "-*-bengali-medium-$slant-*-*-*-$ptsize-*-*-*-*-*-fontspecific" \
             -spacing3 $textsp3 -insertbackground $textibg \
             -background $textbg -foreground $textfg \
             -selectbackground $textsbg -selectforeground $textsfg
      }
   }

   if {($openkbdmap == 1) && (![winfo exists .kbdmap])} {viewKbdMap}
}

proc applyRomanOptions { } {
   global ravail textbg2 textfg2 textsbg2 textsfg2 textibg2 textht2 textwd2 olfg olbg encfnm

   for {set i 1} {$i < $ravail} {incr i 1} {
      if {[winfo exists .roman$i]} {
         .roman$i.mainfr.editfr.textarea config -height $textht2 -width $textwd2 \
            -insertbackground $textibg2 \
            -background $textbg2 -foreground $textfg2 \
            -selectbackground $textsbg2 -selectforeground $textsfg2
         .roman$i.mainfr.olview config -fg $olfg -bg $olbg \
            -selectforeground $olfg -selectbackground $olbg -selectborder 0
      }
   }

   if {[string length $encfnm] > 0} {readEnc 2 $encfnm}
}

########################     End of option.tcl    ##########################

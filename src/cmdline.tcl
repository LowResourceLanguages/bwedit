############################################################################
# cmdline.tcl: Implements the main window functions
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

proc printerrmsg { option } {
   puts "No argument specified for option \"$option\""
   puts "Type \"bwedit -h\" to list the command line options"
   exit
}

proc printVersion { } {
   puts "bwedit: Version 3.0"
   puts "Copyright 1998 - 1999 by Abhijit Das (ad_rab@yahoo.com)"
   exit
}

proc printHelp { } {
   puts "Usage: bwedit \[options\]\nThe options are"
   puts "   -m <file>      Open <file> in main window"
   puts "   -t <file>      Open <file> in transliterator window"
   puts "   -nm <num>      Open <num> blank main windows (Maximum 5)"
   puts "   -nt <num>      Open <num> blank transliterator windows (Maximum 5)"
   puts "   -bw <file>     Open bwencoded <file>"
   puts "   -uu <file>     Open uuencoded <file>"
   puts "   -mime <file>   Open MIME encoded <file>"
   puts "   -e <file>      Read Roman-to-Bengali encoding from <file>"
   puts "   -rm            Open read mail window"
   puts "   -k             Open Keyboard map window"
   puts "   -wl            Open Wordlist window"
   puts "   -f <size>      Set default font size to <size> points"
   puts "   -hl <num>      Set help level (0, 1, 2 or 3)"
   puts "   -h             Print this help message and quit"
   puts "   -v             Print version info and quit"
   destroy .
   exit
}

set mflist [list]
set tflist [list]
set bwlist [list]
set uulist [list]
set mimelist [list]
set helplvl 0
set dfltptsize $ptsize
set openwordlist 0

set narg [llength $argv]
if {![string compare [lindex $argv 0] "-h"]} {
   printHelp
}
for {set i 0} {$i < $narg} {incr i 1} {
   set thisarg [lindex $argv $i]
   if {![string compare $thisarg "-h"]} {
      printHelp
   } elseif {![string compare $thisarg "-v"]} {
      printVersion
   } elseif {![string compare $thisarg "-m"]} {
      if {$i == $narg - 1} { printerrmsg "-m" }
      incr i 1
      lappend mflist [lindex $argv $i]
   } elseif {![string compare $thisarg "-t"]} {
      if {$i == $narg - 1} { printerrmsg "-t" }
      incr i 1
      lappend tflist [lindex $argv $i]
   } elseif {![string compare $thisarg "-nm"]} {
      if {$i == $narg - 1} { printerrmsg "-nm" }
      incr i 1
      set mwno [lindex $argv $i]
   } elseif {![string compare $thisarg "-nt"]} {
      if {$i == $narg - 1} { printerrmsg "-nt" }
      incr i 1
      set twno [lindex $argv $i]
   } elseif {![string compare $thisarg "-e"]} {
      if {$i == $narg - 1} { printerrmsg "-e" }
      incr i 1
      set readencopt 2
      set encfnm [lindex $argv $i]
   } elseif {![string compare $thisarg "-bw"]} {
      if {$i == $narg - 1} { printerrmsg "-bw" }
      incr i 1
      lappend bwlist [lindex $argv $i]
   } elseif {![string compare $thisarg "-uu"]} {
      if {$i == $narg - 1} { printerrmsg "-uu" }
      incr i 1
      lappend uulist [lindex $argv $i]
   } elseif {![string compare $thisarg "-mime"]} {
      if {$i == $narg - 1} { printerrmsg "-mime" }
      incr i 1
      lappend mimelist [lindex $argv $i]
   } elseif {![string compare $thisarg "-f"]} {
      if {$i == $narg - 1} { printerrmsg "-f" }
      incr i 1
      set ptsize [lindex $argv $i]
   } elseif {![string compare $thisarg "-rm"]} {
      set openmail 1
   } elseif {![string compare $thisarg "-k"]} {
      set openkbdmap 1
   } elseif {![string compare $thisarg "-wl"]} {
      set openwordlist 1
   } elseif {![string compare $thisarg "-hl"]} {
      if {$i == $narg - 1} { printerrmsg "-hl" }
      incr i 1
      set helplvl [lindex $argv $i]
   } else {
      if {![string compare "-" [string range $thisarg 0 0]]} {
         puts "Unknown option: [lindex $argv $i]"
         puts "Type \"bwedit -h\" to list the command line options"
         exit
      }
      lappend mflist [lindex $argv $i]
   }
}

if {($ptsize != 100) && ($ptsize != 120) && ($ptsize != 150) && ($ptsize != 180) && ($ptsize != 210) && ($ptsize != 250) && ($ptsize != 300) && ($ptsize != 360) } {
   puts "Font size should be one of 100, 120, 150, 180, 210, 250, 300 and 360"
   set ptsize $dfltptsize
}
switch -exact $ptsize {
   100 {set textsp3 4; set off1 5; set off2 8; set off3 3;}
   120 {set textsp3 5; set off1 6; set off2 9; set off3 3;}
   150 {set textsp3 6; set off1 7; set off2 12; set off3 4;}
   180 {set textsp3 7; set off1 9; set off2 14; set off3 5;}
   210 {set textsp3 8; set off1 10; set off2 16; set off3 6;}
   250 {set textsp3 10; set off1 12; set off2 20; set off3 7;}
   300 {set textsp3 12; set off1 15; set off2 24; set off3 9;}
   360 {set textsp3 15; set off1 18; set off2 28; set off3 10;}
   default {set textsp3 5; set off1 6; set off2 9; set off3 3;}
}
if {$readencopt == 2} { readEnc 2 $encfnm } else { readEnc }
for {set i 0} {$i < [llength $mflist]} {incr i 1} {
   loadMain2 [lindex $mflist $i]
}
for {set i 0} {$i < [llength $tflist]} {incr i 1} {
   loadRoman2 [lindex $tflist $i]
}
if {$mwno > 5} {set mwno 5}
if {$twno > 5} {set twno 5}
for {set i 0} {$i < $mwno} {incr i 1} { newMain }
for {set i 0} {$i < $twno} {incr i 1} { newRoman }
for {set i 0} {$i < [llength $bwlist]} {incr i 1} {
   readBW 0 -1 [lindex $bwlist $i]
}
for {set i 0} {$i < [llength $uulist]} {incr i 1} {
   readUU 0 -1 [lindex $uulist $i]
}
for {set i 0} {$i < [llength $mimelist]} {incr i 1} {
   readMIME 0 -1 [lindex $mimelist $i]
}
if {$openmail} { readMail }
if {$openkbdmap} { viewKbdMap }
if {$openwordlist} { viewWordList }

switch -exact $helplvl {
   1 { helpWin }
   2 { helpWinRoman }
   3 { helpWin; helpWinRoman }
}

########################     End of main.tcl    ##########################

############################################################################
# refresh.tcl: Implements the refresh-win-list functions
# Author: Abhijit Das (Barda) [ad_rab@yahoo.com]
# Last updated: March 22 2000
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

set targetWin 0
set mtwin 0
set rmtwin 0

proc refreshAllWinList { } {
   refreshTargetWinList
   if {[winfo exists .kbdmap]} { updateWinMenu }
   if {[winfo exists .sendmail]} { mupdateMenus }
}

proc updateWinMenu { } {
   global targetWin mavail ravail

   .kbdmap.row0.target.m delete 0 last
   for {set i 0} {$i <= $mavail} {incr i 1} {
      if {[winfo exists ".main$i"]} {
         .kbdmap.row0.target.m add command -label "Target: Main window $i" \
            -command "
               set targetWin [list $i]
               .kbdmap.row0.target config -text { [list Target : Main window $i] } -underline 1
            "
      }
   }
   for {set i 0} {$i <= $ravail} {incr i 1} {
      if {[winfo exists ".roman$i"]} {
         .kbdmap.row0.target.m add command -label "Target: Transliterator window $i" \
            -command "
               set targetWin [list -$i]
               .kbdmap.row0.target config -text { [list Target : Transliterator window $i] } -underline 1
            "
      }
   }
   if {($targetWin > 0) && (![winfo exists .main$targetWin])} {
      set targetWin 0
      .kbdmap.row0.target config -text " Target window : (None) "
   }
   if {($targetWin < 0) && (![winfo exists .roman[expr -$targetWin]])} {
      set targetWin 0
      .kbdmap.row0.target config -text " Target window : (None) "
   }
}

proc mupdateMenus { } {
   global mavail ravail mtwin rmtwin

   .sendmail.fr6.btn.m delete 0 last
   .sendmail.fr7.btn.m delete 0 last
   for {set i 1} {$i <= $mavail} {incr i 1} {
      if {[winfo exists .main$i]} {
         .sendmail.fr6.btn.m add command -label "Main window $i" \
            -command ".sendmail.fr6.rad config -text {Main window $i}; set mtwin {$i}"
      }
   }
   for {set i 1} {$i <= $ravail} {incr i 1} {
      if {[winfo exists .roman$i]} {
         .sendmail.fr7.btn.m add command -label "Transliterator window $i" \
            -command ".sendmail.fr7.rad config -text {Transliterator window $i}; set rmtwin {$i}"
      }
   }
   set radtxt [.sendmail.fr6.rad cget -text]
   set twin [string range $radtxt 12 [expr [string length $radtxt] - 1]]
   if {([string length $twin] > 0) && (![winfo exists .main$twin])} {
      set mtwin 0
      .sendmail.fr6.rad config -text "Main window"
   }
   set radtxt [.sendmail.fr7.rad cget -text]
   set twin [string range $radtxt 22 [expr [string length $radtxt] - 1]]
   if {([string length $twin] > 0) && (![winfo exists .roman$twin])} {
      set rmtwin 0
      .sendmail.fr7.rad config -text "Transliterator window"
   }
}

set ttargetWin "0"
proc refreshTargetWinList { } {
   global mavail ravail ttargetWin

   for {set i 1} {$i < $ravail} {incr i 1} {
      if {[winfo exists .roman$i]} {
         .roman$i.cmdfr.transfer.m.m delete 0 last
         for {set j 1} {$j <= $mavail} {incr j 1} {
            if {[winfo exists .main$j]} {
               .roman$i.cmdfr.transfer.m.m add radio -label "Main window $j" -variable ttargetWin -value "$j"
            }
         }
      }
   }
}

########################     End of refresh.tcl    ##########################

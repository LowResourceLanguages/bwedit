############################################################################
# goto.tcl: Implements the `goto line number' functions
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

proc jumpToLine { wintype myid } {
   global lineno
   if {[winfo exists .$wintype$myid]} {
      tkTextSetCursor .$wintype$myid.mainfr.editfr.textarea $lineno.0
      if {![string compare $wintype "roman"]} { setbnstr $myid }
   }
}

proc showLine { wintype myid } {
   global lineno
   if {[winfo exists .$wintype$myid]} {
      set lineno [.$wintype$myid.mainfr.editfr.textarea index insert]
      set dotidx [string first "." $lineno]
      set lineno [string range $lineno 0 [expr $dotidx - 1]]
   }
}

proc gotoLine { myid {wintype main} } {
   global appbg appfg btnbg btnfg hdrfont dpyfont
   global lineno gotook

   if {[winfo exists .gotowin]} {
      if {![string compare $wintype "main"]} {
         .gotowin.h config -text "Goto line in main window $myid"
      } else {
         .gotowin.h config -text "Goto line in transliterator window $myid"
      }
      .gotowin.f.g config -command "jumpToLine $wintype $myid"
      .gotowin.f.c config -command "showLine $wintype $myid"
      return
   }
   set gwin [toplevel .gotowin]
   $gwin config -bg $appbg
   label $gwin.h -font $hdrfont -relief flat -fg $appfg -bg $appbg \
      -text "Goto line in transliterator window $myid"
   if {![string compare $wintype "main"]} {
      $gwin.h config -text "Goto line in main window $myid"
   }
   frame $gwin.f -relief flat -bg $appbg
   entry $gwin.f.e -textvariable lineno -bg #ddddaa -fg #000000 -width 50 \
      -selectforeground #ddddaa -selectbackground #000000 -selectborderwidth 0 \
      -width 10
   button $gwin.f.g -text "Go to" -relief raised -command "
      jumpToLine $wintype $myid
   " -fg $btnfg -bg $btnbg -activeforeground $btnfg -activebackground $btnbg \
   -underline 0
   button $gwin.f.c -text "Current" -relief raised -command "
      showLine $wintype $myid
   " -fg $btnfg -bg $btnbg -activeforeground $btnfg -activebackground $btnbg \
   -underline 0
   button $gwin.f.d -text "Dismiss" -relief raised -command {
      set gotook 1
   } -fg $btnfg -bg $btnbg -activeforeground $btnfg -activebackground $btnbg \
   -underline 0
   pack $gwin.f.e -side left -expand yes -fill x
   pack $gwin.f.e $gwin.f.g $gwin.f.c $gwin.f.d -side left -expand no -padx 2
   pack $gwin.h $gwin.f -padx 5 -pady 5 -fill both -expand yes

   bind $gwin <Alt-c> ".gotowin.f.c invoke"
   bind $gwin <Alt-d> ".gotowin.f.d invoke"
   bind $gwin <Alt-g> ".gotowin.f.g invoke"
   bind $gwin <Alt-C> ".gotowin.f.c invoke"
   bind $gwin <Alt-D> ".gotowin.f.d invoke"
   bind $gwin <Alt-G> ".gotowin.f.g invoke"
   bind $gwin <Escape> ".gotowin.f.d invoke"
   wm resizable $gwin false false
   wm title $gwin "bwedit: goto line"
   focus $gwin.f.e
   tkwait variable gotook
   destroy .gotowin
}

########################     End of goto.tcl    ##########################

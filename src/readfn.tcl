############################################################################
# readfn.tcl: Implements the read-file-name dialog box
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

set browsedir [exec pwd]
proc browse { win {ent .getfname.ent} } {
   global browsedir

   $win delete 0 end
   if [regexp {/\.\.$} $browsedir] {
      set browsedir [string range $browsedir 0 [expr [string length $browsedir] - 4]]
      set browsedir [string range $browsedir 0 [expr [string last "/" $browsedir] - 1]]
   }
   if {[string compare $browsedir ""] == 0} {
      foreach f [exec ls -a "/"] {
         if {[regexp {^\.$} $f] == 0} {
            if [file isdirectory /$f] {
               $win insert end /$f/
            } else {
               $win insert end /$f
            }
         }
      }
   } else {
      foreach f [exec ls -a $browsedir] {
         if {[regexp {^\.$} $f] == 0} {
            if [file isdirectory $browsedir/$f] {
               $win insert end $browsedir/$f/
            } else {
               $win insert end $browsedir/$f
            }
         }
      }
   }
   tkEntrySetCursor $ent end
}

proc getFileName { wtitle } {
   global appbg appfg btnbg btnfg browsedir newnewfname newfname gfndbox gfnok

   set gfnok 0
   set gfndbox [toplevel .getfname]
   label $gfndbox.lbl -text "Enter filename: " -relief flat -fg $appfg -bg $appbg
   entry $gfndbox.ent -textvariable newfname -bg #88ddff -fg #000000 \
      -selectforeground #88ddff -selectbackground #000000 -selectborderwidth 0
   button $gfndbox.obtn -text "OK" -command {
      set newfname [string trim $newfname]
      if {![string compare $newfname ""]} {
         set gfnok 0
      } else {
         set newnewfname [glob -nocomplain $newfname]
         if {[string compare $newnewfname ""]} {
            set newfname $newnewfname
         }
         if [file isdirectory $newfname] {
            set browsedir $newfname
            browse $gfndbox.brfr.lbx
         } else {
            set gfnok 1
         }
      }
   } -fg $btnfg -bg $btnbg -activeforeground $btnfg -activebackground $btnbg
   label $gfndbox.space -text "" -fg $appfg -bg $appbg
   button $gfndbox.cbtn -text "Cancel" -command "set gfnok 0" -fg $btnfg -bg $btnbg \
      -activeforeground $btnfg -activebackground $btnbg
   frame $gfndbox.brfr -bg $appbg
   listbox $gfndbox.brfr.lbx -width 60 -height 12 -bg #88ddff -fg $btnfg \
      -xscroll "$gfndbox.xscr set" -yscr "$gfndbox.brfr.yscr set" -relief sunken \
      -selectmode single -selectforeground #88ddff -selectbackground $btnfg \
      -selectborderwidth 0
   scrollbar $gfndbox.brfr.yscr -command "$gfndbox.brfr.lbx yview" \
      -troughcolor #88ddff -orient vertical -bg $appbg -width 12 \
      -activebackground $appbg
   scrollbar $gfndbox.xscr -command "$gfndbox.brfr.lbx xview" \
      -troughcolor #88ddff -orient horizontal -bg $appbg -width 12 \
      -activebackground $appbg
   bind $gfndbox.ent <Return> {
      set newfname [string trim $newfname]
      if {![string compare $newfname ""]} {
         set gfnok 0
      } else {
         set newnewfname [glob -nocomplain $newfname]
         if {[string compare $newnewfname ""]} {
            set newfname $newnewfname
         }
         if [file isdirectory $newfname] {
            set browsedir $newfname
            browse $gfndbox.brfr.lbx
         } else {
            set gfnok 1
         }
      }
   }
   bind $gfndbox <Escape> "set gfnok 0"
   bind $gfndbox.brfr.lbx <ButtonRelease-1> {
      foreach si [$gfndbox.brfr.lbx curselection] {
         set f [$gfndbox.brfr.lbx get $si]
         if {![file isdirectory $f]} { set newfname $f }
      }
   }
   bind $gfndbox.brfr.lbx <Double-Button-1> {
      foreach si [$gfndbox.brfr.lbx curselection] {
         set newfname [$gfndbox.brfr.lbx get $si]
         if [file isdirectory $newfname] {
            set browsedir [string range $f 0 [expr [string length $f] - 2]]
            browse $gfndbox.brfr.lbx
         } else {
            set gfnok 1
         }
      }
   }

   pack $gfndbox.lbl -padx 10 -pady 5
   pack $gfndbox.ent -padx 10 -pady 5 -fill x
   pack $gfndbox.brfr.yscr $gfndbox.brfr.lbx -side right -padx 0 -pady 0 -fill y
   pack $gfndbox.brfr -padx 10 -pady 0
   pack $gfndbox.xscr -padx 10 -pady 0 -fill x
   pack $gfndbox.obtn -padx 10 -pady 5 -side left
   pack $gfndbox.space -padx 10 -pady 5 -expand yes -fill x -side left
   pack $gfndbox.cbtn -padx 10 -pady 5
   $gfndbox config -bg $appbg

   wm title $gfndbox "$wtitle"
   wm resizable $gfndbox false false
   if {![file readable $browsedir]} { set browsedir [exec pwd] }
   browse $gfndbox.brfr.lbx

   focus $gfndbox.ent
   grab $gfndbox
   tkwait variable gfnok
   grab release $gfndbox
   destroy $gfndbox

   if {$gfnok} { return [string trim $newfname] } else { return "" }
}

########################     End of readfn.tcl    ##########################

############################################################################
# search.tcl: Implements the search and replace functions
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

proc searchExpr { myid {wintype main} } {
   global appbg appfg btnbg btnfg hdrfont dpyfont dirtybit newTclTk
   global srchdirn srchcase findok sstring rstring lsidx sasciimode sascin rasciimode rascin

   if {[winfo exists .find]} {return}

   set sstring ""
   set rstring ""
   set findwin [toplevel .find]
   .find config -bg $appbg
   label .find.h -font $hdrfont -relief flat -fg $appfg -bg $appbg \
      -text "Search in transliterator window $myid"
   if {![string compare $wintype "main"]} {
      .find.h config -text "Search in main window $myid"
   }
   frame .find.s -bg $appbg -relief flat
   label .find.s.l -font $dpyfont -relief flat -fg $appfg -bg $appbg \
      -text "Search string  " -anchor e
   entry .find.s.e -textvariable sstring -bg #ddddaa -fg #000000 \
      -selectforeground #ddddaa -selectbackground #000000 -selectborderwidth 0
   if {![string compare $wintype "main"]} {
      if {($newTclTk)} {
         .find.s.e config -font "-*-bengali2-medium-r-*-*-*-120-*-*-*-*-iso10646-1" -width 40
      } else {
         .find.s.e config -font "-*-bengali-medium-r-*-*-*-120-*-*-*-*-*-fontspecific" -width 40
      }
   }
   .find.s.e config -width 60
   frame .find.r -bg $appbg -relief flat
   label .find.r.l -font $dpyfont -relief flat -fg $appfg -bg $appbg \
      -text "Replace string  " -anchor e
   entry .find.r.e -textvariable rstring -bg #ddddaa -fg #000000 \
      -selectforeground #ddddaa -selectbackground #000000 -selectborderwidth 0
   if {![string compare $wintype "main"]} {
      if {($newTclTk)} {
         .find.r.e config -font "-*-bengali2-medium-r-*-*-*-120-*-*-*-*-iso10646-1" -width 40
      } else {
         .find.r.e config -font "-*-bengali-medium-r-*-*-*-120-*-*-*-*-*-fontspecific" -width 40
      }
   }
   .find.r.e config -width 60
   frame .find.c -bg $appbg -relief flat
   checkbutton .find.c.b -text " Search backward " -relief ridge \
      -onvalue "-back" -offvalue "-forw" -variable "srchdirn" \
      -selectcolor #bbff00 -fg $appfg -bg $appbg \
      -activeforeground $appfg -activebackground $appbg
   set srchdirn "-forw"
   checkbutton .find.c.c -text " Case sensitive " -relief ridge \
      -onvalue "1" -offvalue "0" -variable "srchcase" \
      -selectcolor #bbff00 -fg $appfg -bg $appbg \
      -activeforeground $appfg -activebackground $appbg
   set srchcase 1
   frame .find.b -bg $appbg -relief flat
   button .find.b.l -text "Clear" -relief raised -command {
         set sstring ""
         set rstring ""
      } -fg $btnfg -bg $btnbg -activeforeground $btnfg -activebackground $btnbg \
      -underline 1
   button .find.b.s -text "Search" -relief raised -command "doSearch $myid $wintype" \
      -fg $btnfg -bg $btnbg -activeforeground $btnfg -activebackground $btnbg \
      -underline 0
   button .find.b.r -text "Replace" -relief raised -command "doReplace $myid $wintype" \
      -fg $btnfg -bg $btnbg -activeforeground $btnfg -activebackground $btnbg \
      -underline 0
   button .find.b.g -text "Replace all" -relief raised -command "doGlobalReplace $myid $wintype" \
      -fg $btnfg -bg $btnbg -activeforeground $btnfg -activebackground $btnbg \
      -underline 8
   button .find.b.c -text "Close" -relief raised -command { set findok 1 } \
      -fg $btnfg -bg $btnbg -activeforeground $btnfg -activebackground $btnbg \
      -underline 0

   pack .find.h -padx 5 -pady 5 -expand yes -fill x
   pack .find.s.l -expand yes -fill x -anchor e -padx 0 -side left
   pack .find.s.e -expand no -padx 0 -side left
   pack .find.r.l -expand yes -fill x -anchor e -padx 0 -side left
   pack .find.r.e -expand no -padx 0 -side left
   pack .find.s .find.r -expand yes -fill x -padx 5 -pady 5
   pack .find.c.b -expand no -padx 10 -pady 0 -side left
   if {![string compare "roman" $wintype]} {
      pack .find.c.c -expand no -padx 10 -pady 0 -side left
   }
   pack .find.c -expand no -padx 5 -pady 5
   pack .find.b.l .find.b.s .find.b.r .find.b.g .find.b.c -padx 10 -pady 0 -side left
   pack .find.b -expand no -padx 5 -pady 5

   set lsidx ""

   bind $findwin <Alt-A> {.find.b.g invoke}
   bind $findwin <Alt-C> {.find.b.c invoke}
   bind $findwin <Alt-L> {.find.b.l invoke}
   bind $findwin <Alt-R> {.find.b.r invoke}
   bind $findwin <Alt-S> {.find.b.s invoke}
   bind $findwin <Alt-a> {.find.b.g invoke}
   bind $findwin <Alt-c> {.find.b.c invoke}
   bind $findwin <Alt-l> {.find.b.l invoke}
   bind $findwin <Alt-r> {.find.b.r invoke}
   bind $findwin <Alt-s> {.find.b.s invoke}
   bind .find.s.e <Return> {focus .find.r.e}
   bind .find.r.e <Return> {focus .find.s.e}

   if {![string compare $wintype "main"]} {
      if {($newTclTk)} {
         bind .find.s.e <Control-a> ".find.s.e insert insert [encfrom a]; break"
         bind .find.s.e <Control-A> ".find.s.e insert insert [encfrom aA]; break"
         bind .find.s.e <Control-i> ".find.s.e insert insert [encfrom [format %c 1]]; break"
         bind .find.s.e <Control-I> ".find.s.e insert insert [encfrom [format %c 2]]; break"
         bind .find.s.e <Control-u> ".find.s.e insert insert [encfrom [format %c 3]]; break"
         bind .find.s.e <Control-U> ".find.s.e insert insert [encfrom [format %c 4]]; break"
         bind .find.s.e <Control-R> ".find.s.e insert insert [encfrom [format %c 5]]; break"
         bind .find.s.e <Control-e> ".find.s.e insert insert [encfrom [format %c 6]]; break"
         bind .find.s.e <Control-E> ".find.s.e insert insert [encfrom [format %c 7]]; break"
         bind .find.s.e <Control-o> ".find.s.e insert insert [encfrom [format %c 8]]; break"
         bind .find.s.e <Control-O> ".find.s.e insert insert [encfrom o]; break"
         bind .find.s.e <Control-y> ".find.s.e insert insert [encfrom [format %c 14]]; break"
         bind .find.s.e <Control-r> ".find.s.e insert insert [encfrom [format %c 15]]; break"

         bind .find.r.e <Control-a> ".find.r.e insert insert [encfrom a]; break"
         bind .find.r.e <Control-A> ".find.r.e insert insert [encfrom aA]; break"
         bind .find.r.e <Control-i> ".find.r.e insert insert [encfrom [format %c 1]]; break"
         bind .find.r.e <Control-I> ".find.r.e insert insert [encfrom [format %c 2]]; break"
         bind .find.r.e <Control-u> ".find.r.e insert insert [encfrom [format %c 3]]; break"
         bind .find.r.e <Control-U> ".find.r.e insert insert [encfrom [format %c 4]]; break"
         bind .find.r.e <Control-R> ".find.r.e insert insert [encfrom [format %c 5]]; break"
         bind .find.r.e <Control-e> ".find.r.e insert insert [encfrom [format %c 6]]; break"
         bind .find.r.e <Control-E> ".find.r.e insert insert [encfrom [format %c 7]]; break"
         bind .find.r.e <Control-o> ".find.r.e insert insert [encfrom [format %c 8]]; break"
         bind .find.r.e <Control-O> ".find.r.e insert insert [encfrom o]; break"
         bind .find.r.e <Control-y> ".find.r.e insert insert [encfrom [format %c 14]]; break"
         bind .find.r.e <Control-r> ".find.r.e insert insert [encfrom [format %c 15]]; break"
      } else {
         bind .find.s.e <Control-a> ".find.s.e insert insert {a}; break"
         bind .find.s.e <Control-A> ".find.s.e insert insert {aA}; break"
         bind .find.s.e <Control-i> ".find.s.e insert insert [format %c 1]; break"
         bind .find.s.e <Control-I> ".find.s.e insert insert [format %c 2]; break"
         bind .find.s.e <Control-u> ".find.s.e insert insert [format %c 3]; break"
         bind .find.s.e <Control-U> ".find.s.e insert insert [format %c 4]; break"
         bind .find.s.e <Control-R> ".find.s.e insert insert [format %c 5]; break"
         bind .find.s.e <Control-e> ".find.s.e insert insert [format %c 6]; break"
         bind .find.s.e <Control-E> ".find.s.e insert insert [format %c 7]; break"
         bind .find.s.e <Control-o> ".find.s.e insert insert [format %c 8]; break"
         bind .find.s.e <Control-O> ".find.s.e insert insert {o}; break"
         bind .find.s.e <Control-y> ".find.s.e insert insert [format %c 14]; break"
         bind .find.s.e <Control-r> ".find.s.e insert insert [format %c 15]; break"

         bind .find.r.e <Control-a> ".find.r.e insert insert {a}; break"
         bind .find.r.e <Control-A> ".find.r.e insert insert {aA}; break"
         bind .find.r.e <Control-i> ".find.r.e insert insert [format %c 1]; break"
         bind .find.r.e <Control-I> ".find.r.e insert insert [format %c 2]; break"
         bind .find.r.e <Control-u> ".find.r.e insert insert [format %c 3]; break"
         bind .find.r.e <Control-U> ".find.r.e insert insert [format %c 4]; break"
         bind .find.r.e <Control-R> ".find.r.e insert insert [format %c 5]; break"
         bind .find.r.e <Control-e> ".find.r.e insert insert [format %c 6]; break"
         bind .find.r.e <Control-E> ".find.r.e insert insert [format %c 7]; break"
         bind .find.r.e <Control-o> ".find.r.e insert insert [format %c 8]; break"
         bind .find.r.e <Control-O> ".find.r.e insert insert {o}; break"
         bind .find.r.e <Control-y> ".find.r.e insert insert [format %c 14]; break"
         bind .find.r.e <Control-r> ".find.r.e insert insert [format %c 15]; break"
      }

      set sasciimode 0
      set sascin ""
      for {set i 0} {$i < 10} {incr i 1} {
         bind .find.s.e <Key-$i> {
            if {$sasciimode} {set sascin "${sascin}%A"; break }
         }
      }
      bind .find.s.e <Escape> {sprocEsc}
      bind .find.s.e <Any-Key> {
         if {$sasciimode} {set sasciimode 0; set sascin ""}
         if {($newTclTk) && ([string compare %A " "] >= 0) && ([string compare %A "~"] <= 0)} {
            .find.s.e insert insert [encfrom %A]
            break
         }
      }

      set rasciimode 0
      set rascin ""
      for {set i 0} {$i < 10} {incr i 1} {
         bind .find.r.e <Key-$i> {
            if {$rasciimode} {set rascin "${rascin}%A"; break }
         }
      }
      bind .find.r.e <Escape> {rprocEsc}
      bind .find.r.e <Any-Key> {
         if {$rasciimode} {set rasciimode 0; set rascin ""}
         if {($newTclTk) && ([string compare %A " "] >= 0) && ([string compare %A "~"] <= 0)} {
            .find.r.e insert insert [encfrom %A]
            break
         }
      }
   }

   wm resizable $findwin false false
   wm title $findwin "bwedit: search"
   focus .find.s.e

   grab $findwin
   tkwait variable findok
   grab release $findwin
   destroy $findwin
}

proc sprocEsc { } {
   global sasciimode sascin newTclTk

   if {($sasciimode == 1) && ([string length $sascin] > 0)} {
      if {($newTclTk)} {
         .find.s.e insert insert [encfrom [format "%c" $sascin]]
      } else {
         .find.s.e insert insert [format "%c" $sascin]
      }
      set sascin ""
   }
   set sasciimode [expr 1 - $sasciimode]
}

proc rprocEsc { } {
   global rasciimode rascin newTclTk

   if {($rasciimode == 1) && ([string length $rascin] > 0)} {
      if {($newTclTk)} {
         .find.r.e insert insert [encfrom [format "%c" $rascin]]
      } else {
         .find.r.e insert insert [format "%c" $rascin]
      }
      set rascin ""
   }
   set rasciimode [expr 1 - $rasciimode]
}

proc doSearch { myid wintype } {
   global sstring rstring lsidx lsnum srchdirn srchcase

   if {[string length $sstring] == 0} {return}
   if {[string length $lsidx] == 0} {
      set lsidx "1.0"
   } elseif {![string compare $srchdirn "-forw"]} {
      set lsidx [.$wintype$myid.mainfr.editfr.textarea index "$lsidx + 1 char"]
   } else {
      set lsidx [.$wintype$myid.mainfr.editfr.textarea index "$lsidx"]
   }
   if {$srchcase} {
      set lsidx [.$wintype$myid.mainfr.editfr.textarea search $srchdirn $sstring $lsidx]
   } else {
      set lsidx [.$wintype$myid.mainfr.editfr.textarea search $srchdirn -nocase $sstring $lsidx]
   }
   if {[string length $lsidx] != 0} {
      tkTextSetCursor .$wintype$myid.mainfr.editfr.textarea $lsidx
      if {![string compare $wintype "roman"]} { setbnstr $myid }
      .$wintype$myid.mainfr.editfr.textarea tag remove sel 1.0 end
      .$wintype$myid.mainfr.editfr.textarea tag add sel $lsidx "$lsidx + [string length $sstring] chars"
      .$wintype$myid.mainfr.editfr.textarea see $lsidx
   } else {
      if {![string compare $wintype "main"]} {
         errmsg $myid "     Search failed     "
      } else {
         errmsg2 $myid "     Search failed     "
      }
      grab .find
   }
}

proc doReplace { myid wintype } {
   global sstring rstring lsidx lsnum srchdirn srchcase dirtybit rdirtybit

   if {[string length $sstring] == 0} {return}
   if {[string length $lsidx] == 0} {
      set lsidx "1.0"
   } elseif {![string compare $srchdirn "-forw"]} {
      set lsidx [.$wintype$myid.mainfr.editfr.textarea index "$lsidx + 1 char"]
   } else {
      set lsidx [.$wintype$myid.mainfr.editfr.textarea index "$lsidx"]
   }
   if {$srchcase} {
      set lsidx [.$wintype$myid.mainfr.editfr.textarea search $srchdirn $sstring $lsidx]
   } else {
      set lsidx [.$wintype$myid.mainfr.editfr.textarea search $srchdirn -nocase $sstring $lsidx]
   }
   if {[string length $lsidx] != 0} {
      tkTextSetCursor .$wintype$myid.mainfr.editfr.textarea $lsidx
      .$wintype$myid.mainfr.editfr.textarea tag remove sel 1.0 end
      .$wintype$myid.mainfr.editfr.textarea delete $lsidx "$lsidx + [string length $sstring] chars"
      .$wintype$myid.mainfr.editfr.textarea insert $lsidx $rstring
      .$wintype$myid.mainfr.editfr.textarea tag add sel $lsidx "$lsidx + [string length $rstring] chars"
      .$wintype$myid.mainfr.editfr.textarea see $lsidx
      if {![string compare $wintype "main"]} {
         incr dirtybit($myid)
      } else {
         setbnstr $myid
         incr rdirtybit($myid)
      }
   } else {
      if {![string compare $wintype "main"]} {
         errmsg $myid "     Search failed     "
      } else {
         errmsg2 $myid "     Search failed     "
      }
      grab .find
   }
}

proc doGlobalReplace { myid wintype } {
   global sstring rstring lsidx lsnum srchcase dirtybit rdirtybit

   if {[string length $sstring] == 0} {return}
   set lsidx 1.0
   set nrepl 0
   .$wintype$myid.mainfr.editfr.textarea tag remove sel 1.0 end
   while {[string length $lsidx] > 0} {
      if {$srchcase} {
         set lsidx [.$wintype$myid.mainfr.editfr.textarea search $sstring $lsidx end]
      } else {
         set lsidx [.$wintype$myid.mainfr.editfr.textarea search -nocase $sstring $lsidx end]
      }
      if {[string length $lsidx] > 0} {
         .$wintype$myid.mainfr.editfr.textarea delete $lsidx "$lsidx + [string length $sstring] chars"
         .$wintype$myid.mainfr.editfr.textarea insert $lsidx $rstring
         .$wintype$myid.mainfr.editfr.textarea tag add sel $lsidx "$lsidx + [string length $rstring] chars"
         set lsidx [.$wintype$myid.mainfr.editfr.textarea index "$lsidx + [string length $rstring] chars"]
         incr nrepl
      }
   }

   if {![string compare $wintype "main"]} {
      incr dirtybit($myid) $nrepl
   } else {
      incr rdirtybit($myid) $nrepl
   }

   if {![string compare $wintype "main"]} {
      errmsg $myid "   $nrepl replacements done   "
   } else {
      setbnstr $myid
      errmsg2 $myid "   $nrepl replacements done   "
   }
   grab .find
}

########################     End of search.tcl    ##########################

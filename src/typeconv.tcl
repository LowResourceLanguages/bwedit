############################################################################
# typeconv.tcl: Routines for converting text among different formats
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

proc readEnc { { flag 0 } { fnm "" } } {
   global encmap invencmap installdir

   if {$flag == 0} {
      set encfname "$installdir/lib/bn.enc"
   } elseif {$flag == 1} {
      set encfname [getFileName "bwedit: Encoding file"]
   } else {
      set encfname $fnm
   }
   if {[string length $encfname] == 0} { return }
   if {![file readable "$encfname"]} {
      puts "ERROR: I cannot read the encoding file."
      puts "The file $encfname"
      puts "does not exist or does not have read permission."
      puts "This means that you cannot use the Roman-to-Bengali transliterator."
      return
   }

   if [info exists encmap] { unset encmap }
   if [info exists invencmap] { unset invencmap }

   set encmap(VowelAlphabet) "aAeEiILoORuU"
   set encmap(ConsonantAlphabet) "bBcCdDfFgGhHjJkKlmMnNpPqQrsStTvVwWxXyYZ^"
   set encmap(SyllableSeparator) "_"
   set encmap(HasantaCode) "__"
   set encmap(RefCode) "^r,r"
   set encmap(RafalaCode) "^r,r"
   set encmap(JafalaCode) "^y,y"
   set encmap(ChandrabinduCode) "^"

   set encf [open "$encfname" r]
   while {[gets $encf line] >= 0} {
      set idx [ string first "#" $line ]
      if {$idx >= 0} { set line [string range $line 0 [expr $idx - 1]] }
      set idx [ string first ":" $line ]
      if {$idx >= 0} {
         set code [string range $line 0 [expr $idx - 1]]
         set char [string range $line [expr $idx + 1] [expr [string length $line] - 1]]
         set code [string trim $code]
         set char [string trim $char]
         if {([string length $code] > 0) && ([string length $char] > 0)} {
            if {![string compare $code "VowelAlphabet"]} {
               set encmap(VowelAlphabet) $char
            } elseif {![string compare $code "ConsonantAlphabet"]} {
               set encmap(ConsonantAlphabet) $char
            } elseif {![string compare $code "SyllableSeparator"]} {
               set encmap(SyllableSeparator) $char
            } elseif {![string compare $code "HasantaCode"]} {
               set encmap($char) 95
            } elseif {![string compare $code "RefCode"]} {
               set encmap(RefCode) $char
            } elseif {![string compare $code "RafalaCode"]} {
               set encmap(RafalaCode) $char
            } elseif {![string compare $code "JafalaCode"]} {
               set encmap(JafalaCode) $char
            } elseif {![string compare $code "ChandrabinduCode"]} {
               set encmap(ChandrabinduCode) $char
            } else {
               if {![string compare "\\" [string index $char 0]]} {
                  set ascval [string range $char 1 [expr [string length $char] - 1]]
               } else {
                  scan $char "%c" ascval
               }
               set encmap($code) $ascval
               set invencmap($ascval) $code
            }
         }
      }
   }
   set codeList [split $encmap(RefCode) ","]
   for {set i 0} {$i < [llength $codeList]} {incr i 1} {
      set encmap(ref$i) [lindex $codeList $i]
   }
   set codeList [split $encmap(RafalaCode) ","]
   for {set i 0} {$i < [llength $codeList]} {incr i 1} {
      set encmap(rafala$i) [lindex $codeList $i]
   }
   set codeList [split $encmap(JafalaCode) ","]
   for {set i 0} {$i < [llength $codeList]} {incr i 1} {
      set encmap(jafala$i) [lindex $codeList $i]
   }
   set codeList [split $encmap(ChandrabinduCode) ","]
   for {set i 0} {$i < [llength $codeList]} {incr i 1} {
      set encmap(chandra$i) [lindex $codeList $i]
   }
   unset encmap(RefCode)
   unset encmap(RafalaCode)
   unset encmap(JafalaCode)
   unset encmap(ChandrabinduCode)
}

proc vowel { c } {
   global encmap
   if {[string first $c $encmap(VowelAlphabet)] >= 0} { return 1 } else { return 0 }
}

proc consonant { c } {
   global encmap
   if {[string first $c $encmap(ConsonantAlphabet)] >= 0} { return 1 } else { return 0 }
}

proc isPrefix { str substr } {
   set slen [string length $str]
   set sslen [string length $substr]
   if {$sslen > $slen} { return 0 }
   set pfxstr [string range $str 0 [expr $sslen - 1]]
   if {![string compare $pfxstr $substr]} { return 1 }
   return 0
}

proc isSuffix { str substr } {
   set slen [string length $str]
   set sslen [string length $substr]
   if {$sslen > $slen} { return 0 }
   set sfxstr [string range $str [expr $slen - $sslen] [expr $slen - 1]]
   if {![string compare $sfxstr $substr]} { return 1 }
   return 0
}

proc romanToBeng { txt tarea {cursor "insert"} } {
   global encmap newTclTk

   set bngmode 1
   set idx 0
   set iplen [string length $txt]
   if {$iplen > 0} { set nextchar [string index $txt 0] }
   while {$idx < $iplen} {
      if {($bngmode == 0)} {
         if {![string compare $nextchar "#"]} {
            if {($idx <= $iplen - 2) && (![string compare "#" [string index $txt [expr $idx + 1]]])} {
               incr idx
               $tarea insert $cursor "#" english
            } else {
               set bngmode 1
            }
         } elseif {![string compare $nextchar "\n"]} {
            set bngmode 1
            $tarea insert $cursor "\n"
         } else {
            $tarea insert $cursor $nextchar english
         }
         incr idx 1
         if {$idx < $iplen} { set nextchar [string index $txt $idx] } else { set nextchar "" }
      } else {
         set bntxt ""
         if {[vowel $nextchar]} {
            set swar ""
            while {[vowel $nextchar] && ($idx < $iplen)} {
               set swar $swar$nextchar
               incr idx 1
               if {$idx < $iplen} { set nextchar [string index $txt $idx] } else { set nextchar "" }
            }
            if [info exists encmap($swar)] {
               switch -exact $encmap($swar) {
                  97 { set bntxt "a" }
                  65 { set bntxt "aA" }
                   1 { set bntxt [format "%c" 1] }
                 105 { set bntxt [format "%c" 1] }
                   2 { set bntxt [format "%c" 2] }
                  73 { set bntxt [format "%c" 2] }
                   3 { set bntxt [format "%c" 3] }
                 117 { set bntxt [format "%c" 3] }
                   4 { set bntxt [format "%c" 4] }
                  85 { set bntxt [format "%c" 4] }
                   5 { set bntxt [format "%c" 5] }
                  87 { set bntxt [format "%c" 5] }
                   6 { set bntxt [format "%c" 6] }
                 101 { set bntxt [format "%c" 6] }
                   7 { set bntxt [format "%c" 7] }
                  69 { set bntxt [format "%c" 7] }
                   8 { set bntxt [format "%c" 8] }
                  79 { set bntxt "o" }
                 111 { set bntxt "o" }
                  14 { set bntxt a[format "%c" 14]A }
               }
            }
         } elseif {[consonant $nextchar]} {
            set swar ""
            set banjon ""
            while {[consonant $nextchar] && ($idx < $iplen)} {
               set banjon $banjon$nextchar
               incr idx 1
               if {$idx < $iplen} { set nextchar [string index $txt $idx] } else { set nextchar "" }
            }
            while {[vowel $nextchar] && ($idx < $iplen)} {
               set swar $swar$nextchar
               incr idx 1
               if {$idx < $iplen} { set nextchar [string index $txt $idx] } else { set nextchar "" }
            }
            if {[string length $swar] == 0} {
               set swar 97
            } elseif {[info exists encmap($swar)]} {
               set swar $encmap($swar)
            } else {
               set swar 97
            }
            set chandra ""
            set ref ""
            set jafala ""
            set rafala ""
            if {[info exists encmap($banjon)]} {
               set tban $encmap($banjon)
            } else {
               set tban -1
            }
            if {$tban < 0} {
               set done 0
               while {($tban < 0) && ($done == 0)} {
                  set done 1
                  for {set i 0} {($done == 1) && [info exists encmap(chandra$i)]} {incr i 1} {
                     set thiscode $encmap(chandra$i)
                     if {[isSuffix $banjon $thiscode]} {
                        set chandra "w"
                        set done 0
                        set banjon [string range $banjon 0 [expr [string length $banjon] - [string length $thiscode] - 1]]
                     }
                  }
                  for {set i 0} {($done == 1) && [info exists encmap(ref$i)]} {incr i 1} {
                     set thiscode $encmap(ref$i)
                     if {[isPrefix $banjon $thiscode]} {
                        set ref "^"
                        set done 0
                        set banjon [string range $banjon [string length $thiscode] [expr [string length $banjon] - 1]]
                     }
                  }
                  for {set i 0} {($done == 1) && [info exists encmap(rafala$i)]} {incr i 1} {
                     set thiscode $encmap(rafala$i)
                     if {[isSuffix $banjon $thiscode]} {
                        set rafala [format "%c" 15]
                        set done 0
                        set banjon [string range $banjon 0 [expr [string length $banjon] - [string length $thiscode] - 1]]
                     }
                  }
                  for {set i 0} {($done == 1) && [info exists encmap(jafala$i)]} {incr i 1} {
                     set thiscode $encmap(jafala$i)
                     if {[isSuffix $banjon $thiscode]} {
                        set jafala [format "%c" 14]
                        set done 0
                        set banjon [string range $banjon 0 [expr [string length $banjon] - [string length $thiscode] - 1]]
                     }
                  }
                  if {[info exists encmap($banjon)]} {
                     set tban $encmap($banjon)
                  }
               }
            }
            if {(($swar == 3) || ($swar == 117)) && ($tban != -1) && ![string compare $jafala ""] && ![string compare $rafala ""]} {
               switch -exact $tban {
                  114 { set tban 25 ; set swar 97 }
                  104 { set tban 27 ; set swar 97 }
                  103 { set tban 29 ; set swar 97 }
                   83 { set tban 30 ; set swar 97 }
                  192 { set tban 193 ; set swar 97 }
                  226 { set tban 227 ; set swar 97 }
                  253 { set tban 254 ; set swar 97 }
               }
            }
            if {(($swar == 4) || ($swar == 85)) && ($tban == 114) && ![string compare $jafala ""] && ![string compare $rafala ""]} {
               set tban 26
               set swar 97
            }
            if {(($swar == 5) || ($swar == 87)) && ($tban == 104) && ![string compare $jafala ""] && ![string compare $rafala ""]} {
               set tban 28
               set swar 97
            }
            if {($tban == 121) && [string compare $ref ""]} {
               set tban 114
               set ref ""
               set jafala [format "%c" 14]
            }
            if {$tban < 0} {
               if {([string length $chandra] > 0) && ([string length $banjon] == 0)} {
                  set ban "w"
                  set swar 97
                  set chandra ""
               } else {
                  set ban " $ref$chandra$rafala$jafala"
               }
            } else {
               set ban "[format "%c" $tban]$ref$chandra$rafala$jafala"
            }
            switch -exact $swar {
               97 { set bntxt "$ban" }
               65 { set bntxt "${ban}A" }
                1 { set bntxt "i$ban" }
              105 { set bntxt "i$ban" }
                2 { set bntxt "${ban}I" }
               73 { set bntxt "${ban}I" }
                3 { set bntxt "${ban}u" }
              117 { set bntxt "${ban}u" }
                4 { set bntxt "${ban}U" }
               85 { set bntxt "${ban}U" }
                5 { set bntxt "${ban}W" }
               87 { set bntxt "${ban}W" }
                6 { set bntxt "e$ban" }
              101 { set bntxt "e$ban" }
                7 { set bntxt "E$ban" }
               69 { set bntxt "E$ban" }
                8 { set bntxt "e${ban}A" }
               79 { set bntxt "e${ban}O" }
              111 { set bntxt "e${ban}O" }
               14 { set bntxt "$ban[format "%c" 14]A" }
            }
         } else {
            if {![string compare $nextchar "#"]} {
               incr idx 1
               if {$idx < $iplen} { set nextnextchar [string index $txt $idx] } else { set nextnextchar "" }
               if {![string compare $nextnextchar "#"]} {
                  incr idx 1
                  set bntxt "#"
                  if {$idx < $iplen} { set nextchar [string index $txt $idx] } else { set nextchar "" }
               } else {
                  set nextchar $nextnextchar
                  set bngmode 0
               }
            } elseif {![string compare $nextchar "\n"]} {
               set bntxt "\n"
               incr idx 1
               set bngmode 1
               if {$idx < $iplen} { set nextchar [string index $txt $idx] } else { set nextchar "" }
            } else {
               incr idx 1
               set ligop ""
               if {($idx == $iplen)} {
                  set nextnextchar ""
               } else {
                  set nextnextchar [string index $txt $idx]
                  set ligip "$nextchar$nextnextchar"
                  if {[info exists encmap($ligip)]} {
                     set ligop [format "%c" $encmap($ligip)]
                  }
               }
               set bntxt ""
               if {![string compare $ligop ""]} {
                  if {[string compare $nextchar $encmap(SyllableSeparator)]} {
                     set bntxt $nextchar
                  }
                  set nextchar $nextnextchar
               } elseif {![string compare $ligop "_"]} {
                  set bntxt "_"
                  incr idx 1
                  if {($idx == $iplen)} {
                     set nextchar ""
                  } else {
                     set nextchar [string index $txt $idx]
                  }
               } else {
                  set nextchar $ligop
               }
            }
         }
         if ($newTclTk) {
            $tarea insert $cursor [encfrom $bntxt]
         } else {
            $tarea insert $cursor $bntxt
         }
      }
   }
}

proc importRoman { myid flag } {
   global dirtybit

   set mwin ".main$myid"

   set fn [getFileName "bwedit: Import Roman file"]
   if { [string compare $fn ""] != 0 } {
      if {![file readable $fn]} {
         errmsg $myid "ERROR:\nI cannot load the file \"$fn\". The file does not exist or does not have read permission."
         return
      }
      if {![file isfile $fn]} {
         errmsg $myid "ERROR:\nI cannot load the file. \"$fn\" is not a regular file."
         return
      }
      if {$flag == 0} { $mwin.mainfr.editfr.textarea delete 1.0 end }
      set f [open $fn r]
      set txt [read $f]
      close $f
      if {$flag == 2} {
         romanToBeng $txt $mwin.mainfr.editfr.textarea end
      } else {
         romanToBeng $txt $mwin.mainfr.editfr.textarea
      }
      $mwin.mainfr.editfr.textarea see insert
      incr dirtybit($myid) 1
   }
}

proc getExportFileName {} {
   global efname verbatim omithdr xfnok appbg appfg btnbg btnfg

   set entwidth [string length $efname]
   if {$entwidth < 25} { set entwidth 25 }
   set dbox [toplevel .export]
   frame $dbox.fr1
   frame $dbox.fr2
   frame $dbox.fr3
   frame $dbox.fr4
   label $dbox.fr1.lbl -text "Export to file:" -relief flat -anchor e -bg $appbg -fg $appfg
   entry $dbox.fr1.ent -textvariable efname -bg #ddaaaa -fg #000000 -width $entwidth
   label $dbox.fr2.lbl -text "Document title:" -relief flat -anchor e -bg $appbg -fg $appfg
   entry $dbox.fr2.ent -textvariable doctitle -bg #ddaaaa -fg #000000 -width $entwidth
   checkbutton $dbox.fr3.cb -text "  Verbatim copy " -variable verbatim -onvalue 1 -offvalue 0 \
      -relief raised -selectcolor #bbff00 -bg $appbg -fg $appfg -activebackground $appbg -activeforeground $appfg
   checkbutton $dbox.fr3.oh -text "  Omit headers " -variable omithdr -onvalue 1 -offvalue 0 \
      -relief raised -selectcolor #bbff00 -bg $appbg -fg $appfg -activebackground $appbg -activeforeground $appfg
   button $dbox.fr4.obtn -text "OK" -command {set xfnok 1} -width 6 -fg $btnfg -bg $btnbg -activebackground $btnbg -activeforeground $btnfg
   button $dbox.fr4.cbtn -text "Cancel" -command {set xfnok 0} -width 6 -fg $btnfg -bg $btnbg -activebackground $btnbg -activeforeground $btnfg
   label $dbox.fr4.space -text "" -relief flat -bg $appbg -fg $appfg
   bind $dbox.fr1.ent <Return> "focus $dbox.fr2.ent"
   bind $dbox.fr2.ent <Return> {set xfnok 1}
   bind $dbox <Escape> {set xfnok 0}

   pack $dbox.fr1 $dbox.fr2 $dbox.fr3 -expand yes -fill x
   pack $dbox.fr4 -expand yes -fill both
   pack $dbox.fr1.lbl -padx 5 -pady 5 -expand yes -fill x -side left
   pack $dbox.fr1.ent -padx 5 -pady 5
   pack $dbox.fr2.lbl -padx 5 -pady 5 -expand yes -fill x -side left
   pack $dbox.fr2.ent -padx 5 -pady 5
   pack $dbox.fr3.cb  -padx 5 -pady 5
   pack $dbox.fr3.oh  -padx 5 -pady 5
   pack $dbox.fr4.obtn -padx 5 -pady 5 -fill y -side left
   pack $dbox.fr4.space -padx 5 -pady 5 -expand yes -fill x -side left
   pack $dbox.fr4.cbtn -padx 5 -pady 5 -fill y
   $dbox config -bg $appbg
   $dbox.fr1 config -bg $appbg
   $dbox.fr2 config -bg $appbg
   $dbox.fr3 config -bg $appbg
   $dbox.fr4 config -bg $appbg

   tkEntrySetCursor $dbox.fr1.ent end

   wm title $dbox "bwedit: export"
   wm resizable $dbox false false

   focus $dbox.fr1.ent
   grab $dbox
   tkwait variable xfnok
   grab release $dbox
   destroy $dbox

   if {$xfnok} { return [string trim $efname] } else { return "" }
}

proc exportLaTeX { myid } {
   global fname efname verbatim omithdr doctitle customfontno ptsize slant newTclTk

   set mwin ".main$myid"

   if { [string compare $fname($myid) ""] != 0 } {
      set dotindex [string last "." $fname($myid)]
      incr dotindex -1
   } else {
      set dotindex -1
   }
   if {$dotindex >= 0} {
      set efname [string range $fname($myid) 0 $dotindex]
      set efname "$efname.tex"
   } else {
      set efname "$fname($myid).tex"
   }
   set verbatim 0
   set omithdr 0
   set doctitle ""
   set efn [getExportFileName]
   if { [string compare $efn ""] != 0 } {
      switch -exact $ptsize {
         100 { set bndft "\\bn\\small" ; set ss "\\bn\\tiny" ; set sss "\\bn\\tiny" }
         150 { set bndft "\\bn\\large" ; set ss "\\bn" ; set sss "\\bn\\small" }
         180 { set bndft "\\bn\\Large" ; set ss "\\bn\\large" ; set sss "\\bn" }
         210 { set bndft "\\bn\\LARGE" ; set ss "\\bn\\Large" ; set sss "\\bn\\large" }
         250 { set bndft "\\bn\\huge" ; set ss "\\bn\\LARGE" ; set sss "\\bn\\Large" }
         300 { set bndft "\\bn\\Huge" ; set ss "\\bn\\huge" ; set sss "\\bn\\LARGE" }
         360 { set bndft "\\bn\\Huge" ; set ss "\\bn\\huge" ; set sss "\\bn\\LARGE" }
         default {set bndft "\\bn" ; set ss "\\bn\\small" ; set sss "\\bn\\tiny" }
      }
      if {![string compare "o" $slant]} { set bndft "$bndft\\sl" }
      foreach tagname {suptag supsuptag subsuptag subtag subsubtag supsubtag english} {
         set ${tagname}rng [$mwin.mainfr.editfr.textarea tag ranges $tagname]
      }
      for {set i 0} {$i < $customfontno($myid)} {incr i 1} {
         set englishrng [concat $englishrng [$mwin.mainfr.editfr.textarea tag ranges customftag$i]]
      }
      set smallrng [$mwin.mainfr.editfr.textarea tag ranges bengali100r]
      set normalsizerng [$mwin.mainfr.editfr.textarea tag ranges bengali120r]
      set largerng [$mwin.mainfr.editfr.textarea tag ranges bengali150r]
      set Largerng [$mwin.mainfr.editfr.textarea tag ranges bengali180r]
      set LARGErng [$mwin.mainfr.editfr.textarea tag ranges bengali210r]
      set hugerng [$mwin.mainfr.editfr.textarea tag ranges bengali250r]
      set Hugerng [lsort -real -increasing [concat \
         [$mwin.mainfr.editfr.textarea tag ranges bengali300r] \
         [$mwin.mainfr.editfr.textarea tag ranges bengali360r]]]
      set smallslrng [$mwin.mainfr.editfr.textarea tag ranges bengali100o]
      set normalsizeslrng [$mwin.mainfr.editfr.textarea tag ranges bengali120o]
      set largeslrng [$mwin.mainfr.editfr.textarea tag ranges bengali150o]
      set Largeslrng [$mwin.mainfr.editfr.textarea tag ranges bengali180o]
      set LARGEslrng [$mwin.mainfr.editfr.textarea tag ranges bengali210o]
      set hugeslrng [$mwin.mainfr.editfr.textarea tag ranges bengali250o]
      set Hugeslrng [lsort -real -increasing [concat \
         [$mwin.mainfr.editfr.textarea tag ranges bengali300o] \
         [$mwin.mainfr.editfr.textarea tag ranges bengali360o]]]

      foreach scriptrng { \$suptagrng \$subtagrng \$supsuptagrng \$subsuptagrng \$subsubtagrng \$supsubtagrng } {
         set srlen [ eval llength $scriptrng ]
         if {$srlen > 0} {
            foreach tagrng { \$normalsizerng \$smallrng \$largerng \$Largerng \$LARGErng \$hugerng \$Hugerng \$englishrng \$normalsizeslrng \$smallslrng \$largeslrng \$Largeslrng \$LARGEslrng \$hugeslrng \$Hugeslrng } {
               set trlen [ eval llength $tagrng ]
               if {$trlen > 0} {
                  for {set i 0} {$i < $srlen} {incr i 2} {
                     for {set j 0} {$j < $trlen} {incr j 1} {
                        set si [eval lindex $scriptrng $i]
                        set ti1 [eval lindex $tagrng $j]
                        incr j 1
                        set ti2 [eval lindex $tagrng $j]
                        if { ($ti1 < $si) && ($ti2 > $si) } {
                           set [string range $tagrng 1 [expr [string length $tagrng] - 1]] [eval linsert $tagrng $j $si $si]
                           incr trlen 2
                        }
                     }
                  }
                  for {set i 1} {$i < $srlen} {incr i 2} {
                     for {set j 0} {$j < $trlen} {incr j 1} {
                        set si [eval lindex $scriptrng $i]
                        set ti1 [eval lindex $tagrng $j]
                        incr j 1
                        set ti2 [eval lindex $tagrng $j]
                        if { ($ti1 < $si) && ($ti2 > $si) } {
                           set [string range $tagrng 1 [expr [string length $tagrng] - 1]] [eval linsert $tagrng $j $si $si]
                           incr trlen 2
                        }
                     }
                  }
               }
            }
         }
      }

      set f [open $efn w]
      puts $f "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
      puts $f "%% Filename: $efname"
      puts $f "%% Original file: $fname($myid)"
      puts $f "%% Exported by: bwedit version 3.0"
      puts $f "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
      if {$omithdr == 0} {
         puts $f "\\documentstyle\[11pt,bengali\]\{article\}"
         puts $f "\\parindent 0pt"
         puts $f "\\parskip 10pt"
         puts $f "\\hbadness 10000"
         if { [string compare $doctitle ""] != 0 } {
            puts $f "\\pagestyle\{myheadings\}"
            puts $f "\\markboth\{$doctitle\}\{$doctitle\}"
         }
         puts $f "\\begin\{document\}"
      }
      puts $f "\\begingroup$bndft\\leavevmode"
      if {($newTclTk)} {
         set ins [encto [$mwin.mainfr.editfr.textarea get 1.0 end]]
      } else {
         set ins [$mwin.mainfr.editfr.textarea get 1.0 end]
      }
      set inl [string length $ins]
      set lineno 1
      set charno 0
      set englishmode 0
      set tagshere {}
      for {set i 0} {$i < $inl} {incr i 1} {
         if {[lsearch -regexp $tagshere "bengali"] >= 0} {
            foreach tagname { \$normalsizerng \$smallrng \$largerng \$Largerng \$LARGErng \$hugerng \$Hugerng \$normalsizeslrng \$smallslrng \$largeslrng \$Largeslrng \$LARGEslrng \$hugeslrng \$Hugeslrng } {
               set ridx [eval lsearch -exact $tagname $lineno.$charno]
               if { ($ridx >= 0) && ($ridx & 1) } { puts -nonewline $f "\}" }
            }
         }
         set ridx [lsearch -exact $englishrng $lineno.$charno]
         if { ($ridx >= 0) && ($ridx & 1) } {
            puts -nonewline $f "\}"
            incr englishmode -1
         }
         set suidx [lsearch -regexp $tagshere "su"]
         if {$suidx >= 0} {
            set tagname [lindex $tagshere $suidx]
            set ridx [eval lsearch -exact \$${tagname}rng $lineno.$charno]
            if { ($ridx >= 0) && ($ridx & 1) } {
               if {[string length $tagname] == 6} {
                  puts -nonewline $f "\}\}\$"
               } else {
                  puts -nonewline $f "\}\}\}\$"
               }
            }
         }
         set tagshere [$mwin.mainfr.editfr.textarea tag names "$lineno.$charno"]
         set suidx [lsearch -regexp $tagshere "su"]
         if {$suidx >= 0} {
            set tagname [lindex $tagshere $suidx]
            switch -exact $tagname {
               suptag {
                  set ridx [lsearch -exact $suptagrng $lineno.$charno]
                  if { ($ridx >= 0) && !($ridx & 1) } { puts -nonewline $f "\$^\{\\hbox\{$ss " }
               }
               subtag {
                  set ridx [lsearch -exact $subtagrng $lineno.$charno]
                  if { ($ridx >= 0) && !($ridx & 1) } { puts -nonewline $f "\$_\{\\hbox\{$ss " }
               }
               supsuptag {
                  set ridx [lsearch -exact $supsuptagrng $lineno.$charno]
                  if { ($ridx >= 0) && !($ridx & 1) } { puts -nonewline $f "\$^\{^\{\\hbox\{$sss " }
               }
               subsuptag {
                  set ridx [lsearch -exact $subsuptagrng $lineno.$charno]
                  if { ($ridx >= 0) && !($ridx & 1) } { puts -nonewline $f "\$^\{_\{\\hbox\{$sss " }
               }
               subsubtag {
                  set ridx [lsearch -exact $subsubtagrng $lineno.$charno]
                  if { ($ridx >= 0) && !($ridx & 1) } { puts -nonewline $f "\$_\{_\{\\hbox\{$sss " }
               }
               subsubtag {
                  set ridx [lsearch -exact $supsubtagrng $lineno.$charno]
                  if { ($ridx >= 0) && !($ridx & 1) } { puts -nonewline $f "\$_\{^\{\\hbox\{$sss " }
               }
            }
         }
         set ridx [lsearch -exact $englishrng $lineno.$charno]
         if { ($ridx >= 0) } {
            if { !($ridx & 1) } {
               incr englishmode 1 ; puts -nonewline $f "\{\\rm "
            } else {
               incr ridx 1
               if { ($ridx < [llength $englishrng]) && ("$lineno.$charno" == [lindex $englishrng $ridx]) } {
                  incr englishmode 1 ; puts -nonewline $f "\{\\rm "
               }
            }
         }
         if {[lsearch -regexp $tagshere "bengali"] >= 0} {
            foreach tagname { normalsize small large Large LARGE huge Huge } {
               set ridx [eval lsearch -exact \$${tagname}rng $lineno.$charno]
               if { ($ridx >= 0) } {
                  if { !($ridx & 1) } {
                     puts -nonewline $f "\{\\$tagname\\nsl "
                  } else {
                     incr ridx 1
                     if { ($ridx < [eval llength  \$${tagname}rng]) && ("$lineno.$charno" == [eval lindex \$${tagname}rng $ridx]) } {
                        puts -nonewline $f "\{\\$tagname\\nsl "
                     }
                  }
               }
               set ridx [eval lsearch -exact \$${tagname}slrng $lineno.$charno]
               if { ($ridx >= 0) } {
                  if { !($ridx & 1) } {
                     puts -nonewline $f "\{\\$tagname\\sl "
                  } else {
                     incr ridx 1
                     if { ($ridx < [eval llength  \$${tagname}rng]) && ("$lineno.$charno" == [eval lindex \$${tagname}slrng $ridx]) } {
                        puts -nonewline $f "\{\\$tagname\\sl "
                     }
                  }
               }
            }
         }
         set nextchar [string range $ins $i $i]
         scan $nextchar "%c" asciival
         if {$asciival == 10} { set charno 0 ; incr lineno 1 } else { incr charno 1 }
         if {($englishmode & 1)} {
            switch -exact $asciival {
               10 { if {$verbatim} {
                       puts $f "\\null\\\\\\null"
                    } else {
                       puts $f ""
                    }
               }
               32 { if {$verbatim} {
                       puts -nonewline $f "~"
                    } else {
                       puts -nonewline $f " "
                    }
               }
               35 { puts -nonewline $f "\\#" }
               36 { puts -nonewline $f "\\\$" }
               37 { puts -nonewline $f "\\%" }
               38 { puts -nonewline $f "\\&" }
               60 { puts -nonewline $f "\$<\$" }
               62 { puts -nonewline $f "\$>\$" }
               91 { puts -nonewline $f "\$\[\$" }
               92 { puts -nonewline $f "\$\\backslash\$" }
               93 { puts -nonewline $f "\$\]\$" }
               94 { puts -nonewline $f "\{\\char94\}" }
               95 { puts -nonewline $f "\\_" }
               123 { puts -nonewline $f "\\\{" }
               124 { puts -nonewline $f "\$|\$" }
               125 { puts -nonewline $f "\\\}" }
               126 { puts -nonewline $f "\$\\tilde\{\\phantom\{1\}\}\$" }
               169 { puts -nonewline $f "\\copyright\{\}" }
               215 { puts -nonewline $f "\$\\times\$" }
               247 { puts -nonewline $f "\$\\div\$" }
               default { puts -nonewline $f $nextchar }
            }
         } else {
            switch -exact $asciival {
                9 { puts -nonewline $f "\t" }
               10 { if {$verbatim} {
                       puts $f "\\null\\\\\\null"
                    } else {
                       puts $f ""
                    }
                  }
               32 { if {$verbatim} {
                       puts -nonewline $f "~"
                    } else {
                       puts -nonewline $f " "
                    }
                  }
               35 { puts -nonewline $f "\\#" }
               36 { puts -nonewline $f "\{\\bucks\}" }
               37 { puts -nonewline $f "\\%" }
               38 { puts -nonewline $f "\{\\char38\}" }
               60 { puts -nonewline $f ".." }
               62 { puts -nonewline $f "\{\\char62\}" }
               64 { puts -nonewline $f "\{\\char64\}" }
               91 { puts -nonewline $f "\{\\char91\}" }
               92 { puts -nonewline $f "\{\\char92\}" }
               93 { puts -nonewline $f "\{\\char93\}" }
               94 { puts -nonewline $f "\{\\char94\}" }
               95 { puts -nonewline $f "\{\\char95\}" }
               default {
                  if { $asciival < 32 } {
                     puts -nonewline $f "\{\\char$asciival\}"
                  } elseif { $asciival >= 123 } {
                     puts -nonewline $f "\{\\char$asciival\}"
                  } else {
                     puts -nonewline $f $nextchar
                  }
               }
            }
         }
      }
      puts $f "\\endgroup"
      if {$omithdr == 0} { puts $f "\\end\{document\}" }
      puts $f "%% End of file"
      close $f
   }
}

proc exportHTML { myid } {
   global fname efname verbatim omithdr doctitle ptsize slant customfontno newTclTk

   set mwin ".main$myid"
   if { [string compare $fname($myid) ""] != 0 } {
      set dotindex [string last "." $fname($myid)]
      incr dotindex -1
   } else {
      set dotindex -1
   }
   if {$dotindex >= 0} {
      set efname [string range $fname($myid) 0 $dotindex]
      set efname "$efname.html"
   } else {
      set efname "$fname($myid).html"
   }
   set verbatim 0
   set omithdr 0
   set doctitle "untitled"
   set efn [getExportFileName]
   if { [string compare $efn ""] != 0 } {
      foreach tagname {suptag supsuptag subsuptag subtag subsubtag supsubtag english} {
         set ${tagname}rng [$mwin.mainfr.editfr.textarea tag ranges $tagname]
      }
      for {set i 0} {$i < $customfontno($myid)} {incr i 1} {
         set englishrng [concat $englishrng [$mwin.mainfr.editfr.textarea tag ranges customftag$i]]
      }
      set englishrng [lsort -real -increasing $englishrng]
      set size1rng [$mwin.mainfr.editfr.textarea tag ranges bengali100r]
      set size2rng [$mwin.mainfr.editfr.textarea tag ranges bengali120r]
      set size3rng [$mwin.mainfr.editfr.textarea tag ranges bengali150r]
      set size4rng [$mwin.mainfr.editfr.textarea tag ranges bengali180r]
      set size5rng [$mwin.mainfr.editfr.textarea tag ranges bengali210r]
      set size6rng [$mwin.mainfr.editfr.textarea tag ranges bengali250r]
      set size7rng [lsort -real -increasing [concat \
         [$mwin.mainfr.editfr.textarea tag ranges bengali300r] \
         [$mwin.mainfr.editfr.textarea tag ranges bengali360r]]]
      set size1slrng [$mwin.mainfr.editfr.textarea tag ranges bengali100o]
      set size2slrng [$mwin.mainfr.editfr.textarea tag ranges bengali120o]
      set size3slrng [$mwin.mainfr.editfr.textarea tag ranges bengali150o]
      set size4slrng [$mwin.mainfr.editfr.textarea tag ranges bengali180o]
      set size5slrng [$mwin.mainfr.editfr.textarea tag ranges bengali210o]
      set size6slrng [$mwin.mainfr.editfr.textarea tag ranges bengali250o]
      set size7slrng [lsort -real -increasing [concat \
         [$mwin.mainfr.editfr.textarea tag ranges bengali300o] \
         [$mwin.mainfr.editfr.textarea tag ranges bengali360o]]]
      foreach scriptrng { \$suptagrng \$subtagrng \$supsuptagrng \$subsuptagrng \$subsubtagrng \$supsubtagrng } {
         set srlen [ eval llength $scriptrng ]
         if {$srlen > 0} {
            foreach tagrng { \$englishrng \$size1rng \$size2rng \$size3rng \$size4rng \$size5rng \$size6rng \$size7rng \$size1slrng \$size2slrng \$size3slrng \$size4slrng \$size5slrng \$size6slrng \$size7slrng } {
               set trlen [ eval llength $tagrng ]
               if {$trlen > 0} {
                  for {set i 0} {$i < $srlen} {incr i 2} {
                     for {set j 0} {$j < $trlen} {incr j 1} {
                        set si [eval lindex $scriptrng $i]
                        set ti1 [eval lindex $tagrng $j]
                        incr j 1
                        set ti2 [eval lindex $tagrng $j]
                        if { ($ti1 < $si) && ($ti2 > $si) } {
                           set [string range $tagrng 1 [expr [string length $tagrng] - 1]] [eval linsert $tagrng $j $si $si]
                           incr trlen 2
                        }
                     }
                  }
                  for {set i 1} {$i < $srlen} {incr i 2} {
                     for {set j 0} {$j < $trlen} {incr j 1} {
                        set si [eval lindex $scriptrng $i]
                        set ti1 [eval lindex $tagrng $j]
                        incr j 1
                        set ti2 [eval lindex $tagrng $j]
                        if { ($ti1 < $si) && ($ti2 > $si) } {
                           set [string range $tagrng 1 [expr [string length $tagrng] - 1]] [eval linsert $tagrng $j $si $si]
                           incr trlen 2
                        }
                     }
                  }
               }
            }
         }
      }

      set f [open $efn w]
      puts $f "<!--------------------------------------------------------->"
      puts $f "<!-- Filename: $efname -->"
      puts $f "<!-- Original file: $fname($myid) -->"
      puts $f "<!-- Exported by: bwedit version 3.0 -->"
      puts $f "<!--------------------------------------------------------->"
      if {$omithdr == 0} {
         puts $f "<HTML>"
         puts $f "<HEAD><TITLE>$doctitle</TITLE></HEAD>"
      }
      switch -exact $ptsize {
         100 { puts $f "<BASEFONT SIZE=2>" }
         150 { puts $f "<BASEFONT SIZE=4>" }
         180 { puts $f "<BASEFONT SIZE=5>" }
         210 { puts $f "<BASEFONT SIZE=6>" }
         250 { puts $f "<BASEFONT SIZE=7>" }
         300 { puts $f "<BASEFONT SIZE=7>" }
         360 { puts $f "<BASEFONT SIZE=7>" }
      }
      if {$omithdr == 0} { puts $f "<BODY>" }
      if {($newTclTk)} {
         set ins [encto [$mwin.mainfr.editfr.textarea get 1.0 end]]
      } else {
         set ins [$mwin.mainfr.editfr.textarea get 1.0 end]
      }
      set inl [string length $ins]
      set lineno 1
      set charno 0
      set tagshere {}
      set opsctg(sup) "<SUP>"
      set opsctg(sub) "<SUB>"
      set opsctg(supsup) "<SUP><SUP>"
      set opsctg(subsup) "<SUP><SUB>"
      set opsctg(subsub) "<SUB><SUB>"
      set opsctg(supsub) "<SUB><SUP>"
      set clsctg(sup) "</SUP>"
      set clsctg(sub) "</SUB>"
      set clsctg(supsup) "</SUP></SUP>"
      set clsctg(subsup) "</SUB></SUP>"
      set clsctg(subsub) "</SUB></SUB>"
      set clsctg(supsub) "</SUP></SUB>"
      for {set i 0} {$i < $inl} {incr i 1} {
         if {[lsearch -regexp $tagshere "bengali"] >= 0} {
            foreach tagname { \$size1rng \$size2rng \$size3rng \$size4rng \$size5rng \$size6rng \$size7rng } {
               set ridx [eval lsearch -exact $tagname $lineno.$charno]
               if { ($ridx >= 0) && ($ridx & 1) } {
                  puts -nonewline $f "</FONT>"
               }
            }
            foreach tagname { \$size1slrng \$size2slrng \$size3slrng \$size4slrng \$size5slrng \$size6slrng \$size7slrng } {
               set ridx [eval lsearch -exact $tagname $lineno.$charno]
               if { ($ridx >= 0) && ($ridx & 1) } {
                  puts -nonewline $f "</I></FONT>"
               }
            }
         }
         set ridx [lsearch -exact $englishrng $lineno.$charno]
         if { ($ridx >= 0) && ($ridx & 1) } { puts -nonewline $f "</TT>" }
         set suidx [lsearch -regexp $tagshere "su"]
         if {$suidx >= 0} {
            set tagname [lindex $tagshere $suidx]
            set tagname [string range $tagname 0 [expr [string length $tagname] - 4]]
            set ridx [eval lsearch -exact \$${tagname}tagrng $lineno.$charno]
            if { ($ridx >= 0) && ($ridx & 1) } { puts -nonewline $f $clsctg($tagname) }
         }
         set tagshere [$mwin.mainfr.editfr.textarea tag names "$lineno.$charno"]
         set suidx [lsearch -regexp $tagshere "su"]
         if {$suidx >= 0} {
            set tagname [lindex $tagshere $suidx]
            set tagname [string range $tagname 0 [expr [string length $tagname] - 4]]
            set ridx [eval lsearch -exact \$${tagname}tagrng $lineno.$charno]
            if { ($ridx >= 0) && !($ridx & 1) } { puts -nonewline $f $opsctg($tagname) }
         }
         set ridx [lsearch -exact $englishrng $lineno.$charno]
         if {($ridx >= 0)} {
            if { !($ridx & 1) } { puts -nonewline $f "<TT>" } else {
               incr ridx 1
               if { ($ridx < [llength $englishrng]) && ("$lineno.$charno" == [lindex $englishrng $ridx]) } {
                   puts -nonewline $f "<TT>"
               }
            }
         }
         if {[lsearch -regexp $tagshere "bengali"] >= 0} {
            for {set ftsz 1} {$ftsz <= 7} {incr ftsz 1} {
               set ridx [eval lsearch -exact \$size${ftsz}rng $lineno.$charno]
               if {($ridx >= 0)} {
                  if { !($ridx & 1) } {
                     puts -nonewline $f "<FONT SIZE=$ftsz>"
                  } else {
                     incr ridx 1
                     if { ($ridx < [eval llength \$size${ftsz}rng]) && ("$lineno.$charno" == [eval lindex \$size${ftsz}rng $ridx]) } {
                        puts -nonewline $f "<FONT SIZE=$ftsz>"
                     }
                  }
               }
               set ridx [eval lsearch -exact \$size${ftsz}slrng $lineno.$charno]
               if {($ridx >= 0)} {
                  if { !($ridx & 1) } {
                     puts -nonewline $f "<FONT SIZE=$ftsz><I>"
                  } else {
                     incr ridx 1
                     if { ($ridx < [eval llength \$size${ftsz}slrng]) && ("$lineno.$charno" == [eval lindex \$size${ftsz}slrng $ridx]) } {
                        puts -nonewline $f "<FONT SIZE=$ftsz><I>"
                     }
                  }
               }
            }
         }
         set nextchar [string range $ins $i $i]
         scan $nextchar "%c" asciival
         if {$asciival == 10} { set charno 0 ; incr lineno 1 } else { incr charno 1 }
         switch -exact $asciival {
            34 { puts -nonewline $f "&quot;" }
            38 { puts -nonewline $f "&amp;" }
            60 { puts -nonewline $f "&lt;" }
            62 { puts -nonewline $f "&gt;" }
             9 { if {$verbatim} {
                    puts -nonewline $f "&nbsp;"
                 } else {
                    puts  -nonewline $f "\t"
                 }
               }
            10 { if {$verbatim} {
                    puts $f "<BR>"
                 } else {
                    incr i
                    set nextnextchar [string range $ins $i $i]
                    if { [string compare $nextnextchar "\n"] == 0 } {
                       puts $f "\n<P>"
                       incr lineno
                    } else {
                       incr i -1
                       puts $f ""
                    }
                 }
               }
            32 { if {$verbatim} {
                    puts -nonewline $f "&nbsp;"
                 } else {
                    puts -nonewline $f " "
                 }
               }
            default {
               if { $asciival < 32 } {
                  puts -nonewline $f "&#$asciival;"
               } elseif { $asciival >= 128 } {
                  puts -nonewline $f "&#$asciival;"
               } else {
                  puts -nonewline $f $nextchar
               }
            }
         }
      }
      if {$omithdr == 0} {
         puts $f "</BODY>"
         puts $f "</HTML>"
      }
      puts $f "<!-- End of file -->"
      close $f
   }
}

proc getPSFileName {} {
   global efname pt pageheight textheight xoffset yoffset psfnok
   global btnbg btnfg appbg appfg

   set dbox [toplevel .export]
   frame $dbox.fr1
   frame $dbox.fr2
   frame $dbox.fr3
   frame $dbox.fr4
   frame $dbox.fr5
   frame $dbox.fr6
   frame $dbox.fr6a
   frame $dbox.fr7
   label $dbox.fr1.lbl -text "Export to file:" -relief flat -anchor e -fg $appfg -bg $appbg
   entry $dbox.fr1.ent -textvariable efname -bg #ddaaaa -fg #000000
   label $dbox.fr2.lbl -text "Point size:" -relief flat -anchor e -fg $appfg -bg $appbg
   entry $dbox.fr2.ent -textvariable pt -bg #ddaaaa -fg #000000
   label $dbox.fr3.lbl -text "Text height (cm)" -relief flat -anchor e -fg $appfg -bg $appbg
   entry $dbox.fr3.ent -textvariable textheight -bg #ddaaaa -fg #000000
   label $dbox.fr4.lbl -text "X offset (cm)" -relief flat -anchor e -fg $appfg -bg $appbg
   entry $dbox.fr4.ent -textvariable xoffset -bg #ddaaaa -fg #000000
   label $dbox.fr5.lbl -text "Y offset (cm)" -relief flat -anchor e -fg $appfg -bg $appbg
   entry $dbox.fr5.ent -textvariable yoffset -bg #ddaaaa -fg #000000
   label $dbox.fr6.lbl -text "Page height (cm)" -relief flat -anchor e -fg $appfg -bg $appbg
   entry $dbox.fr6.ent -textvariable pageheight -bg #ddaaaa -fg #000000
   label $dbox.fr6a.lbl -text "Paper" -relief flat -anchor e -fg $appfg -bg $appbg
   menubutton $dbox.fr6a.btn -text "A4" -height 1 -width 10 -relief raised \
      -menu $dbox.fr6a.btn.m -bg $appbg -fg $appfg \
      -activeforeground $appfg -activebackground $appbg \
      -highlightthickness 0
   menu $dbox.fr6a.btn.m -tearoff false -bg $appbg -fg $appfg
   $dbox.fr6a.btn.m add command -label "  A3" -command "set xoffset 2.5; set yoffset 2.5; set pageheight 42.0; set textheight 37.0; $dbox.fr6a.btn config -text A3"
   $dbox.fr6a.btn.m add command -label "  A4" -command "set xoffset 2.5; set yoffset 2.5; set pageheight 29.7; set textheight 24.7; $dbox.fr6a.btn config -text A4"
   $dbox.fr6a.btn.m add command -label "  A5" -command "set xoffset 2.5; set yoffset 2.5; set pageheight 21.0; set textheight 16.0; $dbox.fr6a.btn config -text A5"
   $dbox.fr6a.btn.m add command -label "  B4" -command "set xoffset 2.5; set yoffset 2.5; set pageheight 36.4; set textheight 31.4; $dbox.fr6a.btn config -text B4"
   $dbox.fr6a.btn.m add command -label "  B5" -command "set xoffset 2.5; set yoffset 2.5; set pageheight 25.7; set textheight 20.7; $dbox.fr6a.btn config -text B5"
   $dbox.fr6a.btn.m add command -label "  Executive" -command "set xoffset 2.5; set yoffset 2.5; set pageheight 25.4; set textheight 20.4; $dbox.fr6a.btn config -text Executive"
   $dbox.fr6a.btn.m add command -label "  Folio" -command "set xoffset 2.5; set yoffset 2.5; set pageheight 33.0; set textheight 28.0; $dbox.fr6a.btn config -text Folio"
   $dbox.fr6a.btn.m add command -label "  Ledger" -command "set xoffset 2.5; set yoffset 2.5; set pageheight 27.9; set textheight 22.9; $dbox.fr6a.btn config -text Ledger"
   $dbox.fr6a.btn.m add command -label "  Legal" -command "set xoffset 2.5; set yoffset 2.5; set pageheight 35.6; set textheight 30.6; $dbox.fr6a.btn config -text Legal"
   $dbox.fr6a.btn.m add command -label "  Letter" -command "set xoffset 2.5; set yoffset 2.5; set pageheight 27.9; set textheight 22.9; $dbox.fr6a.btn config -text Letter"
   $dbox.fr6a.btn.m add command -label "  Quarto" -command "set xoffset 2.5; set yoffset 2.5; set pageheight 27.5; set textheight 22.5; $dbox.fr6a.btn config -text Quarto"
   $dbox.fr6a.btn.m add command -label "  Statement" -command "set xoffset 2.5; set yoffset 2.5; set pageheight 21.6; set textheight 16.6; $dbox.fr6a.btn config -text Statement"
   $dbox.fr6a.btn.m add command -label "  Tabloid" -command "set xoffset 2.5; set yoffset 2.5; set pageheight 43.2; set textheight 38.2; $dbox.fr6a.btn config -text Tabloid"
   button $dbox.fr7.obtn -text "OK" -command {set psfnok 1} -width 6 -fg $btnfg -bg $btnbg -activebackground $btnbg -activeforeground $btnfg
   button $dbox.fr7.cbtn -text "Cancel" -command {set psfnok 0} -width 6 -fg $btnfg -bg $btnbg -activebackground $btnbg -activeforeground $btnfg
   label $dbox.fr7.space -text "" -relief flat -fg $appfg -bg $appbg
   pack $dbox.fr1 $dbox.fr2 $dbox.fr3 $dbox.fr4 $dbox.fr5 $dbox.fr6 -expand yes -fill x
   pack $dbox.fr6a -expand no
   pack $dbox.fr7 -expand yes -fill x
   pack $dbox.fr1.lbl -padx 5 -pady 5 -side left -expand yes -fill x
   pack $dbox.fr1.ent -padx 5 -pady 5
   pack $dbox.fr2.lbl -padx 5 -pady 5 -side left -expand yes -fill x
   pack $dbox.fr2.ent -padx 5 -pady 5
   pack $dbox.fr3.lbl -padx 5 -pady 5 -side left -expand yes -fill x
   pack $dbox.fr3.ent -padx 5 -pady 5
   pack $dbox.fr4.lbl -padx 5 -pady 5 -side left -expand yes -fill x
   pack $dbox.fr4.ent -padx 5 -pady 5
   pack $dbox.fr5.lbl -padx 5 -pady 5 -side left -expand yes -fill x
   pack $dbox.fr5.ent -padx 5 -pady 5
   pack $dbox.fr6.lbl -padx 5 -pady 5 -side left -expand yes -fill x
   pack $dbox.fr6.ent -padx 5 -pady 5
   pack $dbox.fr6a.lbl -padx 5 -pady 5 -side left -expand no
   pack $dbox.fr6a.btn -padx 5 -pady 5
   pack $dbox.fr7.obtn -padx 5 -pady 5 -side left
   pack $dbox.fr7.space -padx 5 -pady 5  -side left -expand yes -fill x
   pack $dbox.fr7.cbtn -padx 5 -pady 5 -fill y
   $dbox config -bg $appbg
   $dbox.fr1 config -bg $appbg
   $dbox.fr2 config -bg $appbg
   $dbox.fr3 config -bg $appbg
   $dbox.fr4 config -bg $appbg
   $dbox.fr5 config -bg $appbg
   $dbox.fr6 config -bg $appbg
   $dbox.fr6a config -bg $appbg
   $dbox.fr7 config -bg $appbg
   bind $dbox <Escape> {set psfnok 0}
   bind $dbox.fr1.ent <Return>  "focus $dbox.fr2.ent"
   bind $dbox.fr2.ent <Return>  "focus $dbox.fr3.ent"
   bind $dbox.fr3.ent <Return>  "focus $dbox.fr4.ent"
   bind $dbox.fr4.ent <Return>  "focus $dbox.fr5.ent"
   bind $dbox.fr5.ent <Return>  "focus $dbox.fr6.ent"
   bind $dbox.fr6.ent <Return>  {set psfnok 1}

   wm title $dbox "bwedit: export"
   wm resizable $dbox false false

   focus $dbox.fr1.ent
   grab $dbox
   tkwait variable psfnok
   grab release $dbox
   destroy $dbox

   if {$psfnok} { return [string trim $efname] } else { return "" }
}

proc exportPS { myid } {
   global fname efname pt pageheight textheight xoffset yoffset psfontfile
   global customfontno ptsize slant appbg appfg newTclTk

   set mwin ".main$myid"

   if { [string compare $fname($myid) ""] != 0 } {
      set dotindex [string last "." $fname($myid)]
      incr dotindex -1
   } else {
      set dotindex -1
   }
   if {$dotindex >= 0} {
      set efname [string range $fname($myid) 0 $dotindex]
      set efname "$efname.ps"
   } else {
      set efname "$fname($myid).ps"
   }
   set pt 12
   set sl "normal"
   set pageheight 29.7
   set textheight 24.7
   set xoffset 2.5
   set yoffset 2.5

   set efn [getPSFileName]
   if { [string compare $efn ""] != 0 } {
      if {[string compare "o" $slant]} { set slflag 0 } else { set slflag 1 }
      foreach tagname {suptag supsuptag subsuptag subtag subsubtag supsubtag english} {
         set ${tagname}rng [$mwin.mainfr.editfr.textarea tag ranges $tagname]
      }
      for {set i 0} {$i < $customfontno($myid)} {incr i 1} {
         set englishrng [concat $englishrng [$mwin.mainfr.editfr.textarea tag ranges customftag$i]]
      }
      set englishrng [lsort -real -increasing $englishrng]
      set smallrng [$mwin.mainfr.editfr.textarea tag ranges bengali100r]
      set normalrng [$mwin.mainfr.editfr.textarea tag ranges bengali120r]
      set largerng [$mwin.mainfr.editfr.textarea tag ranges bengali150r]
      set Largerng [$mwin.mainfr.editfr.textarea tag ranges bengali180r]
      set LARGErng [$mwin.mainfr.editfr.textarea tag ranges bengali210r]
      set hugerng [$mwin.mainfr.editfr.textarea tag ranges bengali250r]
      set Hugerng [$mwin.mainfr.editfr.textarea tag ranges bengali300r]
      set HUGErng [$mwin.mainfr.editfr.textarea tag ranges bengali360r]
      set smallslrng [$mwin.mainfr.editfr.textarea tag ranges bengali100o]
      set normalslrng [$mwin.mainfr.editfr.textarea tag ranges bengali120o]
      set largeslrng [$mwin.mainfr.editfr.textarea tag ranges bengali150o]
      set Largeslrng [$mwin.mainfr.editfr.textarea tag ranges bengali180o]
      set LARGEslrng [$mwin.mainfr.editfr.textarea tag ranges bengali210o]
      set hugeslrng [$mwin.mainfr.editfr.textarea tag ranges bengali250o]
      set Hugeslrng [$mwin.mainfr.editfr.textarea tag ranges bengali300o]
      set HUGEslrng [$mwin.mainfr.editfr.textarea tag ranges bengali360o]
      foreach scriptrng { \$suptagrng \$subtagrng \$supsuptagrng \$subsuptagrng \$subsubtagrng \$supsubtagrng } {
         set srlen [ eval llength $scriptrng ]
         if {$srlen > 0} {
            foreach tagrng { \$normalrng \$smallrng \$largerng \$Largerng \$LARGErng \$hugerng \$Hugerng \$HUGErng \$englishrng \$normalslrng \$smallslrng \$largeslrng \$Largeslrng \$LARGEslrng \$hugeslrng \$Hugeslrng \$HUGEslrng } {
               set trlen [ eval llength $tagrng ]
               if {$trlen > 0} {
                  for {set i 0} {$i < $srlen} {incr i 2} {
                     for {set j 0} {$j < $trlen} {incr j 1} {
                        set si [eval lindex $scriptrng $i]
                        set ti1 [eval lindex $tagrng $j]
                        incr j 1
                        set ti2 [eval lindex $tagrng $j]
                        if { ($ti1 < $si) && ($ti2 > $si) } {
                           set [string range $tagrng 1 [expr [string length $tagrng] - 1]] [eval linsert $tagrng $j $si $si]
                           incr trlen 2
                        }
                     }
                  }
                  for {set i 1} {$i < $srlen} {incr i 2} {
                     for {set j 0} {$j < $trlen} {incr j 1} {
                        set si [eval lindex $scriptrng $i]
                        set ti1 [eval lindex $tagrng $j]
                        incr j 1
                        set ti2 [eval lindex $tagrng $j]
                        if { ($ti1 < $si) && ($ti2 > $si) } {
                           set [string range $tagrng 1 [expr [string length $tagrng] - 1]] [eval linsert $tagrng $j $si $si]
                           incr trlen 2
                        }
                     }
                  }
               }
            }
         }
      }
      set pageno 1
      set f [open $efn w]
      puts $f "%!PS-Adobe-2.0"
      puts $f "%%Title: Exported from $fname($myid)"
      puts $f "%%Creator: bwedit version 3.0"
      puts $f "%%CreationDate: [exec date]"
      puts $f "%%Pages: (atend)"
      puts $f "%%PageOrder: Ascend"
      puts $f "%%BoundingBox: 0 0 596 842"
      puts $f "%%DocumentFonts: "
      puts $f "%%DocumentPaperSizes: a4"
      puts $f "%%EndComments"

      set ff [open $psfontfile r]
      set x [read $ff]
      puts $f $x
      close $ff

      set corr1 [expr 0.43 * $pt]
      set corr2 [expr 0.23 * $pt]
      set corr3 [expr 0.20 * $pt]
      set corr4 [expr 0.56 * $pt]
      set corr5 [expr 0.06 * $pt]
      set lineskip [expr 1.4 * $pt]
      set uly [expr ($pageheight - $yoffset) * 28.35 - (0.8 * $pt)]
      set lly [expr $uly - ($textheight * 28.35)]
      set xoffset [expr $xoffset * 28.35]
      set currenty $uly
      set off1 [expr 0.5 * $pt]
      set off2 [expr 0.8 * $pt]
      set off3 [expr 0.3 * $pt]
      puts $f "/bnnormal \{ /Bengali findfont $pt scalefont setfont \} def"
      set bnsize [expr 0.7 * $pt]
      puts $f "/bnsmall \{ /Bengali findfont $bnsize scalefont setfont \} def"
      set bnsize [expr 0.5 * $pt]
      puts $f "/bntiny \{ /Bengali findfont $bnsize scalefont setfont \} def"
      set bnsize [expr 1.2 * $pt]
      puts $f "/bnlarge \{ /Bengali findfont $bnsize scalefont setfont \} def"
      set bnsize [expr 1.44 * $pt]
      puts $f "/bnLarge \{ /Bengali findfont $bnsize scalefont setfont \} def"
      set bnsize [expr 1.728 * $pt]
      puts $f "/bnLARGE \{ /Bengali findfont $bnsize scalefont setfont \} def"
      set bnsize [expr 2.074 * $pt]
      puts $f "/bnhuge \{ /Bengali findfont $bnsize scalefont setfont \} def"
      set bnsize [expr 2.488 * $pt]
      puts $f "/bnHuge \{ /Bengali findfont $bnsize scalefont setfont \} def"
      set bnsize [expr 2.986 * $pt]
      puts $f "/bnHUGE \{ /Bengali findfont $bnsize scalefont setfont \} def"
      puts $f "/english \{ /Times-Roman findfont $pt scalefont setfont \} def"

      puts $f "/bsup \{ 0 $off1 rmoveto \} def"
      puts $f "/bsub \{ 0 -$off1 rmoveto \} def"
      puts $f "/bsupsup \{ 0 $off2 rmoveto \} def"
      puts $f "/bsubsub \{ 0 -$off2 rmoveto \} def"
      puts $f "/bsubsup \{ 0 $off3 rmoveto \} def"
      puts $f "/bsupsub \{ 0 -$off3 rmoveto \} def"
      puts $f "/esup \{ 0 -$off1 rmoveto \} def"
      puts $f "/esub \{ 0 $off1 rmoveto \} def"
      puts $f "/esupsup \{ 0 -$off2 rmoveto \} def"
      puts $f "/esubsub \{ 0 $off2 rmoveto \} def"
      puts $f "/esubsup \{ 0 -$off3 rmoveto \} def"
      puts $f "/esupsub \{ 0 $off3 rmoveto \} def"

      puts $f "/M \{ dup 4 div neg /y0 exch def moveto \} def"
      puts $f "/S \{ show \} def"
      puts $f "/SS \{ dup stringwidth pop /xx exch def gsave \[1 0 0.25 1 y0 0\] concat show grestore xx 0 rmoveto \} def"
      puts $f "/N \{ $xoffset $uly M \} def"
      puts $f "/B \{ neg /corr exch def corr 0 rmoveto \} def /F \{ /corr exch def corr 0 rmoveto \} def"
      puts $f "/CH 1 string def"
      puts $f "/P \{ CH 0 3 -1 roll put CH S \} def"
      puts $f "/PP \{ CH 0 3 -1 roll put CH SS \} def"
      puts $f "bnnormal"
      set tos 0
      set fontstack(0) "bnnormal"

      puts $f "\n%%Page: $pageno $pageno\nN"
      if ($newTclTk) {
         set ins [encto [$mwin.mainfr.editfr.textarea get 1.0 end]]
      } else {
         set ins [$mwin.mainfr.editfr.textarea get 1.0 end]
      }
      set inl [string length $ins]
      set lineno 1
      set charno 0
      set englishmode 0
      foreach tagname { sub sup subsup supsub supsup subsub large Large LARGE huge Huge HUGE } {
         set ${tagname}found 0
         set prevcorr 0
      }
      set acc ""
      set tagshere {}
      for {set i 0} {$i < $inl} {incr i 1} {
         if {[lsearch -regexp $tagshere "bengali"] >= 0} {
            foreach tagname { \$normalrng \$smallrng \$largerng \$Largerng \$LARGErng \$hugerng \$Hugerng \$HUGErng \$normalslrng \$smallslrng \$largeslrng \$Largeslrng \$LARGEslrng \$hugeslrng \$Hugeslrng \$HUGEslrng } {
               set ridx [eval lsearch -exact $tagname $lineno.$charno]
               if { ($ridx >= 0) && ($ridx & 1) } {
                  incr tos -1 ; set prevfont $fontstack($tos) ; set acc "$acc $prevfont"
                  if {[string compare $slant "o"]} {set slflag 0} else {set slflag 1}
               }
            }
         }
         set ridx [lsearch -exact $englishrng $lineno.$charno]
         if { ($ridx >= 0) && ($ridx & 1) } {
            incr englishmode -1
            incr tos -1 ; set prevfont $fontstack($tos) ; set acc "$acc $prevfont"
         }
         set suidx [lsearch -regexp $tagshere "su"]
         if {$suidx >= 0} {
            set tagname [lindex $tagshere $suidx]
            set tagname [string range $tagname 0 [expr [string length $tagname] - 4]]
            set ridx [eval lsearch -exact \$${tagname}tagrng $lineno.$charno]
            if { ($ridx >= 0) && ($ridx & 1) } {
               set acc "$acc e$tagname"
               incr tos -1 ; set prevfont $fontstack($tos) ; set acc "$acc $prevfont"
            }
         }
         set tagshere [$mwin.mainfr.editfr.textarea tag names "$lineno.$charno"]
         set suidx [lsearch -regexp $tagshere "su.tag"]
         if {$suidx >= 0} {
            set tagname [lindex $tagshere $suidx]
            set tagname [string range $tagname 0 [expr [string length $tagname] - 4]]
            set ridx [eval lsearch -exact \$${tagname}tagrng $lineno.$charno]
            if { ($ridx >= 0) && !($ridx & 1) && ([string length $tagname] == 3) } {
               set acc "$acc b$tagname"
               incr tos 1 ; set fontstack($tos) bnsmall ; set acc "$acc bnsmall"
               set ${tagname}found 1
            }
         }
         set suidx [lsearch -regexp $tagshere "su.su.tag"]
         if {$suidx >= 0} {
            set tagname [lindex $tagshere $suidx]
            set tagname [string range $tagname 0 [expr [string length $tagname] - 4]]
            set ridx [eval lsearch -exact \$${tagname}tagrng $lineno.$charno]
            if { ($ridx >= 0) && !($ridx & 1) } {
               set acc "$acc b$tagname"
               incr tos 1 ; set fontstack($tos) bntiny ; set acc "$acc bntiny"
               set ${tagname}found 1
            }
         }
         set ridx [lsearch -exact $englishrng $lineno.$charno]
         if {($ridx >= 0)} {
            if { !($ridx & 1) } {
               incr englishmode 1
               incr tos 1 ; set fontstack($tos) english ; set acc "$acc english"
            } else {
               incr ridx 1
               if { ($ridx < [llength $englishrng]) && ("$lineno.$charno" == [lindex $englishrng $ridx]) } {
                  incr englishmode 1
                  incr tos 1 ; set fontstack($tos) english ; set acc "$acc english"
               }
            }
         }
         if {[lsearch -regexp $tagshere "bengali"] >= 0} {
            foreach tagname { normal small large Large LARGE huge Huge HUGE } {
               set ridx [eval lsearch -exact \$${tagname}rng $lineno.$charno]
               if {($ridx >= 0)} {
                  if { !($ridx & 1) } {
                     set acc "$acc bn$tagname" ; set slflag 0
                     incr tos 1 ; set fontstack($tos) bn$tagname
                     set ${tagname}found 1
                  } else {
                     incr ridx 1
                     if { ($ridx < [eval llength \$${tagname}rng]) && ("$lineno.$charno" == [eval lindex \$${tagname}rng $ridx]) } {
                        set acc "$acc bn$tagname" ; set slflag 0
                        incr tos 1 ; set fontstack($tos) bn$tagname
                        set ${tagname}found 1
                     }
                  }
               }
               set ridx [eval lsearch -exact \$${tagname}slrng $lineno.$charno]
               if {($ridx >= 0)} {
                  if { !($ridx & 1) } {
                     set acc "$acc bn$tagname" ; set slflag 1
                     incr tos 1 ; set fontstack($tos) bn$tagname
                     set ${tagname}found 1
                  } else {
                     incr ridx 1
                     if { ($ridx < [eval llength \$${tagname}slrng]) && ("$lineno.$charno" == [eval lindex \$${tagname}slrng $ridx]) } {
                        set acc "$acc bn$tagname" ; set slflag 1
                        incr tos 1 ; set fontstack($tos) bn$tagname
                        set ${tagname}found 1
                     }
                  }
               }
            }
         }
         set nextchar [string range $ins $i $i]
         scan $nextchar "%c" asciival
         if {$asciival == 10} { set charno 0 ; incr lineno 1 } else { incr charno 1 }
         if {($slflag) && !($englishmode)} {set P PP ; set S SS} else {set P P ; set S S}
         if {$asciival == 10} {
            set currenty [expr $currenty - $lineskip]
            if {$prevcorr != 0} { set currenty [expr $currenty - ( $prevcorr * $pt )] }
            set sosc 0
            if {$subsupfound} { set sosc 0.3 }
            if {$supfound} { set sosc 0.5 }
            if {$supsupfound} { set sosc 0.8 }
            set fosc 0
            if {$largefound} { set fosc 0.25 }
            if {$Largefound} { set fosc 0.5 }
            if {$LARGEfound} { set fosc 0.75 }
            if {$hugefound} { set fosc 1.08 }
            if {$Hugefound} { set fosc 1.5 }
            if {$HUGEfound} { set fosc 2 }
            set tosc [expr ( $sosc + $fosc ) * $pt]
            set currenty [expr $currenty - $tosc]
            set prevcorr 0
            if { $currenty <= $lly } {
               incr pageno 1
               puts $f "showpage\n\n%%Page: $pageno $pageno\nN"
               set currenty $uly
            } else {
               if {$supsubfound} {set prevcorr 0.3}
               if {$subfound} {set prevcorr 0.5}
               if {$subsubfound} {set prevcorr 0.8}
            }
            puts $f "$xoffset $currenty M"
            puts $f $acc
            set acc ""
            set taglist [$mwin.mainfr.editfr.textarea tag names "$lineno.0"]
            if {[lsearch -regexp $taglist "bengali150"] >= 0} { set largefound 1 } else { set largefound 0 }
            if {[lsearch -regexp $taglist "bengali180"] >= 0} { set Largefound 1 } else { set Largefound 0 }
            if {[lsearch -regexp $taglist "bengali210"] >= 0} { set LARGEfound 1 } else { set LARGEfound 0 }
            if {[lsearch -regexp $taglist "bengali250"] >= 0} { set hugefound 1 } else { set hugefound 0 }
            if {[lsearch -regexp $taglist "bengali300"] >= 0} { set Hugefound 1 } else { set Hugefound 0 }
            if {[lsearch -regexp $taglist "bengali360"] >= 0} { set HUGEfound 1 } else { set HUGEfound 0 }
            foreach tagname { sub sup subsup supsub supsup subsub } {
               if {[lsearch -exact $taglist "${tagname}tag"] >= 0} {
                  set ${tagname}found 1
               } else { set ${tagname}found 0 }
            }
         } elseif {$englishmode} {
            switch -exact $asciival {
               37 { set acc "$acc (\\$nextchar) S" }
               40 { set acc "$acc (\\$nextchar) S" }
               41 { set acc "$acc (\\$nextchar) S" }
               92 { set acc "$acc (\\$nextchar) S" }
               default {
                  if { ($asciival < 32) || ($asciival > 127) } {
                     set acc "$acc $asciival P"
                  } else {
                     set acc "$acc ($nextchar) S"
                  }
               }
            }
         } else {
            switch -exact $asciival {
                1 { set acc "$acc $corr5 B 1 $P $corr5 F" }
                3 { set acc "$acc $corr5 B 3 $P $corr5 F" }
                4 { set acc "$acc $corr5 B 4 $P $corr5 F" }
               15 { set acc "$acc $corr4 B 15 $P $corr4 F" }
               37 { set acc "$acc (\\$nextchar) $S" }
               40 { set acc "$acc (\\$nextchar) $S" }
               41 { set acc "$acc (\\$nextchar) $S" }
               46 { set acc "$acc $corr1 F (.) $S" }
               73 { set acc "$acc $corr1 B (I) $S $corr1 F" }
               79 { set acc "$acc $corr1 B (O) $S $corr1 F" }
               84 { set acc "$acc $corr5 B (T) $S $corr5 F" }
               85 { set acc "$acc $corr2 B (U) $S $corr2 F" }
               87 { set acc "$acc $corr2 B (W) $S $corr2 F" }
               92 { set acc "$acc (\\$nextchar) $S" }
              117 { set acc "$acc $corr2 B (u) $S $corr2 F" }
              119 { set acc "$acc $corr3 B (w) $S $corr3 F" }
               default {
                  if { ($asciival < 32) || ($asciival > 127) } {
                     set acc "$acc $asciival $P"
                  } else {
                     set acc "$acc ($nextchar) $S"
                  }
               }
            }
         }
      }
      puts $f "showpage\n"
      puts $f "%%Trailer"
      puts $f "%%Pages: $pageno"
      puts $f "%%EOF"
      close $f
   }
}

proc rExportHTML { myid } {
   global rfname efname verbatim omithdr doctitle installdir encfnm

   set rwin ".roman$myid"

   if { [string compare $rfname($myid) ""] != 0 } {
      set dotindex [string last "." $rfname($myid)]
      incr dotindex -1
   } else {
      set dotindex -1
   }
   if {$dotindex >= 0} {
      set efname [string range $rfname($myid) 0 $dotindex]
      set efname "$efname.html"
   } else {
      set efname "$rfname($myid).html"
   }
   set verbatim 0
   set omithdr 0
   set doctitle "untitled"
   set efn [getExportFileName]

   if { [string compare $efn ""] != 0 } {
      set f [open $efn w]
      puts $f "<!--------------------------------------------------------->"
      puts $f "<!-- Filename: $efname -->"
      puts $f "<!-- Original file: $rfname($myid) -->"
      puts $f "<!-- Exported by: bwedit version 3.0 -->"
      puts $f "<!--------------------------------------------------------->"
      if {$omithdr == 0} {
         puts $f "<HTML>"
         puts $f "<HEAD><TITLE>$doctitle</TITLE></HEAD>"
         puts $f "<BODY>"
      }
      if {$verbatim == 0} { set bwconvflags "Ms" } else { set bwconvflags "Msv" }
      puts $f [exec $installdir/bin/bwconv $bwconvflags [$rwin.mainfr.editfr.textarea get 1.0 end] $encfnm 2>/dev/null]
      if {$omithdr == 0} {
         puts $f "</BODY>"
         puts $f "</HTML>"
      }
      puts $f "<!-- End of file -->"
      close $f
   }
}

proc rExportLaTeX { myid } {
   global rfname efname verbatim omithdr doctitle installdir encfnm

   set rwin ".roman$myid"

   if { [string compare $rfname($myid) ""] != 0 } {
      set dotindex [string last "." $rfname($myid)]
      incr dotindex -1
   } else {
      set dotindex -1
   }
   if {$dotindex >= 0} {
      set efname [string range $rfname($myid) 0 $dotindex]
      set efname "$efname.tex"
   } else {
      set efname "$rfname($myid).tex"
   }
   set verbatim 0
   set omithdr 0
   set doctitle ""
   set efn [getExportFileName]
   if { [string compare $efn ""] != 0 } {
      set f [open $efn w]
      puts $f "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
      puts $f "%% Filename: $efname"
      puts $f "%% Original file: $rfname($myid)"
      puts $f "%% Exported by: bwedit version 3.0"
      puts $f "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
      if {$omithdr == 0} {
         puts $f "\\documentstyle\[11pt,bengali\]\{article\}"
         puts $f "\\parindent 0pt"
         puts $f "\\parskip 10pt"
         puts $f "\\hbadness 10000"
         if { [string compare $doctitle ""] != 0 } {
            puts $f "\\pagestyle\{myheadings\}"
            puts $f "\\markboth\{$doctitle\}\{$doctitle\}"
         }
         puts $f "\\begin\{document\}"
      }
      puts $f "\\begingroup\\bn\\leavevmode"
      if {$verbatim == 0} { set bwconvflags "Lns" } else { set bwconvflags "Lnsv" }
      puts $f [exec $installdir/bin/bwconv $bwconvflags [$rwin.mainfr.editfr.textarea get 1.0 end] $encfnm 2>/dev/null]
      puts $f "\\endgroup"
      if {$omithdr == 0} { puts $f "\\end\{document\}" }
      puts $f "%% End of file"
      close $f
   }
}

proc rExportBNG { myid } {
   global installdir encfnm

   set rwin ".roman$myid"
   set efn [getFileName "bwedit: export file name"]
   if { [string compare $efn ""] != 0 } {
      set bwconvout [exec $installdir/bin/bwconv Bs [$rwin.mainfr.editfr.textarea get 1.0 end] $encfnm 2>/dev/null]
      set tagidx [string last "english :" $bwconvout]
      if {($tagidx >= 0)} {
         exec echo [string range $bwconvout 0 [expr $tagidx - 2]] > $efn
         exec echo [string range $bwconvout $tagidx [expr [string length $bwconvout] - 1]] > $efn.tags
      }
   }
}

proc rExportISCII { myid } {
   global installdir encfnm

   set rwin ".roman$myid"
   set efn [getFileName "bwedit: export file name"]
   if { [string compare $efn ""] != 0 } {
      set bwconvout [exec $installdir/bin/bwconv Is [$rwin.mainfr.editfr.textarea get 1.0 end] $encfnm 2>/dev/null]
      exec echo $bwconvout > $efn
   }
}

proc rExportPS { myid } {
   global rfname efname pt pageheight textheight xoffset yoffset psfontfile installdir encfnm

   set rwin ".roman$myid"
   if { [string compare $rfname($myid) ""] != 0 } {
      set dotindex [string last "." $rfname($myid)]
      incr dotindex -1
   } else {
      set dotindex -1
   }
   if {$dotindex >= 0} {
      set efname [string range $rfname($myid) 0 $dotindex]
      set efname "$efname.ps"
   } else {
      set efname "$rfname($myid).ps"
   }
   set pt 12
   set pageheight 29.7
   set textheight 24.7
   set xoffset 2.5
   set yoffset 2.5
   set efn [getPSFileName]
   if { [string compare $efn ""] != 0 } {
      set f [open $efn w]
      puts $f "%!PS-Adobe-2.0"
      puts $f "%%Title: Exported from $rfname($myid)"
      puts $f "%%Creator: bwedit version 3.0"
      puts $f "%%CreationDate: [exec date]"
      puts $f "%%Pages: (atend)"
      puts $f "%%PageOrder: Ascend"
      puts $f "%%BoundingBox: 0 0 596 842"
      puts $f "%%DocumentFonts: "
      puts $f "%%DocumentPaperSizes: a4"
      puts $f "%%EndComments"

      set ff [open $psfontfile r]
      set x [read $ff]
      puts $f $x
      close $ff

      set bwconvflags "Ps+$pt,$textheight,$xoffset,$yoffset,$pageheight"
      puts $f [exec $installdir/bin/bwconv $bwconvflags [$rwin.mainfr.editfr.textarea get 1.0 end] $encfnm 2>/dev/null]
      close $f
   }
}

########################     End of typeconv.tcl    ##########################

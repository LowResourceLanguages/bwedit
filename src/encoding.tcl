############################################################################
# encoding.tcl: Routines for converting strings between bwfu and unicode
#               encodings. Needed only if the flag newTclTk is on
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

# Initialize encoding table
for {set i 1} {$i <= 255} {incr i} { set bwfuenc($i) [expr $i + 256] }
set bwfuenc(0) 0
set bwfuenc(9) 9
set bwfuenc(10) 10
set bwfuenc(11) 11
set bwfuenc(12) 12
set bwfuenc(13) 13
set bwfuenc(160) 160

# Convert strings from bwfu (8-bit) to Unicode (16-bit) encoding
proc encfrom {ipstr} {
   global bwfuenc

   set opstr ""
   set iplen [string length $ipstr]
   for {set i 0} {$i < $iplen} {incr i} {
      scan [string range $ipstr $i $i] "%c" nextchar
      if {($nextchar <= 255)} { set nextchar $bwfuenc($nextchar) }
      append opstr [format "%c" $nextchar]
   }
   return $opstr
}

# Convert strings from unicode (16-bit) to bwfu (8-bit) encoding
proc encto {ipstr} {
   set opstr ""
   set iplen [string length $ipstr]
   for {set i 0} {$i < $iplen} {incr i} {
      scan [string range $ipstr $i $i] "%c" nextchar
      if {($nextchar >= 256)} { set nextchar [expr $nextchar - 256] }
      append opstr [format "%c" $nextchar]
   }
   return $opstr
}

########################     End of encoding.tcl    ##########################

############################################################################
# global.tcl: Defines some global parameters
# Author: Abhijit Das (Barda) [ad_rab@yahoo.com]
# Last updated: July 03 2002
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

set fntprobe [ exec xlsfonts ]
if {[regexp "bengali" $fntprobe] == 0} {
   puts "\nERROR: Font not found ...."
   puts "I cannot detect Bengali fonts in your system."
   puts "First load the fonts and then run bwedit.\n"
   exit -1;
}
unset fntprobe
set fontlist [ exec xlsfonts | grep -v bengali]
set fontlist [ split $fontlist "\n" ]
set scriptlist [ list suptag supsuptag subsuptag subtag subsubtag supsubtag ]

set appbg "#d3d3d3"
set appfg "#000000"
set btnbg "#a9a9a9"
set btnfg "#000000"
set blnbg "#ffffaa"
set blnfg "#000000"

set psfontfile "$installdir/lib/bnr.gsf"

image create photo bweditlogo -file "$installdir/images/bwedit-logo.ppm"

########################     End of global.tcl    ##########################

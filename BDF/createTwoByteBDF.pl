#!/usr/bin/perl -w
#############################################################################
# This perl script relocates some characters in the original bdf files
# to encoding positions higher than 255. This relocation was necessary
# to get rid of a display bug in bwedit under Tcl/Tk Versions 8.1 and
# above.
#############################################################################

foreach $fname ("bnr10.100","bnr10.120","bnr10.150","bnr10.180","bnr10.210","bnr10.250","bnr10.300","bnr10.360",
   "bnsl10.100","bnsl10.120","bnsl10.150","bnsl10.180","bnsl10.210","bnsl10.250","bnsl10.300","bnsl10.360") {

   $ifname = $fname . ".bdf";
   $ofname = $ifname; $ofname =~ s/bnr/bn2r/; $ofname =~ s/bnsl/bn2sl/;
   print "Converting $ifname to $ofname...\n";
   open(INF,"<$ifname");
   open(OUTF,">$ofname");
   while (defined($line = <INF>)) {
      chop $line;
      if ($line =~ /^FONT -\S-bengali-medium-(\S)-(.+)-(\d+)-(.+)$/) {
         print OUTF "FONT -*-bengali2-medium-$1-*-*-*-$3-*-*-*-*-iso10646-1\n";
      } elsif ($line =~ /^STARTCHAR C(\d+)$/) {
         $enc = $1 + 256;
         # if ( ($enc < 32) || (($enc >= 127) && ($enc <= 160)) ) { $enc += 256; }
         print OUTF "STARTCHAR C$enc\n";
      } elsif ($line =~ /^ENCODING (\d+)$/) {
         $enc = $1 + 256;
         # if ( ($enc < 32) || (($enc >= 127) && ($enc <= 160)) ) { $enc += 256; }
         print OUTF "ENCODING $enc\n";
      } elsif ($line eq "STARTPROPERTIES 3") {
          print OUTF "STARTPROPERTIES 4\n";
      } elsif ($line eq "ENDPROPERTIES") {
          print OUTF "DEFAULT_CHAR 319\nENDPROPERTIES\n";
      } else { print OUTF "$line\n"; }
   }
   close(INF);
   close(OUTF);
}

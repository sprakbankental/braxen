#!/usr/bin/perl -w

#**************************************#
# Convert between Braxen's internal 
# transcription alphabet and IPA
#
# encode (Braxen2IPA) or decode (IPAtoBraxen)
#

# perl <path>/braxen_conversion.pl <encode|decode> <infile> <outfile>
#
# 2025-02-27
#**************************************#

use Test::More;
use Test::Class;

# SBTal boilerplate
use strict;
use utf8;
use autodie;
use warnings;
use warnings	qw< FATAL  utf8 >;
use open	qw< :std  :utf8 >;	 # Should perhaps be :encoding(utf-8)?
use charnames	qw< :full :short >;	# autoenables in v5.16 and above
use feature	qw< unicode_strings >;
no feature	qw< indirect >;
use feature	qw< signatures >;
no warnings	qw< experimental::signatures >;

#**************************************************************#
my $outfile = "t/data/ipa_out.txt";
my $cmd = qq(perl scripts/braxen_conversion.pl encode t/data/base_in.txt $outfile );
system( $cmd ) == 0 or die "Failed to run braxen_conversion.pl: $!";
open my $fh_sv, $outfile or die $!;
my $saved_content = do{ local $/; <$fh_sv> };
close $fh_sv;
ok( $saved_content =~ /vrʊ.bˈ́ɛv.skɪ/ );


$outfile = "t/data/base_out.txt";
$cmd = qq(perl scripts/braxen_conversion.pl decode t/data/ipa_in.txt $outfile );
system( $cmd ) == 0 or die "Failed to run braxen_conversion.pl: $!";
open my $fh_2, $outfile or die $!;
$saved_content = do{ local $/; <$fh_2> };
close $fh_2;
ok( $saved_content =~ /m y: \. n \"o: \. v ,a/ );

done_testing();



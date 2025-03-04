#!/usr/bin/perl -w

#**************************************************************#
# ipa (Braxen) validation (Swedish)
#
# Validate Braxen pronunciations
#
# perl <path>/validate_ipa.pl <infile> <outfile>
#
#**************************************************************#
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

my $infile = "t/data/ipa_in.txt";
my $outfile = "t/data/ipa_valid.txt";
my $cmd = qq(perl scripts/validate_ipa.pl $infile $outfile );
system( $cmd ) == 0 or die "Failed to run validate_ipa.pl: $!";
open my $fh_valid, $outfile or die $!;
my $saved_valid = do{ local $/; <$fh_valid> };
close $fh_valid;
ok( $saved_valid =~ /VALID/ );


$infile = "t/data/ipa_test.txt";
$outfile = "t/data/ipa_invalid.txt";
$cmd = qq(perl scripts/validate_ipa.pl $infile $outfile );
system( $cmd ) == 0 or die "Failed to run validate_ipa.pl: $!";
open my $fh_invalid, $outfile or die $!;
my $saved_invalid = do{ local $/; <$fh_invalid> };
close $fh_invalid;
ok( $saved_invalid =~ /Symbol is not valid/ );
done_testing();
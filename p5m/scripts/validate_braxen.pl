#!/usr/bin/perl -w

#**************************************************************#
# Base (Braxen) validation (Swedish)
#
# Validate Braxen pronunciations
#
# perl <path>/validate_braxen.pl <infile> <outfile>
#
#**************************************************************#
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
my %valid = ();

my( $infile, $outfile ) = @ARGV;

if ( @ARGV < 1 ) {
	print "ERROR Usage:\t$0 <infile> <outfile>\n";
	exit 1;
}

open my $fh, '<', $infile or die();
open my $fh_out, '>', $outfile or die();
while(<$fh>) {
	chomp;
	s/[\r\n]//g;
	my $line = $_;
	my $ret = validate( $line, $line, 'sv' );
	print $fh_out "$line	$ret";
}
close $fh;
#**************************************************************#
# base
sub validate {
	my( $self, $i, $lang ) = @_;

	if( not(defined( $lang ))) {
		$lang = 'sv';
	}

	&read_table();
	my $schwa = 'ex';

	my @ret = ();

	# Split	on word boundaries
	my @words = split/ \| /, $i;

	foreach my $word ( @words ) {

		#print STDERR "word $word\n";

		my @phonemes = split' ', $i;
		my @cv = ();
		#****************************************************************#
		# Symbols
		foreach my $p ( @phonemes ) {
			my $pp = $p;
			my $stress = 0;
			$stress = 1 if $pp =~ s/[\'\",]//g;
			if( not( exists( $valid{ $pp } ))) {
				push @ret, "Symbol is not valid: $pp\n";
			} else {
				# Unstressable phone
				if( $stress == 1 ) {
					if( $valid{ $pp } ne 'v' ) {
						push @ret, "Unstressable phone: $word	$p\n";
					}
					if( $p =~ /[\'\"]$schwa/ ) {
						push @ret, "Schwa cannot have main stress: $word	$p\n";
					}
				}
				push @cv, $valid{ $pp };
			}
		}
		#****************************************************************#
		# Stress
		# Illegal stress placement
		if( $word =~ /[\'\",] / ) {
			push @ret, "Illegal stress placement: $word\n";
		}

		# Multiple stress markers
		if( $word =~ /[\'\,].*[\'\"\,]/ ) {
			push @ret, "Multiple stress markers: $word\n";
		}

		# No main stress
		if( $word !~ /[\'\"]/ && $word !~ /^(g rh l|rs|h m|p s t)$/ ) {
			push @ret, "No main stress: $word\n";
		}

		# No secondary stress
		if( $word =~ /\"/ && $word !~ /,/ && $lang ne 'en' ) {
			push @ret, "No secondary stress: $word\n";
		}

		# Illegal accent 2 in English
		if( $lang eq 'en' && $word =~ /\"/ ) {
			push @ret, "Illegal stress, accent 2 in English word: $word\n";
		}

		#****************************************************************#
		# Boundaries
		my $cv = join' ', @cv;

		# Missing boundary
		if( $cv =~ /v [^b]+ v/ ) {
			push @ret, "Missing boundary: $word\n";
		}

		# Adjacent boundaries
		if( $cv =~ /b b/ ) {
			push @ret, "Adjacent boundaries: $word\n";
		}
		#****************************************************************#

	}

	my $ret = "VALID\n";
	if( $#ret > -1 ) {
		$ret = join' ', @ret;
	}
	return "$ret";
}
#**************************************************************#
sub read_table {
	while(<DATA>) {
		chomp;
		s/[\r\n]//g;
		next if /\#/;
		my( $base, $cv ) = split/\t/;
		$valid{ $base } = $cv;
	}
	return 1;
}
#**************************************************************#
1;
__DATA__
# Base
# Phonemes
p	c
b	c
t	c
rt	c
d	c
rd	c
k	c
g	c
f	c
v	c
s	c
rs	c
sh	c
zh	c
z	c
dh	c
th	c
h	c
x	c
xx	c
c	c
tc	c
dj	c
m	c
n	c
rn	c
ng	c
r	c
l	c
rl	c
j	c
w	c
rh	c
r0	c
rx	c
i:	v
i	v
ih	v
y:	v
y	v
e:	v
e	v
eh	v
ex	v
ä:	v
ä	v
ae:	v
ae	v
ö:	v
ö	v
oe:	v
oe	v
u:	v
u	v
oh	v
o:	v
o	v
uu:	v
uu	v
uuh	v
uw:	v
uw	v
a:	v
a	v
aa:	v
au	v
eu	v
ei	v
ai	v
oi	v
ou	v
eex	v
iex	v
uex	v
an	v
en	v
on	v
un	v
# Stress
'	s
"	s
,	s
# Boundaries
.	b
-	b
~	b
|	b

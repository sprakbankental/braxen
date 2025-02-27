#!/usr/bin/perl -w

#**************************************************************#
# IPA validation (Swedish)
#
# Validate IPA pronunciations
#
# perl <path>/validate_ipa.pl <infile> <outfile>
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
sub validate {
	my( $self, $i ) = @_;

	&read_table();
	my $schwa = 'ə';

	my @ret = ();

	# Split	on word boundaries
	my @words = split/ \| /, $i;

	foreach my $word ( @words ) {

		#print STDERR "word $word\n";

		# Split
		my @phonemes = $i =~ /(?:
			[ˈ̀́ˌ́]*						# Optional primary or secondary stress mark
			(?:
				aʊ|ɛʊ|eɪ|aɪ|ɔɪ|əʊ|eə|ɪə|ʊə|		# Diphthongs
				t͡ʃ|d͡ʒ|\.|				# Affricates and syllable boundary
				[\p{L}\p{M}]				# Phoneme (letter) followed by optional combining marks
			)
			[ː]?						# Optional length mark
			[\p{M}]*					# Zero or more additional combining marks
		)/gx;

		my @cv = ();
		#****************************************************************#
		# Symbols
		foreach my $p ( @phonemes ) {
			my $pp = $p;
			my $stress = 0;
			$stress = 1 if $pp =~ s/(\ˈ́|\ˈ̀|\ˌ)//g;
			if( not( exists( $valid{ $pp } ))) {
				push @ret, "Symbol is not valid: $pp\n";
			} else {
				# Unstressable phone
				if( $stress == 1 ) {
					if( $valid{ $pp } ne 'v' ) {
						push @ret, "Unstressable phone: $word	$p\n";
					}
					if( $p =~ /(\ˈ́|\ˈ̀)$schwa/ ) {
						push @ret, "Schwa cannot have main stress: $word	$p\n";
					}
				}
				push @cv, $valid{ $pp };
			}
		}
		#****************************************************************#
		# Stress
		# Illegal stress placement
		if( $word =~ /(\ˈ́|\ˈ̀|\ˌ) / ) {
			push @ret, "Illegal stress placement: $word\n";
		}

		# Multiple stress markers
		if( $word =~ /(\ˈ́|\ˌ).*(\ˈ́|\ˈ̀|\ˌ)/ ) {
			push @ret, "Multiple stress markers: $word\n";
		}

		# No main stress
		if( $word !~ /[\ˈ́\ˈ̀]/ ) {
			push @ret, "No main stress: $word\n";
		}

		# No secondary stress
		if( $word =~ /\ˈ̀/ && $word !~ /\ˌ/ ) {
			push @ret, "No secondary stress: $word\n";
		}
		#****************************************************************#
		# Boundaries
		my $cv = join' ', @cv;
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
		my( $tpa, $cv ) = split/\t/;
		$valid{ $tpa } = $cv;
	}
	return 1;
}
#**************************************************************#
1;
__DATA__
# IPA
# Phonemes
IPA
p	c
b	c
t	c
ʈ	c
d	c
ɖ	c
k	c
ɡ	c
f	c
v	c
s	c
ʂ	c
ʃ	c
ʒ	c
z	c
ð	c
θ	c
h	c
ɧ	c
x	c
ç	c
t͡ʃ	c
d͡ʒ	c
m	c
n	c
ɳ	c
ŋ	c
r	c
l	c
ɭ	c
j	c
w	c
ɾ	c
ʀ	c
iː	v
ɪ	v
ɪ̯	v
yː	v
ʏ	v
eː	v
e	v
e̝	v
ə	v
ɛː	v
ɛ	v
æː	v
æ	v
øː	v
ø	v
œː	v
œ	v
uː	v
u	v
o	v
oː	v
ɔ	v
ʉː	v
ɵ	v
ʉ	v
ʊː	v
ʊ	v
ɑː	v
a	v
aː	v
aʊ	v
ɛʊ	v
eɪ	v
aɪ	v
ɔɪ	v
əʊ	v
eə	v
ɪə	v
ʊə	v
ã	v
ɛ̃	v
õ	v
œ̃	v
ɶ	v
g	c
ɶː	v
ɕ	c
# Stress
ˈ́	s
ˈ̀	s
ˌ	s
# Boundaries
.	b

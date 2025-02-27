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

my( $convert, $infile, $outfile ) = @ARGV;

if ( @ARGV < 1 ) {
	print "ERROR Usage:\t$0 <convert> <infile> <outfile>\n";
	exit 1;
}
if( $convert !~ /(decode|encode)/i ) {
	warn "first arg must be decode or encode\n";
}

&read_table();

my $dummy;

open my $fh, '<', $infile or die();
open my $fh_out, '>', $outfile or die();
while(<$fh>) {
	chomp;
	s/[\r\n]//;
	my $in = $_;
	my $out;
	
	if( $convert =~ /encode/i ) {
		$out = encode( $dummy, $in );
	} elsif( $convert =~ /decode/i ) {
		$out = decode( $dummy, $in );
	}
	print $fh_out "$out\n";
}
close $fh;
close $fh_out;
#**************************************************************#
# IPA conversion (Swedish)
#
# Convert from IPA to Braxen format
#
#**************************************************************#
my %base2ipa = ();
my %ipa2base = ();
#**************************************************************#
# base2ipa

sub encode {
	my( $self, $i ) = @_;

	# IPA doesn't have a symbol for compound break:
	# replace Base compound/morpheme/word break to syllable break '.' before conversion.
	$i =~ s/[-\~\|]/\./g;

	# Split
	my @phonemes = split' ', $i;
	my @ipa = ();

	foreach my $p ( @phonemes ) {
		my $add_stress = 'void';

		next if $p eq 'r0';		# IPA does not have a match for /r0/

		# Remove and save stress
		if( $p =~ s/^\'// ) {
			$add_stress = 'ˈ́';
		} elsif ( $p =~ s/^\"// ) {
			$add_stress = 'ˈ̀';
		} elsif( $p =~ s/^,// ) {
			$add_stress = 'ˌ';
		}

		my $ipa;

		# Lookup and add stress
		if( exists( $base2ipa{ $p } )) {
			$ipa = $base2ipa{ $p };
			
			if( $add_stress ne 'void' ) {
				$ipa = $add_stress . $ipa;
			}
			push @ipa, $ipa;
		} else {
			warn "No match for $p\n";
		}
		#print STDERR "encode $p	$ipa\n";
	}

	my $ret = join'', @ipa;

	# TODO: Validate

	return "$ret";
}
#**************************************************************#
# ipa2base
sub decode {
	my( $self, $i ) = @_;

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

	my @base = ();

	foreach my $p ( @phonemes ) {

		my $add_stress = 'void';

		# Remove and save stress
		if( $p =~ s/^ˈ́// ) {
			$add_stress = "\'";
		} elsif ( $p =~ s/^ˈ̀// ) {
			$add_stress = '"';
		} elsif( $p =~ s/^ˌ// ) {
			$add_stress = ',';
		}

		my $base;

		# Lookup and add stress
		if( exists( $ipa2base{ $p } ) || $p =~ /^(y|œː|ɶː|œ|ɶ)$/ ) {
			
			if( exists( $ipa2base{ $p } )) {
				$base = $ipa2base{ $p };
			
			# These are special for e.g. Microsoft Swedish voices.
			} elsif ( $p eq 'y' ) {
				$base = 'y';
			} elsif ( $p =~ /^(œː|ɶː)/ ) {
				$base = 'oe:';
			} elsif ( $p =~ /^(œ|ɶ)/ ) {
				$base = 'oe';
			}
			
			if( $add_stress ne 'void' ) {
				$base = $add_stress . $base;
			}
			push @base, $base;
		} else {
			warn "No match for $p	$i\n";
		}
	}

	my $ret = join' ', @base;

	# TODO: Validate

	return "$ret";
}
#**************************************************************#
sub read_table {
	while(<DATA>) {
		chomp;
		s/[\r\n]//g;
		next if /\#/;
		my( $base, $ipa ) = split/\t/;
		$base2ipa{ $base } = $ipa;
		$ipa2base{ $ipa } = $base;
	}
	return 1;
}
#**************************************************************#
1;
__DATA__
# Base	IPA
# Note that some diacritics does not show properly in the table,
# e.g. the desyllabification diatritic for /ih/.
p	p
b	b
t	t
rt	ʈ
d	d
rd	ɖ
k	k
g	ɡ
g	g
f	f
v	v
s	s
rs	ʂ
sh	ʃ
zh	ʒ
z	z
dh	ð
th	θ
h	h
x	ɧ
xx	x
c	ɕ
tc	t͡ʃ
dj	d͡ʒ
m	m
n	n
rn	ɳ
ng	ŋ
r	r
l	l
rl	ɭ
j	j
w	w
rh	ɾ
r0	r0
rx	ʀ
i:	iː
i	ɪ
ih	ɪ̯
y:	yː
y	ʏ
e:	eː
e	e
eh	e̝
ex	ə
ä:	ɛː
ä	ɛ
ae:	æː
ae	æ
ö:	øː
ö	ø
oe:	ɶː
oe	ɶ
u:	uː
u	u
oh	o
o:	oː
o	ɔ
uu:	ʉː
uu	ɵ
uuh	ʉ
uw:	ʊː
uw	ʊ
a:	ɑː
a	a
aa:	aː
au	aʊ
eu	ɛʊ
ei	eɪ
ai	aɪ
oi	ɔɪ
ou	əʊ
eex	eə
iex	ɪə
uex	ʊə
an	ã
en	ɛ̃
on	õ
un	œ̃
.	.
# Stress
#\ˈ́	\'
#\ˈ̀	\"
#\ˌ	,
# Boundaries
#.	.

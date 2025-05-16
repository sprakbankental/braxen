package SBTal::Braxen;

# SBTal boilerplate
use v5.32;
use utf8;
use strict;
use autodie;
use warnings;
use warnings  qw< FATAL  utf8 >;
use open      qw< :std  :utf8 >;     # Should perhaps be :encoding(utf-8)?
use charnames qw< :full :short >;    # autoenables in v5.16 and above
use feature   qw< unicode_strings >;
no feature qw< indirect >;
use feature qw< signatures >;
## Avoid criticism for eternally experimental signatures
## https://github.com/Perl/perl5/issues/18537
no warnings qw< experimental::signatures >;

use Carp    qw< carp croak confess cluck >;
use English qw( -no_match_vars );

use version 0.77; our $VERSION = version->declare('v1.0.0');

use constant SBTAL_P5M_DEV => !!$ENV{SBTAL_P5M_DEV};

#use Unicode::Collate;
use TOML::Tiny;

sub new ($proto) {
	my $class = ref($proto) || $proto;
	my $self = bless {}, $class;
	$self->initdata();  # Load field specifications from __DATA__

#		NB! This is what we should be doing for order... but something fails
#   NB! so we use standard cmp instead for now		
#		$self->{collator} = Unicode::Collate->new( 
#			level => 4, 
#			normalization => undef, 
#			variable => 'shifted' ,
#		);
	
	return $self;
}

# In this version, we're loading 
# the braxen format specifification from 
# the __DATA__ section. 
# It is however well-formed TOML, and
# limited to two levels, so will be easy to
# transfer to standard SBTal configuration. 
sub initdata ($self) {
	local $/;  # Enable 'slurp' mode to read the entire DATA section
	my $toml = <DATA>;
    
	my $parser = TOML::Tiny->new;
	my $spec = $parser->decode($toml);

  my $fields = scalar @{ $spec->{spec} };

	croak "Field count mismatch: expected $spec->{meta}{fields}, found $fields"
		if $spec->{meta}{fields} != $fields;		
	$self->{fieldspec} = $spec->{spec};
	$self->{fieldcount} = $fields;

#		use Data::Dumper; print STDERR Dumper $spec;
#		exit;
		return $self;
}

sub load_tsv ($self, $filename) {
	$filename || croak "No filename provided";
	# Ensure the file exists and is readable
	croak "File '$filename' does not exist" unless -e $filename;
	croak "File '$filename' is not readable" unless -r $filename;

	# Open the file with UTF-8 handling
	open my $fh, '<:encoding(UTF-8)', $filename
		or croak "Could not open file '$filename': $!";
	my $stats;
	my @comments;  # Local storage for comment lines
	my $previousline = '';  # Keep track of the last non-comment line
	my @data;	# Local storage for valid data lines
	while ( my $line = <$fh> ) {
		
		# Ensure UTF8
		croak "File '$filename' contains invalid UTF-8 characters"
			unless utf8::valid($line);

		chomp $line;
		# Count total number of lines
		$stats->{lines}++; 
		last if $stats->{lines} > 10;

		# Check for comment lines (assuming comments start with #)
		if ( $line =~ /^\s*#/ ) {
			$stats->{comments}++;
			push @comments, [$stats->{lines}, $line];
			next;  # Skip further processing for this line
		}

		# Sorting validation using Unicode::Collate
#   NB! This is what we should be doing for order... but see constructor
#		use Data::Dumper;
#		if ($self->{collator}->cmp($previousline, $line) > 0) {
#				warn "SORT DEBUG: '$previousline' > '$line'\n";
#				warn "Collation keys:\n";
#				warn "  PREV: " . Dumper($self->{collator}->getSortKey($previousline));
#				warn "  CURR: " . Dumper($self->{collator}->getSortKey($line));
#				croak "File is not sorted at line $stats->{lines}: '$line' appears after '$previousline'";
#		}
		croak "File is not sorted at line $stats->{lines}: '$line' appears after '$previousline'"
			if ($previousline cmp $line) > 0;

		$previousline = $line;  # Update reference

		# Split the line into fields based on tab characters
		my @fields = split /\t/, $line, -1;  # -1 ensures trailing empty fields are included

		# Validate the number of fields
		my $expected_fields = $self->{fieldcount} // scalar @fields;
		croak "Line $stats->{lines} has " . scalar(@fields) . " fields; expected $expected_fields"
			if scalar(@fields) != $expected_fields;

		# Store the valid data line
		push @data, \@fields;

	}
	close $fh;
	$self->{stats} = $stats;
	$self->{comments} = \@comments;
	$self->{data} = \@data;
	return;
}

sub load_storable ($self, $filename) {
	croak "Not implemented";
}

sub save_tsv ($self, $filename) {
	croak "Not implemented";
}

sub save_storable ($self, $filename) {
	croak "Not implemented";
}

sub statistics ($self) {
	croak "Not implemented";
}

sub print_statistics ($self) {
	use Data::Dumper;
	print STDERR Dumper $self->{stats}
}



1;

=pod

=encoding utf-8

=head1 NAME

SBTal::Braxen - core module for handling pronunciation lexicon resources

=head1 SYNOPSIS

	use SBTal::Braxen;

	my $braxen = SBTal::Braxen->new();
	braxen->load_tsv("lexicon.tsv");
	$braxen->save_storable("lexicon.storable");

	my $pronunciation = $braxen->lookup("example");

=head1 DESCRIPTION

C<SBTal::Braxen> provides an interface for 
handling pronunciation lexicon resources. 
It facilitates reading, storing, and 
converting lexicon data between different formats.

=head1 METHODS

=head2 new

	my $braxen = SBTal::Braxen->new();

Creates a new C<SBTal::Braxen> instance.

=head2 load_tsv

$braxen->load_tsv($filename);

Loads a Braxen pronunciation lexicon from 
a tab-separated values (TSV) file.  
The TSV file is expected to contain Braxen compatible, structured data with 
word-pronunciation mappings.

This specific method will be replaced by 
a more general method in the future,
but can be used for testing and will not be removed without
a major version change.

=head2 load_storable

	$braxen->load_storable($filename);

Loads a Braxen pronunciation lexicon from a binary file
using L<Storable>.

This specific method will be replaced by
a more general method in the future,
but can be used for testing and will not be removed without
a major version change.

=head2 save_tsv

	$braxen->save_tsv($filename);

Saves the lexicon to a tab-separated values (TSV) file.

This specific method will be replaced by
a more general method in the future,
but can be used for testing and will not be removed without
a major version change.

=head2 save_storable

	$braxen->save_storable($filename);

Saves the lexicon to a binary format using L<Storable>.  
This allows efficient loading and storage of lexicon data.

This specific method will be replaced by
a more general method in the future,
but can be used for testing and will not be removed without
a major version change.

=head2 statistics

	my %stats = $braxen->statistics;

Returns a hash with statistics about the lexicon data.

=head2 print_statistics

	$braxen->print_statistics;

Prints statistics about the lexicon data to STDERR.

This is a convenience method that calls C<statistics> and 
prints the results. 
It should not be used in production code.

=head1 INTERNAL STRUCTURE

C<SBTal::Braxen> integrates with 
the pronunciation manager C<SBTal::Braxen::Pron>, which 
provides access to 
the phoneme representation C<Base>, which allows for 
standardised processing and format conversion.

=head1 FUTURE EXTENSIONS

Planned future extensions include:

- Support for additional input and output formats beyond TSV and Storable.
- Expanded functionality for handling non-pronunciation lexicon data.
- Online data access as a standalone or networked microservice

=head1 SEE ALSO

L<SBTal::Braxen::Pron>, L<SBTal::Braxen::Decoder>, L<SBTal::Braxen::Encoder>

=head1 AUTHOR

Jens Edlund <edlund@speech.kth.se>

=head1 LICENSE


Copyright 2025 Jens Edlund
Copyright 2025 Språkbanken Tal
Copyright 2025 Swedish Agency for Accessible Media

	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.

=cut

__DATA__
# TOML version 1.0 
# https://toml.io/en/v1.0.0
meta = { "version" = "1.0.0", "fields" = 27 }

spec = [
	["Orthography", "ort"],
	["Pronunciation", "Description of field2"],
	["POS", "Part of speech and morphology"],
	["3", "Description of field3"],
	["4", "Description of field4"],
	["5", "Description of field5"],
	["6", "Description of field6"],
	["7", "Description of field7"],
	["8", "Description of field8"],
	["9", "Description of field9"],
	["10", "Description of field10"],
	["11", "Description of field11"],
	["12", "Description of field12"],
	["13", "Description of field13"],
	["14", "Description of field14"],
	["15", "Description of field15"],
	["Case", "Caae sensitivity"],
	["17", "Description of field17"],
	["18", "Description of field18"],
	["19", "Description of field19"],
	["20", "Description of field20"],
	["21", "Description of field21"],
	["22", "Description of field22"],
	["23", "Description of field23"],
	["24", "Description of field24"],
	["25", "Description of field25"],
	["ID", "Unique ID of the entry"]
]


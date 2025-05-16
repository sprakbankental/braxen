package Braxen::Decoder;

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
no warnings qw< experimental::signatures >;

use Carp qw< carp croak confess cluck >;

use version 0.77; our $VERSION = version->declare('v0.1.0');

sub new ($proto, $params) {
	my %params = %$params;
	my $class = ref($proto) || $proto;

	my $self = bless {%params}, $class;
	return $self;
}

sub file ($self, $params) {
	my %params = %$params;
		$self->{file} = $params{file};
		return $self;
}

1;

__END__


=pod

=encoding utf-8

=head1 NAME

Braxen::Decoder - A simple Braxen decoder

=head1 VERSION

This document describes Braxen::Decoder version v0.1.0

=head1 SYNOPSIS

	use Braxen::Decoder;

	my $braxen = Braxen::Decoder->new();

=head1 DESCRIPTION

This module provides a simple Braxen decoder.

=head1 METHODS

=head2 new

	my $braxen = Braxen::Decoder->new();


=head2 decode

	my $decoded = $braxen->decode($data);

=head1 DIAGNOSTICS

=over

=item C<< Error message here, perhaps with %s placeholders >>

Explanation here.

=back

=head1 CONFIGURATION AND ENVIRONMENT

SBTal::Braxen requires no configuration files or environment variables.

=head1 DEPENDENCIES

=over

=item * L<version>

=item * L<Carp>

=item * L<SBTal::Braxen::Encoder>

=item * L<SBTal::Braxen::Decoder>

=back

=head1 INCOMPATIBILITIES

None reported.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

=head1 AUTHOR

SBTal::Braxen was written by Christina Tånnander. 
It has been refactored by Jens Edlund.


=cut








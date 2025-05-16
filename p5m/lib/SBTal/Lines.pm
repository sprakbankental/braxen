package SBTal::Lines;

1;

=pod

=head1 NAME

SBTal::Lines - A Perl module for categorizing, parsing, and reconstructing line-based data structures.

=head1 SYNOPSIS

  use SBTal::Lines;

  my $processor = SBTal::Lines->new(
      line_types => [
          {
              name          => 'comment',
              match_sub     => sub { $_[0] =~ /^#/ },
              parse_sub     => sub { chomp($_[0]); return (1, $_[0]); },
              recompose_sub => sub { return $_[0] . "\n"; },
          },
          {
              name          => 'data',
              match_sub     => sub { $_[0] !~ /^#/ },
              parse_sub     => sub { chomp($_[0]); my @fields = split /\t/, $_[0]; return (scalar @fields == 3, \@fields); },
              recompose_sub => sub { return join("\t", @{$_[0]}) . "\n"; },
          },
          {
              name          => '__default',
              match_sub     => sub { 1 },
              parse_sub     => sub { return (1, $_[0]); },
              recompose_sub => sub { return $_[0]; },
          },
      ]
  );

  $processor->process_lines(@lines);
  my @reconstructed = $processor->reconstruct_lines();

=head1 DESCRIPTION

SBTal::Lines is a Perl module designed to facilitate the processing of line-based data structures, such as text files or lists. It categorizes each line based on user-defined criteria, allowing for tailored parsing and reconstruction of the data. This modular approach ensures flexibility, maintainability, and adherence to Perl Best Practices (PBP) and Språkbanken Tal coding guidelines.

=head1 FEATURES

=over 4

=item * Line Categorization

Each line is assigned a category based on user-defined matching subroutines, enabling specific processing rules for different types of lines.

=item * Customizable Parsing and Reconstruction

For each category, users can define parsing and reconstruction subroutines, allowing tailored processing during both decomposition (parsing) and composition (reconstruction) phases.

=item * Default Handling

Lines that do not match any user-defined category are assigned to a default category (C<__default>), ensuring all lines are accounted for without exhaustive matching rules.

=back

=head1 DESIGN DETAILS

=over 4

=item * Object-Oriented Approach

The module employs an object-oriented design, enhancing code organization and reusability.

=item * Line Type Definitions

Users can define multiple line types, each with:

=over 4

=item - name

A unique identifier for the line type.

=item - match_sub

A subroutine that determines if a line belongs to this type.

=item - parse_sub

A subroutine that processes the line content upon categorization, returning a boolean indicating success and the parsed content. Defaults to a no-operation subroutine if not provided.

=item - recompose_sub

A subroutine that defines how to reconstruct the line during output, operating on the parsed content. Defaults to returning the parsed content as-is if not provided.

=back

=item * Data Storage

The module maintains an internal structure to store lines along with their associated types and parsed content, supporting efficient processing and reconstruction.

=back

=head1 METHODS

=over 4

=item * new

  my $processor = SBTal::Lines->new(line_types => \@line_types);

Constructor that initializes the object and sets up internal data structures. Accepts an array reference of line type definitions.

=item * process_lines

  $processor->process_lines(@lines);

Accepts an array of lines, categorizes each line using the defined matching subroutines, and stores the parsed content accordingly. Utilizes internal methods C<_match_line> and C<_parse_line> for matching and parsing operations.

=item * reconstruct_lines

  my @reconstructed = $processor->reconstruct_lines();

Reconstructs the lines based on their types using the corresponding recomposition subroutines and returns the reconstructed data.

=back

=head1 INTERNAL METHODS

=over 4

=item * _match_line

  my $type = $self->_match_line($line);

Determines the type of a given line by evaluating it against the defined match_sub routines in order. Returns the name of the matching line type.

=item * _parse_line

  my ($is_valid, $parsed_content) = $self->_parse_line($line, $type);

Parses a given line based on its type using the corresponding parse_sub routine. Returns a boolean indicating if the parsing was successful and the parsed content.

=back

=head1 IMPLEMENTATION CONSIDERATIONS

=over 4

=item * Error Handling

Implement robust error handling to manage unexpected inputs or missing subroutines.

=item * Performance Optimization

Optimize the matching and parsing processes to handle large datasets efficiently.

=item * Documentation

Provide comprehensive documentation for each method, including usage examples and parameter descriptions, to facilitate user understanding and adoption.

=back

=head1 AUTHOR

Språkbanken Tal

=head1 LICENSE

This module is licensed under the same terms as Perl itself.

=cut

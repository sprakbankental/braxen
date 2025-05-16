package SBTal::Filter::Integer;

1;

=pod

=head1 NAME

SBTal::Filter::Integer - A Perl module for filtering integer sequences based on specified range specifications.

=head1 SYNOPSIS

  use SBTal::Filter::Integer;

  my $filter = SBTal::Filter::Integer->new(
      rangespec => [0, [10, 15], 19, [30, -1]]
  );

  while (my $item = $iterator->next) {
      if ($filter->monotonic($item)) {
          # Process $item
      }
  }

=head1 DESCRIPTION

SBTal::Filter::Integer is a Perl module designed to filter integer sequences based on user-defined range specifications. It allows for flexible definition of integer ranges and provides methods to determine if given integers fall within these specified ranges. This module adheres to Perl Best Practices (PBP) and Språkbanken Tal coding guidelines, ensuring modularity and maintainability.

=head1 FEATURES

=over 4

=item * Flexible Range Specification

Users can define ranges using a versatile syntax, allowing for individual positions (e.g., C<0>, C<19>) or inclusive ranges (e.g., C<[10, 15]>, C<[30, -1]>), where C<-1> denotes the last position in the sequence.

=item * Range Normalisation

The module normalises overlapping or contiguous ranges upon instantiation to optimise performance and ensure accurate range checking.

=item * Monotonic Sequence Filtering

Provides a method, C<monotonic>, specifically designed for efficiently filtering monotonically increasing integer sequences based on the defined ranges.

=back

=head1 DESIGN DETAILS

=over 4

=item * Object-Oriented Approach

The module employs an object-oriented design, enhancing code organisation and reusability.

=item * Range Specification

Ranges are specified during object instantiation via the C<rangespec> parameter, which accepts an array reference containing individual positions and/or array references defining inclusive ranges.

=item * Normalisation Process

Upon instantiation, the module normalises the provided ranges to merge overlapping or contiguous ranges, ensuring efficient in-range checking.

=item * Monotonic Filtering

The C<monotonic> method is optimised for monotonically increasing sequences, allowing for efficient determination of whether a given integer falls within the specified ranges.

=back

=head1 METHODS

=over 4

=item * new

  my $filter = SBTal::Filter::Integer->new(rangespec => \@ranges);

Constructor that initialises the object, normalises the provided ranges, and sets up internal data structures. Accepts an array reference of ranges as input.

=item * monotonic

  my $is_in_range = $filter->monotonic($position);

Checks if the given position falls within any of the normalised ranges in the context of a monotonically increasing sequence. Returns a boolean indicating the result.

=back

=head1 IMPLEMENTATION CONSIDERATIONS

=over 4

=item * Error Handling

Implement robust error handling to manage unexpected inputs or invalid range specifications.

=item * Performance Optimisation

Optimise the normalisation and in-range checking processes to handle large datasets efficiently.

=item * Documentation

Provide comprehensive documentation for each method, including usage examples and parameter descriptions, to facilitate user understanding and adoption.

=back

=head1 AUTHOR

Språkbanken Tal

=head1 LICENSE

This module is licensed under the same terms as Perl itself.

=cut

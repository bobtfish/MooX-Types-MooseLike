package MooX::Types::MooseLike::Base;
use strict;
use warnings FATAL => 'all';
use Scalar::Util qw(blessed);
use List::Util;
use MooX::Types::MooseLike;
use Exporter 5.57 'import';
our @EXPORT_OK = ();

# These types act like those found in Moose::Util::TypeConstraints.
# Generally speaking, the same test is used.
my $type_definitions = [
  {
    name => 'Any',
    test => sub { 1 },
    message =>
      sub { "If you get here you've achieved the impossible, congrats." }
  },
  {
    name => 'Item',
    test => sub { 1 },
    message =>
      sub { "If you get here you've achieved the impossible, congrats" }
  },
  {
    name    => 'Undef',
    test    => sub { !defined($_[0]) },
    message => sub { "$_[0] is not undef" }
  },

# Note the single quotes so $_[0] is not interpreted because undef and FATAL => 'all'
  {
    name    => 'Defined',
    test    => sub { defined($_[0]) },
    message => sub { '$_[0] is not defined' }
  },
  {
    name => 'Bool',

    #  	test    => sub { $_[0] == 0 || $_[0] == 1 },
    test => sub {
      !defined($_[0]) || $_[0] eq "" || "$_[0]" eq '1' || "$_[0]" eq '0';
      },
    message => sub { "$_[0] is not a Boolean" },
  },
  {
    name    => 'Value',
    test    => sub { !ref($_[0]) },
    message => sub { "$_[0] is not a value" }
  },
  {
    name    => 'Ref',
    test    => sub { ref($_[0]) },
    message => sub { "$_[0] is not a reference" }
  },
  {
    name => 'Str',
    test => sub { ref(\$_[0]) eq 'SCALAR' },
    message => sub { "$_[0] is not a string" }
  },
  {
    name    => 'Num',
    test    => sub { Scalar::Util::looks_like_number($_[0]) },
    message => sub { "$_[0] is not a Number!" },
  },
  {
    name => 'Int',

#  	test    => sub { Scalar::Util::looks_like_number($_[0]) && ($_[0] == int $_[0]) },
    test => sub { "$_[0]" =~ /^-?[0-9]+$/x },
    message => sub { "$_[0] is not an Integer!" },
  },

  # Maybe has no test for itself, rather only the parameter type does
  {
    name    => 'Maybe',
    test    => sub { 1 },
    message => sub { 'Maybe only uses its parameterized type message' },
    parameterizable => sub { return if (not defined $_[0]); $_[0] },
  },
  {
    name => 'ScalarRef',
    test => sub { ref($_[0]) eq 'SCALAR' },
    message => sub { "$_[0] is not an ScalarRef!" },
    parameterizable => sub { ${ $_[0] } },
  },
  {
    name => 'ArrayRef',
    test => sub { ref($_[0]) eq 'ARRAY' },
    message => sub { "$_[0] is not an ArrayRef!" },
    parameterizable => sub { @{ $_[0] } },
  },
  {
    name => 'HashRef',
    test => sub { ref($_[0]) eq 'HASH' },
    message => sub { "$_[0] is not a HashRef!" },
    parameterizable => sub { values %{ $_[0] } },
  },
  {
    name => 'CodeRef',
    test => sub { ref($_[0]) eq 'CODE' },
    message => sub { "$_[0] is not a CodeRef!" },
  },
  {
    name => 'RegexpRef',
    test => sub { ref($_[0]) eq 'Regexp' },
    message => sub { "$_[0] is not a RegexpRef!" },
  },
  {
    name => 'GlobRef',
    test => sub { ref($_[0]) eq 'GLOB' },
    message => sub { "$_[0] is not a GlobRef!" },
  },
  {
    name => 'FileHandle',
    test => sub {
      Scalar::Util::openhandle($_[0])
        || (blessed($_[0]) && $_[0]->isa("IO::Handle"));
      },
    message => sub { "$_[0] is not a FileHandle!" },
  },
  {
    name => 'Object',
    test => sub { blessed($_[0]) && blessed($_[0]) ne 'Regexp' },
    message => sub { "$_[0] is not an Object!" },
  },
  {
    name => 'AHRef',
    test => sub {
      (ref($_[0]) eq 'ARRAY')
        && ($_[0]->[0])
        && (List::Util::first { ref($_) eq 'HASH' } @{ $_[0] });
      },
    message => sub { "$_[0] is not an ArrayRef[HashRef]!" },
  },
  {
    name => 'InstanceOf',
    test => sub {
      my ($instance, $class) = (shift, shift);
      blessed($instance) && (ref($instance) eq $class);
      },
    message => sub { "$_[0] is not an instance of $_[1]!" },
  },
  {
    name => 'ConsumerOf',
    test => sub {
      my ($instance, @roles) = (shift, @_);
      return if (!$instance->can('does'));
      my @missing_roles = grep { !$instance->does($_) } @roles;
      return (scalar @missing_roles ? 0 : 1);
      },
    message => sub { 
      my $instance = shift;
      return "$instance is not a consumer of roles" if (!$instance->can('does'));
      my @missing_roles = grep { !$instance->does($_) } @_;
      my $s = (scalar @missing_roles) > 1 ? 's' : '';
      my $missing_roles = join ' ', @missing_roles;
      return "$instance does not consume the required role${s}: $missing_roles";
    },
  },
  {
    name => 'HasMethods',
    test => sub {
      my ($instance, @methods) = (shift, @_);
      my @missing_methods = grep { !$instance->can($_) } @methods;
      return (scalar @missing_methods ? 0 : 1);
      },
    message => sub {
      my $instance = shift;
      my @missing_methods = grep { !$instance->can($_) } @_;
      my $s = (scalar @missing_methods) > 1 ? 's' : '';
      my $missing_methods = join ' ', @missing_methods;
      return "$instance does not have the required method${s}: $missing_methods";
      },
  },
  ];

MooX::Types::MooseLike::register_types($type_definitions, __PACKAGE__);

# Export an 'all' tag so one can easily import all types like so:
# use MooX::Types::MooseLike::Base qw(:all)
our %EXPORT_TAGS = ('all' => \@EXPORT_OK);

1;

__END__

=head1 NAME

MooX::Types::MooseLike::Base - Moose like types for Moo

=head1 SYNOPSIS

    package MyPackage;
    use Moo;
    use MooX::Types::MooseLike::Base qw(:all);

    has "beers_by_day_of_week" => (
        isa => HashRef
    );
    has "current_BAC" => (
        isa => Num
    );

    # Also supporting is_$type.  For example, is_Int() can be used as follows
    has 'legal_age' => (
        is => 'ro',
        isa => sub { die "$_[0] is not of legal age"
        	           unless (is_Int($_[0]) && $_[0] > 17) },
    );

=head1 DESCRIPTION

Moo attributes (like Moose) have an 'isa' property.
This module provides some basic types for this property.
One can import all types with ':all' tag or import
a list of types like:

    use MooX::Types::MooseLike::Base qw/HashRef CodeRef/;

so one could then declare some attributtes like:

	has 'contact' => (
	  is => 'ro',
	  isa => HashRef,
	);
	has 'guest_list' => (
	  is => 'ro',
	  isa => ArrayRef,
	);
	has 'records' => (
	  is => 'ro',
	  isa => ArrayRef[Int],
	);

These types provide a check that the contact attribute is a hash reference,
that the guest_list is an array reference, and that the records are an array
of hash references.

=head1 TYPES (subroutines)

=head2 Any

Any type (test is always true)

=head2 Item

Synonymous with Any type

=head2 Undef

A type that is not defined

=head2 Defined

A type that is defined

=head2 Bool

A boolean 1|0 type

=head2 Value

A non-reference type

=head2 Ref

A reference type

=head2 Str

A non-reference type where a reference to it is a SCALAR

=head2 Num

A number type

=head2 Int

An integer type

=head2 ArrayRef

An ArrayRef (ARRAY) type

=head2 HashRef

A HashRef (HASH) type

=head2 CodeRef

A CodeRef (CODE) type

=head2 RegexpRef

A regular expression reference type

=head2 GlobRef

A glob reference type

=head2 FileHandle

A type that is either a builtin perl filehandle or an IO::Handle object

=head2 Object

A type that is an object (think blessed)

=head1 PARAMETERIZED TYPES

=head2 Parameterizing Types With Other Types

The following types can be parameterized with other types.

=head3 ArrayRef

For example, ArrayRef[HashRef]

=head3 HashRef

=head3 ScalarRef 

=head3 Maybe

For example, Maybe[Int] would be an integer or undef
 
=head2 Parameterizing Types With Strings

In addition, we have some parameterized types that take string arguments.

=head3 InstanceOf

Takes a class name as the argument. For example:

  isa => InstanceOf['MyClass']

=head3 ConsumerOf

Takes a list of role names as the arguments. For example:

  isa => ConsumerOf['My::Role', 'My::AnotherRole'] 

=head3 HasMethods

Takes a list of method names as the arguments. For example:

  isa => HasMethods[qw/postulate contemplate liberate/]

=head1 AUTHOR

Mateu Hunter C<hunter@missoula.org>

=head1 THANKS

mst has provided critical guidance on the design

=head1 COPYRIGHT

Copyright 2011, 2012 Mateu Hunter

=head1 LICENSE

You may distribute this code under the same terms as Perl itself.

=cut

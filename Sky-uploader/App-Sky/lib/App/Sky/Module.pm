package App::Sky::Module;

use strict;
use warnings;

our $VERSION = '0.0.1';

=head1 NAME

App::Sky::Module - class that does the heavy lifting.

=cut

use Moo;
use MooX 'late';

has upload_cmd => (isa => 'ArrayRef[Str]', is => 'ro',);

=head1 METHODS

=head2 $sky->upload_cmd()

Returns an array reference of strings of the upload command.

=cut

1;


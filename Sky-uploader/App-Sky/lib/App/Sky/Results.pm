package App::Sky::Results;

use strict;
use warnings;

our $VERSION = '0.0.1';

=head1 NAME

App::Sky::Results - results of an upload.

=cut

use Carp ();

use Moo;
use MooX 'late';

has upload_cmd => (isa => 'ArrayRef[Str]', is => 'ro',);

=head1 METHODS

=head2 $sky->upload_cmd()

The upload command to execute.

=cut

1;


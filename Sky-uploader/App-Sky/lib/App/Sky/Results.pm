package App::Sky::Results;

use strict;
use warnings;

=head1 NAME

App::Sky::Results - results of an upload.

=cut

use Carp ();

use URI;

use Moo;
use MooX 'late';

has upload_cmd => ( isa => 'ArrayRef[Str]', is => 'ro', );
has urls       => ( isa => 'ArrayRef[URI]', is => 'ro', );

=head1 METHODS

=head2 $results->upload_cmd()

The upload command to execute.

=head2 $results->urls()

An array reference of L<URI> objects where the files were uploaded to.

=cut

1;


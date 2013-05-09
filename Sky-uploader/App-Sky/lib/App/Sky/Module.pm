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
has dest_upload_prefix => (isa => 'Str', is => 'ro',);

=head1 METHODS

=head2 $sky->upload_cmd()

Returns an array reference of strings of the upload command.

=head2 $sky->dest_upload_prefix

The upload prefix to upload to. So:

    my $m = App::Sky::Module->new(
        {
            upload_cmd => [qw(rsync -a -v --progress --inplace)],
            dest_upload_prefix => 'hostgator:public_html/',
            dest_upload_url => 'http://www.shlomifish.org/',
        }
    );

=head2 $sky->get_upload_results({ file => "Shine4U.webm", target_dir => "Files/files/video/" });

Gives the recipe to execute for the upload commands.

=cut

sub get_upload_results
{
    my ($self, $args) = @_;

    return +{};
}


1;


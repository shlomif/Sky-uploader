package App::Sky::Module;

use strict;
use warnings;

=head1 NAME

App::Sky::Module - class that does the heavy lifting.

=cut

use Carp ();

use Moo;
use MooX 'late';

use URI;
use File::Basename qw(basename);

use List::MoreUtils qw( uniq );

use App::Sky::Results;
use App::Sky::Exception;

has base_upload_cmd => (isa => 'ArrayRef[Str]', is => 'ro',);
has dest_upload_prefix => (isa => 'Str', is => 'ro',);
has dest_upload_url_prefix => (isa => 'Str', is => 'ro',);

=head1 METHODS

=head2 $sky->base_upload_cmd()

Returns an array reference of strings of the upload command.

=head2 $sky->dest_upload_prefix

The upload prefix to upload to. So:

    my $m = App::Sky::Module->new(
        {
            base_upload_cmd => [qw(rsync -a -v --progress --inplace)],
            dest_upload_prefix => 'hostgator:public_html/',
            dest_upload_url_prefix => 'http://www.shlomifish.org/',
        }
    );

=head2 $sky->dest_upload_url_prefix

The base URL where the uploads will be found.

=head2 my $results = $sky->get_upload_results({ filenames => ["Shine4U.webm"], target_dir => "Files/files/video/" });

Gives the recipe to execute for the upload commands.

Returns a L<App::Sky::Results> reference containing:

=over 4

=item * upload_cmd

The upload command to execute (as an array reference of strings).

=back

=cut

sub get_upload_results
{
    my ($self, $args) = @_;

    my $is_dir = ($args->{is_dir} // 0);

    my $filenames = $args->{filenames}
        or Carp::confess ("Missing argument 'filenames'");

    if (@$filenames != 1)
    {
        Carp::confess ("More than one file passed to 'filenames'");
    }

    my $target_dir = $args->{target_dir}
        or Carp::confess ("Missing argument 'target_dir'");

    my $invalid_chars_re = qr/[:]/;

    my @invalid_chars = (map { split( //, $_) } map { /($invalid_chars_re)/g } @$filenames);

    if (@invalid_chars)
    {
        App::Sky::Exception::Upload::Filename::InvalidChars->throw(
            invalid_chars =>
            [sort { $a cmp $b } uniq(@invalid_chars)],
        );
    }

    return App::Sky::Results->new(
        {
            upload_cmd =>
            [
                @{$self->base_upload_cmd()},
                @$filenames,
                ($self->dest_upload_prefix() . $target_dir),
            ],
            urls =>
            [
                URI->new(
                    $self->dest_upload_url_prefix()
                    . $target_dir
                    . basename($filenames->[0])
                    . ($is_dir ? '/' : '')
                ),
            ],
        }
    );
}


1;


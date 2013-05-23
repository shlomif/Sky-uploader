package App::Sky::Manager;

use strict;
use warnings;

our $VERSION = '0.0.1';

=encoding utf8

=head1 NAME

App::Sky::Manager - manager for the configuration.

=cut

use Carp ();

use Moo;
use MooX 'late';

use List::Util qw(first);

use URI;
use File::Basename qw(basename);

use App::Sky::Module;

has config => (isa => 'HashRef', is => 'ro',);

=head1 METHODS

=head2 config

The configuration of the app as passed through the configuration file.

=head2 my $results = $sky->get_upload_results({ filenames => ["Shine4U.webm"], });

Gives the recipe to execute for the upload commands.

Accepts one argument that is a hash reference with these keys:

=over 4

=item * 'filenames'

An array reference containing strings to upload. Currently only supports
one filename.

=item * 'section'

An optional section that will override the target section. If not specified,
the uploader will try to guess based on the file’s basename and the manager
configuration.

=back

Returns a L<App::Sky::Results> reference containing:

=over 4

=item * upload_cmd

The upload command to execute (as an array reference of strings).

=back

=cut

sub get_upload_results
{
    my ($self, $args) = @_;

    my $filenames = $args->{filenames}
        or Carp::confess ("Missing argument 'filenames'");

    if (@$filenames != 1)
    {
        Carp::confess ("More than one file passed to 'filenames'");
    }

    my $config = $self->config;

    my $site_conf = $config->{sites}->{ $config->{default_site} };

    my $backend = App::Sky::Module->new(
        {
            base_upload_cmd => $site_conf->{base_upload_cmd},
            dest_upload_prefix => $site_conf->{dest_upload_prefix},
            dest_upload_url_prefix => $site_conf->{dest_upload_url_prefix},
        }
    );

    my $fn = $filenames->[0];
    my $bn = basename($fn);

    my $sections = $site_conf->{sections};

    my $sect_name = $args->{section};

    if (!defined ($sect_name) )
    {
        $sect_name = (first {
                my $re = $sections->{$_}->{basename_re};
                $fn =~ /$re/ } (keys(%$sections)) );
    }

    if (!defined( $sect_name ))
    {
        Carp::confess ("Unknown section for basename '$bn'");
    }

    if (!exists( $sections->{$sect_name} ))
    {
        Carp::confess ("Section '$sect_name' does not exist.");
    }

    return $backend->get_upload_results(
        {
            filenames => $filenames,
            target_dir => $sections->{$sect_name}->{target_dir},
        }
    );
}


1;


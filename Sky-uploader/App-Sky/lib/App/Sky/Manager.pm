package App::Sky::Manager;

use strict;
use warnings;

our $VERSION = '0.2.0';

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

# For defined-or - "//".
use 5.010;

has config => (isa => 'HashRef', is => 'ro',);

=head1 METHODS

=head2 config

The configuration of the app as passed through the configuration file.

=cut

sub _calc_site_conf
{
    my ($self, $args) = @_;

    my $config = $self->config;

    return $config->{sites}->{ $config->{default_site} };
}

sub _calc_sect_name
{
    my ($self, $args, $sections) = @_;

    my $bn = $args->{basename};

    my $sect_name = $args->{section};

    if (!defined ($sect_name))
    {
        if ($args->{is_dir})
        {
            $sect_name = $self->_calc_site_conf($args)->{dirs_section};
        }
        else
        {
            $sect_name =
            (first
                {
                    my $re = $sections->{$_}->{basename_re};
                    $bn =~ /$re/;
                }
                (keys(%$sections))
            );
        }
    }

    if (!defined( $sect_name ))
    {
        Carp::confess ("Unknown section for basename '$bn'");
    }

    if (!exists( $sections->{$sect_name} ))
    {
        Carp::confess ("Section '$sect_name' does not exist.");
    }

    return $sect_name;
}

sub _calc_target_dir
{
    my ($self, $args) = @_;

    if (defined( $args->{target_dir} ))
    {
        return $args->{target_dir};
    }
    else
    {
        my $sections = $self->_calc_site_conf($args)->{sections};

        my $sect_name = $self->_calc_sect_name( $args, $sections );

        return $sections->{$sect_name}->{target_dir};
    }
}

sub _perform_upload_generic
{
    my ($self, $is_dir, $args) = @_;

    my $filenames = $args->{filenames}
        or Carp::confess ("Missing argument 'filenames'");

    if (@$filenames != 1)
    {
        Carp::confess ("More than one file passed to 'filenames'");
    }

    my $site_conf = $self->_calc_site_conf($args);

    my $backend = App::Sky::Module->new(
        {
            base_upload_cmd => $site_conf->{base_upload_cmd},
            dest_upload_prefix => $site_conf->{dest_upload_prefix},
            dest_upload_url_prefix => $site_conf->{dest_upload_url_prefix},
        }
    );

    my $fn = $filenames->[0];
    my $bn = basename($fn);

    my @dir = ($is_dir ? (is_dir => 1) : ());

    return $backend->get_upload_results(
        {
            filenames => $filenames,
            target_dir => $self->_calc_target_dir({
                    %$args,
                    basename => $bn,
                    @dir,
            }),
            @dir,
        }
    );

}

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

=item * 'target_dir'

Overrides the target directory for the upload, to ignore that dictated by
the sections. Should point to a string.

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

    return $self->_perform_upload_generic(0, $args);
}

=head2 my $results = $sky->get_recursive_upload_results({ filenames => ['/home/music/Music/mp3s/Basic Desire/'], });

Gives the recipe to execute for the recursive upload commands.

Accepts one argument that is a hash reference with these keys:

=over 4

=item * 'filenames'

An array reference containing paths to directories. Currently only supports
one filename.

=item * 'section'

An optional section that will override the target section. If not specified,
the uploader will try to use the 'dirs_section' section.

=item * 'target_dir'

Overrides the target directory for the upload, to ignore that dictated by
the sections. Should point to a string.

=back

Returns a L<App::Sky::Results> reference containing:

=over 4

=item * upload_cmd

The upload command to execute (as an array reference of strings).

=back

=cut

sub get_recursive_upload_results
{
    my ($self, $args) = @_;

    return $self->_perform_upload_generic(1, $args);
}


1;


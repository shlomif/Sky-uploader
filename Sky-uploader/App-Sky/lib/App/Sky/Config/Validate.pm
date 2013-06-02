package App::Sky::Config::Validate;

use strict;
use warnings;

our $VERSION = '0.0.3';

=encoding utf8

=head1 NAME

App::Sky::Config::Validate - validate the configuration.

=cut

use Carp ();

use Moo;
use MooX 'late';

use Scalar::Util qw(reftype);

has 'config' => (isa => 'HashRef', is => 'ro', required => 1,);

=head1 METHODS

=head2 $self->config()

The configuration to validate.

=head2 $self->is_valid()

Determines if the configuration is valid. Throws an exception if not valid,
and returns FALSE (in both list context and scalar context if it is valid.).

=cut

sub is_valid
{
    my ($self) = @_;

    my $config = $self->config();

    # Validate the configuration
    {
        if (! exists ($config->{default_site}))
        {
            die "A 'default_site' key must be present in the configuration.";
        }

        my $sites = $config->{sites};
        if (ref($sites) ne 'HASH')
        {
            die "sites key must be a hash.";
        }

        foreach my $k (keys(%$sites))
        {
            my $v = $sites->{$k};

            my $base_upload_cmd = $v->{base_upload_cmd};
            if (ref ($base_upload_cmd) ne 'ARRAY')
            {
                die "base_upload_cmd for site '$k' is not an array.";
            }

            foreach my $kk (qw(dest_upload_prefix dest_upload_url_prefix))
            {
                my $s = $v->{$kk};
                if (not
                    (
                        defined($s) && (ref($s) eq '') && ($s =~ m/./)
                    )
                )
                {
                    die "$kk for site '$k' is not a string.";
                }
            }



            my $sections = $v->{sections};
            if (ref ($sections) ne 'HASH')
            {
                die "Sections for site '$k' is not a hash.";
            }

            foreach my $sect_k (keys (%$sections))
            {
                my $sect_v = $sections->{$sect_k};

                if (! defined($sect_v->{basename_re}) or ref($sect_v->{basename_re} ne ''))
                {
                    die "Section '$sect_k' at site '$k' must contain a basename_re";
                }

                if (! defined($sect_v->{target_dir}) or ref($sect_v->{target_dir} ne ''))
                {
                    die "Section '$sect_k' at site '$k' must contain a target_dir";
                }
            }
        }
    }

    return;
}

1;


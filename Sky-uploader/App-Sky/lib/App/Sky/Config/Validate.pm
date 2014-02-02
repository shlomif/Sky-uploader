package App::Sky::Config::Validate;

use strict;
use warnings;

our $VERSION = '0.0.7';

=encoding utf8

=head1 NAME

App::Sky::Config::Validate - validate the configuration.

=cut

use Carp ();

use Moo;
use MooX 'late';

use Scalar::Util qw(reftype);
use List::MoreUtils qw(notall);

has 'config' => (isa => 'HashRef', is => 'ro', required => 1,);

=head1 METHODS

=head2 $self->config()

The configuration to validate.

=head2 $self->is_valid()

Determines if the configuration is valid. Throws an exception if not valid,
and returns FALSE (in both list context and scalar context if it is valid.).

=cut

sub _sorted_keys
{
    my $hash_ref = shift;

    return sort {$a cmp $b } keys(%$hash_ref);
}

sub _validate_section
{
    my ($self, $site_name, $sect_name, $sect_conf) = @_;

    foreach my $string_key (qw( basename_re target_dir))
    {
        my $v = $sect_conf->{$string_key};

        if (not (
                defined($v)
                &&
                ref($v) eq ''
                &&
                $v =~ /\S/
            ))
        {
        die "Section '$sect_name' at site '$site_name' must contain a non-empty $string_key";
        }
    }

    return;
}

sub _validate_site
{
    my ($self, $site_name, $site_conf) = @_;

    my $base_upload_cmd = $site_conf->{base_upload_cmd};
    if (ref ($base_upload_cmd) ne 'ARRAY')
    {
        die "base_upload_cmd for site '$site_name' is not an array.";
    }

    if (notall { defined($_) && ref($_) eq '' } @$base_upload_cmd)
    {
        die "base_upload_cmd for site '$site_name' must contain only strings.";
    }

    foreach my $kk (qw(dest_upload_prefix dest_upload_url_prefix))
    {
        my $s = $site_conf->{$kk};
        if (not
            (
                defined($s) && (ref($s) eq '') && ($s =~ m/\S/)
            )
        )
        {
            die "$kk for site '$site_name' is not a string.";
        }
    }



    my $sections = $site_conf->{sections};
    if (ref ($sections) ne 'HASH')
    {
        die "Sections for site '$site_name' is not a hash.";
    }

    foreach my $sect_name (_sorted_keys($sections))
    {
        $self->_validate_section(
            $site_name, $sect_name, $sections->{$sect_name}
        );
    }

    return;
}

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

        foreach my $name (_sorted_keys($sites))
        {
            $self->_validate_site($name, $sites->{$name});
        }
    }

    return;
}

1;


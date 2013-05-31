package App::Sky::CmdLine;

use strict;
use warnings;

our $VERSION = '0.0.1';

=encoding utf8

=head1 NAME

App::Sky::CmdLine - command line program

=cut

use Carp ();

use Moo;
use MooX 'late';

use Getopt::Long qw(GetOptionsFromArray);

use App::Sky::Manager;
use File::HomeDir;

use YAML::XS qw(LoadFile);

use Scalar::Util qw(reftype);

has 'argv' => (isa => 'ArrayRef[Str]', is => 'rw', required => 1,);

=head1 METHODS

=head2 argv

The array of command line arguments - should be supplied to the constructor.

=head2 run()

Run the application.

=cut

sub run
{
    my ($self) = @_;

    my $verb = shift(@{$self->argv()});

    if (($verb eq '--help') or ($verb eq '-h'))
    {
        print <<'EOF';
sky upload /path/to/myfile.txt
EOF
        exit(0);
    }

    if (not (($verb eq 'up') || ($verb eq 'upload')))
    {
        print "Usage: sky [up|upload] /path/to/myfile.txt";
        exit(-1);
    }

    # GetOptionsFromArray(
    #     $self->argv(),
    # );

    my $filename = shift(@{$self->argv()});

    my $dist_config_dir = File::HomeDir->my_dist_config( 'App-Sky', {create => 1}, );

    my $config_fn = File::Spec->catfile($dist_config_dir, 'app_sky_conf.yml');

    my $config = LoadFile($config_fn);

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

    if (reftype($config) ne 'HASH')
    {
        die "Must be a valid App-Sky configuration in '$config_fn'. Please see perldoc App::Sky for details.";
    }

    my $manager = App::Sky::Manager->new(
        {
            config => $config,
        }
    );

    if (! -f $filename)
    {
        die "Can only upload files. '$filename' is not a valid filename.";
    }

    my $results =
        $manager->get_upload_results(
            {
                filenames => [$filename],
            }
        );

    my $upload_cmd = $results->upload_cmd();
    my $urls = $results->urls();

    if ((system { $upload_cmd->[0] } @$upload_cmd) != 0)
    {
        die "Upload cmd <<@$upload_cmd>> failed with $!";
    }

    print "Got URL:\n" , $urls->[0]->as_string(), "\n";

    exit(0);
}

1;


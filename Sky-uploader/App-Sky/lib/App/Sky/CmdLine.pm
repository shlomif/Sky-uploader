package App::Sky::CmdLine;

use strict;
use warnings;

our $VERSION = '0.0.7';

=encoding utf8

=head1 NAME

App::Sky::CmdLine - command line program

=cut

use Carp ();

use Moo;
use MooX 'late';

use Getopt::Long qw(GetOptionsFromArray);

use App::Sky::Config::Validate;
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

sub _basic_help
{
    my ($self) = @_;

    print <<'EOF';
sky upload /path/to/myfile.txt
EOF

    exit(0);
}

sub _basic_usage
{
    my ($self) = @_;

    print "Usage: sky [up|upload] /path/to/myfile.txt\n";
    exit(-1);
}

sub run
{
    my ($self) = @_;

    if (! @{$self->argv()})
    {
        return $self->_basic_usage();
    }

    my $verb = shift(@{$self->argv()});

    if (($verb eq '--help') or ($verb eq '-h'))
    {
        return $self->_basic_help();
    }

    my $_calc_manager = sub {
        my $dist_config_dir = File::HomeDir->my_dist_config( 'App-Sky', {create => 1}, );

        my $config_fn = File::Spec->catfile($dist_config_dir, 'app_sky_conf.yml');

        my $config = LoadFile($config_fn);

        my $validator = App::Sky::Config::Validate->new({ config => $config });
        $validator->is_valid();

        return App::Sky::Manager->new(
            {
                config => $config,
            }
        );
    };

    my $_handle_results = sub {
        my ($results) = @_;

        my $upload_cmd = $results->upload_cmd();
        my $urls = $results->urls();

        if ((system { $upload_cmd->[0] } @$upload_cmd) != 0)
        {
            die "Upload cmd <<@$upload_cmd>> failed with $!";
        }

        print "Got URL:\n" , $urls->[0]->as_string(), "\n";

        exit(0);
    };

    my $op;
    if ((($verb eq 'up') || ($verb eq 'upload')))
    {
        $op = 'upload';
    }
    elsif (($verb eq 'up-r') || ($verb eq 'upload-recursive'))
    {
        $op = "up-r";
    }
    else
    {
        return $self->_basic_usage();
    }


    # GetOptionsFromArray(
    #     $self->argv(),
    # );

    my $filename = shift(@{$self->argv()});

    if (not (($op eq 'upload') ? (-f $filename) : (-d $filename)))
    {
        die "Can only upload directories. '$filename' is not a valid directory name.";
    }

    my $meth = $op eq 'upload' ? 'get_upload_results' : 'get_recursive_upload_results';

    $_handle_results->(
        scalar(
            $_calc_manager->()->$meth(
                {
                    filenames => [$filename],
                }
            )
        )
    );

    return;
}

1;


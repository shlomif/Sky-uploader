package App::Sky::CmdLine;

use strict;
use warnings;

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

has 'argv' => ( isa => 'ArrayRef[Str]', is => 'rw', required => 1, );

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
sky up-r /path/to/directory

Specifying --copy or -x will copy the URL to the clipboard.
EOF

    exit(0);
}

sub _basic_usage
{
    my ($self) = @_;

    print "Usage: sky [up|upload] /path/to/myfile.txt\n";
    exit(-1);
}

sub _is_copy_to_clipboard
{
    my ( $self, $flag ) = @_;

    return ( $flag =~ /\A(--copy|-x)\z/ );
}

sub _shift
{
    my $self = shift;

    return shift( @{ $self->argv() } );
}

sub run
{
    my ($self) = @_;

    my $copy = 0;

    if ( !@{ $self->argv() } )
    {
        return $self->_basic_usage();
    }

    my $verb = shift( @{ $self->argv() } );

    if ( ( $verb eq '--help' ) or ( $verb eq '-h' ) )
    {
        return $self->_basic_help();
    }

    if ( $self->_is_copy_to_clipboard($verb) )
    {
        $copy = 1;

        $verb = shift( @{ $self->argv() } );
    }

    my $_calc_manager = sub {
        my $dist_config_dir =
            File::HomeDir->my_dist_config( 'App-Sky', { create => 1 }, );

        my $config_fn =
            File::Spec->catfile( $dist_config_dir, 'app_sky_conf.yml' );

        my $config = LoadFile($config_fn);

        my $validator =
            App::Sky::Config::Validate->new( { config => $config } );
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
        my $urls       = $results->urls();

        if ( ( system { $upload_cmd->[0] } @$upload_cmd ) != 0 )
        {
            die "Upload cmd <<@$upload_cmd>> failed with $!";
        }

        my $URL = $urls->[0]->as_string();

        print "Got URL:\n", $URL, "\n";

        if ($copy)
        {
            require Clipboard;
            Clipboard->VERSION('0.19');
            Clipboard->import('');
            Clipboard->copy_to_all_selections($URL);
        }

        exit(0);
    };

    my $op;
    if ( ( ( $verb eq 'up' ) || ( $verb eq 'upload' ) ) )
    {
        $op = 'upload';
    }
    elsif ( ( $verb eq 'up-r' ) || ( $verb eq 'upload-recursive' ) )
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

    my $filename = $self->_shift();

ARGS_LOOP:
    while ( $filename =~ /\A-/ )
    {
        if ( $self->_is_copy_to_clipboard($filename) )
        {
            $copy     = 1;
            $filename = $self->_shift();
        }
        elsif ( $filename eq '--' )
        {
            $filename = $self->_shift();
            last ARGS_LOOP;
        }
        else
        {
            die qq#Unrecognized argument "$filename"!#;
        }
    }

    if ( not( ( $op eq 'upload' ) ? ( -f $filename ) : ( -d $filename ) ) )
    {
        if ( $op eq 'upload' )
        {
            die qq#"up" can only upload files. '$filename' is not a file!#;
        }
        die
"Can only upload directories. '$filename' is not a valid directory name.";
    }

    my $meth =
        $op eq 'upload' ? 'get_upload_results' : 'get_recursive_upload_results';

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

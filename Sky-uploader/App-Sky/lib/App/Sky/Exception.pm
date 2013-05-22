package App::Sky::Exception;

use strict;
use warnings;

=head1 NAME

App::Sky::Exception - provides various exception classes for App::Sky

=cut

use vars qw($VERSION);

$VERSION = '0.1103';

use Exception::Class (
    'App::Sky::Exception',
    'App::Sky::Exception::Upload' =>
    { isa => "App::Sky::Exception", },
    'App::Sky::Exception::Upload::Filename' =>
    { isa => "App::Sky::Exception::Upload", },
    'App::Sky::Exception::Upload::Filename::InvalidChars' =>
    { isa => "App::Sky::Exception::Upload",
        fields => [ 'invalid_chars' ],
    },
);

=head1 SYNOPSIS

    use App::Sky::Exception;

=head1 DESCRIPTION

These are L<Exception:Class> exceptions for L<App::Sky> .

=cut

=head1 FUNCTIONS

=head2 new($args)

The constructor. Blesses and calls _init() .

=cut

=head1 AUTHOR

Shlomi Fish, L<http://www.shlomifish.org/> .

=head1 ACKNOWLEDGEMENTS

1; # End of App::Sky::Exception

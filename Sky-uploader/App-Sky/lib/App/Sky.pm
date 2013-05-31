package App::Sky;

use strict;
use warnings;

our $VERSION = '0.0.1';

=head1 NAME

App::Sky - wrapper to rsync/etc. to upload files to a remote server and give
download links.

=head1 SYNOPSIS

Put something like this in F<~/.config/Perl/App-Sky/app_sky_conf.yml> :

    ---
    default_site: homepage
    sites:
        homepage:
            base_upload_cmd:
                - 'rsync'
                - '-a'
                - '-v'
                - '--progress'
                - '--inplace'
            dest_upload_prefix: 'hostgator:public_html/'
            dest_upload_url_prefix: 'http://www.shlomifish.org/'
            sections:
                code:
                    basename_re: '\.(?:pl|pm|c|py)\z'
                    target_dir: 'Files/files/code/'
                music:
                    basename_re: '\.(?:mp3|ogg|wav|aac|m4a)\z'
                    target_dir: 'Files/files/music/mp3-ogg/'
                video:
                    basename_re: '\.(?:webm|flv|avi|mpeg|mpg|mp4|ogv)\z'
                    target_dir: 'Files/files/video/'

Then you can use commands such as:

    $ sky up /path/to/my-music-file.mp3

And get in return a URL to where it was uploaded.

=cut

1;


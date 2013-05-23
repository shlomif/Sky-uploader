#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 7;

use Test::Differences (qw( eq_or_diff ));

use App::Sky::Manager;

{
    my $manager = App::Sky::Manager->new(
        {
            config =>
            {
                default_site => "shlomif",
                sites =>
                {
                    shlomif =>
                    {
                        base_upload_cmd => [qw(rsync -a -v --progress --inplace)],
                        dest_upload_prefix => 'hostgator:public_html/',
                        dest_upload_url_prefix => 'http://www.shlomifish.org/',
                        sections =>
                        {
                            code =>
                            {
                                basename_re => q/\.(?:pl|pm|c|py)\z/,
                                target_dir => "Files/files/code/",
                            },
                            music =>
                            {
                                basename_re => q/\.(?:mp3|ogg|wav|aac|m4a)\z/,
                                target_dir => "Files/files/music/mp3-ogg/",
                            },
                            video =>
                            {
                                basename_re => q/\.(?:webm|flv|avi|mpeg|mpg|mp4|ogv)\z/,
                                target_dir => "Files/files/video/",
                            },
                        },
                    },
                },
            },
        },
    );

    # TEST
    ok ($manager, 'Module App::Sky::Manager was created.');

    {
        my $results = $manager->get_upload_results(
            {
                'filenames' => ['/home/music/Music/mp3s/Shine 4U - Carmen and Camille-B8ehY5tutHs.mp4', ],
            }
        );

        # TEST
        ok ($results, "Results were returned.");

        # TEST
        eq_or_diff (
            $results->upload_cmd(),
            [qw(rsync -a -v --progress --inplace),
            '/home/music/Music/mp3s/Shine 4U - Carmen and Camille-B8ehY5tutHs.mp4',
            'hostgator:public_html/Files/files/video/'
            ],
            "results->upload_cmd() is correct.",
        );

        # TEST
        eq_or_diff (
            [map { $_->as_string() } @{$results->urls()}],
            [
                'http://www.shlomifish.org/Files/files/video/Shine%204U%20-%20Carmen%20and%20Camille-B8ehY5tutHs.mp4',
            ],
            'The result URLs are correct.',
        );
    }

    {
        my $results = $manager->get_upload_results(
            {
                'filenames' => ['./foobar/MyModule.pm'],
            }
        );

        # TEST
        ok ($results, "Results were returned.");

        # TEST
        eq_or_diff (
            $results->upload_cmd(),
            [qw(rsync -a -v --progress --inplace),
            './foobar/MyModule.pm',
            'hostgator:public_html/Files/files/code/'
            ],
            "[code] results->upload_cmd() is correct.",
        );

        # TEST
        eq_or_diff (
            [map { $_->as_string() } @{$results->urls()}],
            [
                'http://www.shlomifish.org/Files/files/code/MyModule.pm',
            ],
            'code - the result URLs are correct.',
        );
    }
}


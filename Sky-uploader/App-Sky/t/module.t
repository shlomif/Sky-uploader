#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 3;

use Test::Differences (qw( eq_or_diff ));

use App::Sky::Module;

{
    my $m = App::Sky::Module->new(
        {
            upload_cmd => [qw(rsync -a -v --progress --inplace)],
            dest_upload_prefix => 'hostgator:public_html/',
            dest_upload_url => 'http://www.shlomifish.org/',
        }
    );

    # TEST
    ok ($m, 'Module App::Sky::Module was created.');

    # TEST
    eq_or_diff(
        $m->upload_cmd(),
        [qw(rsync -a -v --progress --inplace)],
        "upload_cmd was set.",
    );

    my $results = $m->get_upload_results(
        {
            'file' => 'Shine4U.webm',
            'target_dir' => 'Files/files/video/',
        }
    );

    # TEST
    ok ($results, "Results were returned.");
}


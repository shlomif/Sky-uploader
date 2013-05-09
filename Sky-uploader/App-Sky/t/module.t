#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 4;

use Test::Differences (qw( eq_or_diff ));

use App::Sky::Module;

{
    my $m = App::Sky::Module->new(
        {
            base_upload_cmd => [qw(rsync -a -v --progress --inplace)],
            dest_upload_prefix => 'hostgator:public_html/',
            dest_upload_url => 'http://www.shlomifish.org/',
        }
    );

    # TEST
    ok ($m, 'Module App::Sky::Module was created.');

    # TEST
    eq_or_diff(
        $m->base_upload_cmd(),
        [qw(rsync -a -v --progress --inplace)],
        "base_upload_cmd was set.",
    );

    my $results = $m->get_upload_results(
        {
            'filenames' => ['Shine4U.webm'],
            'target_dir' => 'Files/files/video/',
        }
    );

    # TEST
    ok ($results, "Results were returned.");

    # TEST
    eq_or_diff (
        $results->upload_cmd(),
        [qw(rsync -a -v --progress --inplace Shine4U.webm hostgator:public_html/Files/files/video/)],
        "results->upload_cmd() is correct.",
    );
}


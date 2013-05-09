#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 2;

use Test::Differences (qw( eq_or_diff ));

use App::Sky::Module;

{
    my $m = App::Sky::Module->new(
        {
            upload_cmd => [qw(rsync -a -v --progress --inplace)],
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
}


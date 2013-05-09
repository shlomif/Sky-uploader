#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 1;

use App::Sky::Module;

{
    my $m = App::Sky::Module->new();

    # TEST
    ok ($m, 'Module App::Sky::Module was created.');
}


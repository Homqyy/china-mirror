use warnings;
use strict;
use Test::More tests => 2;

# get bin path
use FindBin qw($Bin);

my $project_dir = "$Bin/../";
my $cmd;

# test for ubuntu 20.04
$cmd = "docker run --rm -qv `pwd`:/china-mirror ubuntu:20.04 bash -c 'bash /china-mirror/os.sh && apt-get update'";
print "test cmd: $cmd\n";
is(system($cmd), 0, 'ubuntu 20.04');

# test for ubuntu 22.04
$cmd = "docker run --rm -qv `pwd`:/china-mirror ubuntu:22.04 bash -c 'bash /china-mirror/os.sh && apt-get update'";
print "test cmd: $cmd\n";
is(system($cmd), 0, 'ubuntu 22.04');
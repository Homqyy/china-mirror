use strict;
use warnings;
use Test::More tests => 3;

# get bin path
use FindBin qw($Bin);

my $project_dir = "$Bin/../";
my $cmd;

# test for alpine latest
$cmd = "docker run --rm -v $Bin/../:/china-mirror alpine sh -c 'sh /china-mirror/os.sh && apk update'";
print "test cmd: $cmd\n";
is(system($cmd), 0, 'alpine latest');

# test for alpine 3.14.2
$cmd = "docker run --rm -v $Bin/../:/china-mirror alpine:3.14.2 sh -c 'sh /china-mirror/os.sh && apk update'";
print "test cmd: $cmd\n";
is(system($cmd), 0, 'alpine 3.14.2');

# test for alpine 3.20.3
$cmd = "docker run --rm -v $Bin/../:/china-mirror alpine:3.20.3 sh -c 'sh /china-mirror/os.sh && apk update'";
print "test cmd: $cmd\n";
is(system($cmd), 0, 'alpine 3.20.3');
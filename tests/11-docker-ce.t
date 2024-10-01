use warnings;
use strict;
use Test::More tests => 4;

# get bin path
use FindBin qw($Bin);

my $project_dir = "$Bin/../";
my $cmd;

# case set: test for ubuntu version
sub test_ubuntu($;) {
    my $version = shift;

    $cmd = "docker run --rm -qv $project_dir:/china-mirror" .
        " ubuntu:$version" .
        " bash -c 'bash /china-mirror/docker-ce.sh --no-interaction'";
    print "test cmd: $cmd\n";
    is(system($cmd), 0, "ubuntu $version");
}

&test_ubuntu("20.04");
# &test_ubuntu("21.04");
&test_ubuntu("22.04");
&test_ubuntu("23.04");
&test_ubuntu("24.04");
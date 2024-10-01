use warnings;
use strict;
use Test::More tests => 8;

# get bin path
use FindBin qw($Bin);

my $project_dir = "$Bin/../";
my $cmd;

# case set: test for ubuntu version
sub test_ubuntu($;) {
    my $version = shift;
    $cmd = "docker run --rm -qv $project_dir:/china-mirror" .
        " ubuntu:$version" .
        " bash -c 'bash /china-mirror/k8s.sh -y && apt-get update'";
    print "test cmd: $cmd\n";
    is(system($cmd), 0, "ubuntu $version");
}

sub test_k8s_version($;) {
    my $version = shift;
    $cmd = "docker run --rm -qv $project_dir:/china-mirror" .
        " ubuntu:20.04" .
        " bash -c 'bash /china-mirror/k8s.sh -y -v $version && apt-get update'";
    print "test cmd: $cmd\n";
    is(system($cmd), 0, "k8s $version");
}

&test_ubuntu("20.04");
&test_ubuntu("22.04");
&test_ubuntu("23.04");
&test_ubuntu("24.04");

# case set: test for k8s version
&test_k8s_version("v1.27");
&test_k8s_version("v1.28");
&test_k8s_version("v1.29");
&test_k8s_version("v1.30");
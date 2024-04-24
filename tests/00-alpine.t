use strict;
use warnings;
use Test::More tests => 1;

# get bin path
use FindBin qw($Bin);

# running docker: alpine
my $result = `docker run -q --rm -v '$Bin/../:/root/china-mirror:ro' -w '/root/china-mirror' alpine sh ./os.sh >> /dev/null && echo -n "ok"`;

is($result, "ok", "alpine (os.sh)");

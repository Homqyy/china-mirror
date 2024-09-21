use strict;
use warnings;
use Test::More tests => 1;

# get bin path
use FindBin qw($Bin);

# running docker: alpine
my $result = `docker run -q --rm \
    -v '$Bin/../:/china-mirror:ro' \
    -w '/china-mirror' \
    alpine \
    sh ./os.py >> /dev/null && echo -n "ok"`;

is($result, "ok", "alpine (os.sh)");

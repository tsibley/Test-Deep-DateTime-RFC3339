use strict;
use Test::More;
use Test::Deep;
use Test::Deep::DateTime::RFC3339;
use DateTime::Format::RFC3339;

my $rfc3339 = DateTime::Format::RFC3339->new;
my $now     = DateTime->now( time_zone => 'UTC' );

cmp_deeply { created => '1987-12-18T00:00:00Z' },
           { created => datetime_rfc3339() },
           "parseable only, good";

ok !
(eq_deeply { created => '1987-12-18' },
           { created => datetime_rfc3339() }),
           "parseable only, bad";

cmp_deeply { created => $rfc3339->format_datetime($now) },
           { created => datetime_rfc3339($now) },
           "exact, equal";

ok !
(eq_deeply { created => $rfc3339->format_datetime($now) },
           { created => datetime_rfc3339('1987-12-18T00:00:00Z') }),
           "exact, not equal";

cmp_deeply { created => $rfc3339->format_datetime($now->clone->add( seconds => 3 )) },
           { created => datetime_rfc3339($now, '00:00:05') },
           "within tolerance, positive";

cmp_deeply { created => $rfc3339->format_datetime($now->clone->subtract( seconds => 3 )) },
           { created => datetime_rfc3339($now, '00:00:05') },
           "within tolerance, negative";

ok !
(eq_deeply { created => $rfc3339->format_datetime($now->clone->add( seconds => 3 )) },
           { created => datetime_rfc3339($now, '00:00:01') }),
           "outside tolerance, positive";

ok !
(eq_deeply { created => $rfc3339->format_datetime($now->clone->subtract( seconds => 3 )) },
           { created => datetime_rfc3339($now, '00:00:01') }),
           "outside tolerance, negative";

cmp_deeply { created => $rfc3339->format_datetime($now->clone->add( seconds => 3 )) },
           { created => datetime_rfc3339($now, DateTime::Duration->new( seconds => 3 )) },
           "tolerance as DateTime::Duration, closed interval";

is datetime_rfc3339($now)->renderExp,
   $rfc3339->format_datetime($now),
   "rendering of expected value is RFC3339";

is datetime_rfc3339($now, '00:00:03')->renderExp,
   $rfc3339->format_datetime($now) . " +/- 3 seconds",
   "rendering of expected value is RFC3339 +/- human readable tolerance";

my $got = $now->clone->add( seconds => 5 );
is datetime_rfc3339($now)->renderGot($got),
   $rfc3339->format_datetime($got),
   "rendering of got value is RFC3339";

ok !eval { datetime_rfc3339("bogus") }, "expected parse failure";
like $@, qr/Expected datetime/i, "error message";

ok !eval { datetime_rfc3339($now, "bogus") }, "tolerance parse failure";
like $@, qr/Expected tolerance/i, "error message";

my $check = datetime_rfc3339($now);
ok !
(eq_deeply { created => 'bogus' },
           { created => $check }),
           "failure on unparseable value";
like $check->diag_message('$data->{created}'), qr/Can't parse 'bogus'/, "error message";

done_testing;

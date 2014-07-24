# NAME

Test::Deep::DateTime::RFC3339 - Test RFC3339 timestamps are within a certain tolerance

# SYNOPSIS

    use Test::Deep;
    use Test::Deep::DateTime::RFC3339;

    my $now    = DateTime->now;
    my $record = create_record(...);
    cmp_deeply $record, { created => datetime_rfc3339($now, '00:00:05') },
        'Created is within 5 seconds of current time';

# DESCRIPTION

Test::Deep::DateTime::RFC3339 provides a single function, [`datetime_rfc3339` ](https://metacpan.org/pod/&#x20;#datetime_rfc3339), which is used with [Test::Deep](https://metacpan.org/pod/Test::Deep) to
check that the **string** value gotten is an RFC3339-compliant timestamp equal
to, or within the optional tolerances of, the expected timestamp.

[RFC3339](https://tools.ietf.org/html/rfc3339) was chosen because it is a sane
subset of [ISO8601's kitchen-sink](https://metacpan.org/pod/DateTime::Format::ISO8601#Supported-via-parse_datetime).

# FUNCTIONS

## datetime\_rfc3339

Takes a [DateTime](https://metacpan.org/pod/DateTime) object or an [RFC3339 timestamp](https://tools.ietf.org/html/rfc3339)
string parseable by [DateTime::Format::RFC3339](https://metacpan.org/pod/DateTime::Format::RFC3339) as the required first argument
and a [DateTime::Duration](https://metacpan.org/pod/DateTime::Duration) object or `HH:MM:SS` string representing a
duration as an optional second argument.  The second argument is used as a ±
tolerance centered on the expected datetime.  If a tolerance is provided, the
timestamp being tested must fall within the closed interval for the test to
pass.  Otherwise, the timestamp being tested must match the expected datetime.

All comparisons and date math are done in UTC, as advised by
["How-DateTime-Math-Works" in DateTime](https://metacpan.org/pod/DateTime#How-DateTime-Math-Works).  If this causes problems for you, please
tell me about it via bug-Test-Deep-DateTime-RFC3339 _at_ rt.cpan.org.

Returns a Test::Deep::DateTime::RFC3339 object, which is a [Test::Deep::Cmp](https://metacpan.org/pod/Test::Deep::Cmp),
but you shouldn't need to care about those internals.

Exported by default.

# AUTHOR

Thomas Sibley <trsibley@uw.edu>

# COPYRIGHT

This software is copyright (c) 2014- by the Mullins Lab, Department of
Microbiology, University of Washington.

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# SEE ALSO

[Test::Deep](https://metacpan.org/pod/Test::Deep)

[DateTime](https://metacpan.org/pod/DateTime)

[DateTime::Duration](https://metacpan.org/pod/DateTime::Duration)

[DateTime::Format::RFC3339](https://metacpan.org/pod/DateTime::Format::RFC3339)

[RFC3339](https://tools.ietf.org/html/rfc3339)

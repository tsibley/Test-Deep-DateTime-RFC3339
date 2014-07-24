package Test::Deep::DateTime::RFC3339;

use strict;
use warnings;
use 5.008_005;
our $VERSION = '0.01';

use Test::Deep::Cmp;    # isa

use Exporter 'import';
our @EXPORT = qw(datetime_rfc3339);

use Carp 'confess';

use DateTime;
use DateTime::Duration;
use DateTime::Format::RFC3339;
use DateTime::Format::Duration;
use DateTime::Format::Human::Duration;
use Safe::Isa '$_isa';

sub datetime_rfc3339 {
    __PACKAGE__->new(@_);
}

sub init {
    my $self = shift;
    my $expected  = shift or confess "Expected datetime required for datetime_rfc3339()";
    my $tolerance = shift || DateTime::Duration->new; # default to an ->is_zero duration

    $self->{parser} = DateTime::Format::RFC3339->new;

    unless ($expected->$_isa("DateTime")) {
        my $parsed = eval { $self->{parser}->parse_datetime($expected) }
            or confess "Expected datetime isn't a DateTime and can't be parsed as RFC3339: '$expected', $@";
        $expected = $parsed;
    }
    unless ($tolerance->$_isa("DateTime::Duration")) {
        my $pattern = qr/^\d{2}:\d{2}:\d{2}$/;
        confess "Expected tolerance isn't a DateTime::Duration and doesn't match /$pattern/ (%H:%M:%S): '$tolerance'"
            unless $tolerance =~ /$pattern/;

        my $parser = DateTime::Format::Duration->new( pattern => "%2H:%2M:%2S" );
        my $parsed = eval { $parser->parse_duration($tolerance) }
            or confess "Trouble parsing expected tolerance '$tolerance': $@";
        $tolerance = $parsed;
    }

    # Do all comparisons and math in UTC
    $expected->set_time_zone('UTC');

    $self->{expected}  = $expected;
    $self->{tolerance} = $tolerance;

    return;
}

sub descend {
    my ($self, $got) = @_;
    my ($expected, $tolerance) = @$self{'expected', 'tolerance'};

    $got = eval { $self->{parser}->parse_datetime($got) };

    if ($@ or not $got) {
        $self->{diag_message} = sprintf "Can't parse %s as an RFC3339 timestamp: %s",
            (defined $_[1] ? "'$_[1]'" : "an undefined value"), $@;
        return 0;
    }

    $got->set_time_zone('UTC');

    # This lets us receive the DateTime object in renderGot
    $self->data->{got_string} = $self->data->{got};
    $self->data->{got} = $got;

    return ($got >= $expected - $tolerance and $got <= $expected + $tolerance);
}

# reported at top of diagnostic output on failure
sub diag_message {
    my ($self, $where) = @_;
    my $msg = "Compared $where";
    $msg .= "\n" . $self->{diag_message}
        if $self->{diag_message};
    return $msg;
}

# used in diagnostic output on failure to render the expected value
sub renderExp {
    my $self = shift;
    my $expected = $self->_format( $self->{expected} );
    return $self->{tolerance}->is_zero
        ? $expected
        : $expected . " +/- " . DateTime::Format::Human::Duration->new->format_duration($self->{tolerance});
}

sub renderGot {
    my ($self, $got) = @_;
    return $self->_format($got);
}

sub _format {
    my $self = shift;
    return $self->{parser}->format_datetime(@_);
}

1;
__END__

=encoding utf-8

=head1 NAME

Test::Deep::DateTime::RFC3339 - Test RFC3339 timestamps are within a certain tolerance

=head1 SYNOPSIS

    use Test::Deep;
    use Test::Deep::DateTime::RFC3339;

    my $now    = DateTime->now;
    my $record = create_record(...);
    cmp_deeply $record, { created => datetime_rfc3339($now, '00:00:05') },
        'Created is within 5 seconds of current time';

=head1 DESCRIPTION

Test::Deep::DateTime::RFC3339 provides a single function, L<<
C<datetime_rfc3339> | /datetime_rfc3339 >>, which is used with L<Test::Deep> to
check that the B<string> value gotten is an RFC3339-compliant timestamp equal
to, or within the optional tolerances of, the expected timestamp.

L<RFC3339|https://tools.ietf.org/html/rfc3339> was chosen because it is a sane
subset of L<ISO8601's kitchen-sink|DateTime::Format::ISO8601/"Supported via parse_datetime">.

=head1 FUNCTIONS

=head2 datetime_rfc3339

Takes a L<DateTime> object or an L<RFC3339 timestamp|https://tools.ietf.org/html/rfc3339>
string parseable by L<DateTime::Format::RFC3339> as the required first argument
and a L<DateTime::Duration> object or C<HH:MM:SS> string representing a
duration as an optional second argument.  The second argument is used as a ±
tolerance centered on the expected datetime.  If a tolerance is provided, the
timestamp being tested must fall within the closed interval for the test to
pass.  Otherwise, the timestamp being tested must match the expected datetime.

All comparisons and date math are done in UTC, as advised by
L<DateTime/"How-DateTime-Math-Works">.  If this causes problems for you, please
tell me about it via bug-Test-Deep-DateTime-RFC3339 I<at> rt.cpan.org.

Returns a Test::Deep::DateTime::RFC3339 object, which is a L<Test::Deep::Cmp>,
but you shouldn't need to care about those internals.

Exported by default.

=head1 AUTHOR

Thomas Sibley E<lt>trsibley@uw.eduE<gt>

=head1 COPYRIGHT

This software is copyright (c) 2014- by the Mullins Lab, Department of
Microbiology, University of Washington.

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<Test::Deep>

L<DateTime>

L<DateTime::Duration>

L<DateTime::Format::RFC3339>

L<RFC3339|https://tools.ietf.org/html/rfc3339>

=cut
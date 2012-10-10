package OddsConverter;

=head1 NAME

OddsConverter

=head1 SYNOPSIS

    my $oc = OddsConverter->new(probability => 0.5);
    print $oc->decimal_odds;    # '2.00' (always to 2 decimal places)
    print $oc->roi;             # '100%' (always whole numbers or 'Inf.')

=cut

use Modern::Perl;
use POSIX qw (ceil);

use autodie;
use Moose;
use Moose::Util::TypeConstraints;

subtype 'ProbabilityType',
    as 'Num',
    where { $_ >= 0 && $_ <= 1 },
    message { 'probability value should be >= 0 and <= 1' };

has 'probability' => (
             is  => 'rw',
             isa => 'ProbabilityType',
             required => 1
         );

around BUILDARGS => sub {
    my $orig  = shift;
    my $class = shift;

    if ( @_ == 2 && !ref $_[0] ) {
        return $class->$orig( $_[0] => $_[1] );
    } else {
        return $class->$orig(@_);
    }
};

sub decimal_odds
{
    my $self = shift;

    my $odds = ($self->probability == 0) ? 'Inf.' :
                   sprintf("%0.2f", $self->calc_odds);
    return $odds;
}

sub roi
{
    my $self = shift;

    my $roi = ($self->probability == 0) ? 'Inf.' :
                  sprintf("%d%%", $self->calc_roi);
    return $roi;
}

sub calc_odds
{
    my $self = shift;
    return (1 / $self->probability) if ($self->probability != 0);
}

sub calc_roi
{
    my $self = shift;
    return ceil(($self->calc_odds - 1) * 100) if ($self->probability != 0);
}

1;

package ReferenDumb::Controller::Main;
use Mojo::Base 'Mojolicious::Controller';

use Mojo::JSON qw( decode_json );

my $CACHE_TIME = 1;

# helper function which returns (count, last_updated).
sub get_count {
    my $self = shift;

    # Worst cache in the world?
    state $count;
    state $last_updated;
    state $last_tried = 0;
    my $now = time;

    if($now >= $last_tried + $CACHE_TIME) {
        $last_tried = $now;
        my $tx = $self->ua->get(
            "https://petition.parliament.uk/petitions/131215.json",
            { Accept => 'application/json' }
        );
        if($tx->success) {
            my $data = decode_json $tx->res->body;
            $count = $data->{data}{attributes}{signature_count};
            $last_updated = $last_tried;
            $self->log->debug("Updated cached count to $count");
        } else {
            my $err = $tx->error;
            $self->log->error("Failed to update cached count");
            $self->log->debug("Keeping old cached $count from " . scalar gmtime $last_updated);
            if($err->{code}) {
                $self->log->error("$err->{code} response: $err->{message}");
            } else {
                $self->log->error("Connection error: $err->{message}");
            }
        }
    }

    return ($count, $last_updated);
}

sub commify($) {
    my($number) = @_;
    $number = int($number);
    1 while $number =~ s/(\d+)(\d{3})/$1,$2/;
    return $number;
}

sub root {
  my $self = shift;

  my ($count, $mtime) = $self->get_count;

  my $electorate = 46_501_241;
  my $leave = 17_410_742;
  my $remain = 16_141_241;
  my $rejected = 26_033;
  my $abstain = $electorate - $leave - $remain - $rejected;

  my %votes = (
      leave => $leave,
      remain => $remain,
      rejected => $rejected,
      abstain => $abstain,
  );

  my (@totals, %table);

  foreach my $kind (keys %votes) {
      # votes for this outcome
      my $votes = $votes{$kind};
      # fraction of votes for this outcome.
      my $fraction = $votes / $electorate;
      # pro-rated petition signatures
      my $signatures = $fraction * $count;
      # votes for this outcome if the petitioners switched to Remain
      my $remain_adjust = -$signatures;
      $remain_adjust += $count if $kind eq 'remain';
      # adjusted votes if this is a swing towards Remain
      my $new_votes = $votes + $remain_adjust;
      my @row = ( $votes, $fraction, $signatures, $remain_adjust, $new_votes );
      $table{$kind} = \@row;
      $totals[$_] += $row[$_] for (0..$#row);
  }

  $table{total} = \@totals;

  my @order = sort {
      $table{$a}[4] <=> $table{$b}[4]
      } keys %table;
  
  my %params = (
      table => \%table,
      order => \@order,
      count => $count,
      mtime => $mtime,
  );

#  use YAML;
  $self->render(
      %params,
      commify => \&commify,
#      msg => Dump \%params,
  );
}

1;

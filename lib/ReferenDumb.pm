package ReferenDumb;
use Mojo::Base 'Mojolicious';

use Mojo::Log;
use Mojo::UserAgent;

# This method will run once at server start
sub startup {
  my $self = shift;

  $self->helper(log => sub { state $log = Mojo::Log->new(
      level => 'debug',
  )});
  $self->helper(ua => sub { state $ua = Mojo::UserAgent->new });

  # Documentation browser under "/perldoc"
  #$self->plugin('PODRenderer');

  # Router
  my $r = $self->routes;

  # Normal route to controller
  $r->get('/')->to('Main#root');
}

1;

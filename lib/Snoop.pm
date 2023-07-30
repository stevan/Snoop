package Snoop;
use v5.38;

__END__

=pod

=encoding UTF-8

=head1 NAME

Snoop - Streaming JSON Tokens

=head1 DESCRIPTION

This is a system for publshing a stream of JSON tokens to multiple subscribers.

Here is roughtly what it will do:

=over 4

=item The publisher gets JSON from a source.

=item The publisher then "grinds" the JSON into single characters.

=item The publisher then "rolls" these characters up into tokens.

=item The publisher will then "pass" each token to it's subscriber in turn.

=item The subscribers then "inhales" the token and processes it internally.

=item After all toke(n)s have been taken, the publisher finishes the "sesh".

=item

=back

=head1 SEE ALSO

Puff, puff, pass.

=cut



use v5.38;
use experimental 'class', 'try', 'builtin';
use builtin 'blessed';

use Snoop::Core::Token;
use Snoop::Core::AST;

class Snoop::Parser {

    use constant OBJECT_MARKER => 1;
    use constant ARRAY_MARKER  => 2;

    field @stack;

    method accumulated_nodes { @stack }

    method parse (@tokens) {

        foreach my $token (@tokens) {
            if ( $token isa Snoop::Core::Token::StartObject ) {
                push @stack => OBJECT_MARKER;
            }
            elsif ( $token isa Snoop::Core::Token::EndObject ) {
                my $i = 0;
                my @properties;
                while (@stack) {
                    if ($stack[-1] == OBJECT_MARKER) {
                        pop @stack;
                        last;
                    }
                    else {
                        my $val = pop @stack;
                        my $key = pop @stack;

                        unshift @properties => Snoop::Core::AST::Property->new(
                            key   => $key->string,
                            value => $val,
                        );
                    }
                }
                push @stack => Snoop::Core::AST::Object->new( properties => \@properties );
            }
            elsif ( $token isa Snoop::Core::Token::StartProperty ) {
                ;
            }
            elsif ( $token isa Snoop::Core::Token::EndProperty ) {
                ;
            }
            elsif ( $token isa Snoop::Core::Token::StartArray ) {
                push @stack => ARRAY_MARKER;
            }
            elsif ( $token isa Snoop::Core::Token::EndArray ) {
                my $i = 0;
                my @items;
                while (@stack) {
                    if ($stack[-1] == ARRAY_MARKER) {
                        pop @stack;
                        last;
                    }
                    else {
                        unshift @items => Snoop::Core::AST::Item->new(
                            index => $i++,
                            value => pop @stack
                        );
                    }
                }

                push @stack => Snoop::Core::AST::Array->new( items => \@items );

            }
            elsif ( $token isa Snoop::Core::Token::StartItem ) {
                ;
            }
            elsif ( $token isa Snoop::Core::Token::EndItem ) {
                ;
            }
            elsif ( $token isa Snoop::Core::Token::AddString ) {
                push @stack => Snoop::Core::AST::String->new( string => $token->value );
            }
            elsif ( $token isa Snoop::Core::Token::AddInt ) {
                push @stack => Snoop::Core::AST::Int->new( int => $token->value );
            }
            elsif ( $token isa Snoop::Core::Token::AddFloat ) {
                push @stack => Snoop::Core::AST::Float->new( float => $token->value );
            }
            elsif ( $token isa Snoop::Core::Token::AddTrue ) {
                push @stack => Snoop::Core::AST::True->new;
            }
            elsif ( $token isa Snoop::Core::Token::AddFalse ) {
                push @stack => Snoop::Core::AST::False->new;
            }
            elsif ( $token isa Snoop::Core::Token::AddNull ) {
                push @stack => Snoop::Core::AST::Null->new;
            }
            elsif ( $token isa Snoop::Core::Token::Error ) {
                die "Got Error Token: ".$token->value;
            }
        }

        return @stack;
    }
}

__END__

=pod

=encoding UTF-8

=head1 NAME

Snoop::Parser - Streaming JSON Tokens

=head1 DESCRIPTION

=cut

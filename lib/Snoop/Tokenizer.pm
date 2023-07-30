
use v5.38;
use experimental 'class', 'try', 'builtin';
use builtin 'blessed';

use Snoop::Core::Token;

class Snoop::Tokenizer {

    use constant IN_OBJECT   => 1;
    use constant IN_ARRAY    => 2;
    use constant IN_PROPERTY => 3;
    use constant IN_ITEM     => 4;

    field @stack;
    field @context;
    field @chars;

    method accumulated_tokens { @stack }

    method tokenize ($source) {
        @chars = split // => $source;

        my $top = scalar @stack;
        try {
            while (@chars) {
                push @stack => $self->toke;
            }
        } catch ($e) {
            push @stack => Snoop::Core::Token::Error->new( error => $e );
        }

        return @stack[ $top .. $#stack ];
    }

    method toke {
        while (@chars) {
            my $char = shift @chars;

            if ($char eq ' ') {
                next;
            }

            elsif ($char eq '{') {
                push @context => IN_OBJECT;
                return Snoop::Core::Token::StartObject->new;
            }
            elsif ($char eq '}') {
                my @tokens;
                if ( $context[-1] == IN_PROPERTY ) {
                    pop @context;
                    push @tokens => Snoop::Core::Token::EndProperty->new;
                }

                if ( $context[-1] == IN_OBJECT ) {
                    pop @context;
                    return @tokens, Snoop::Core::Token::EndObject->new;
                }
                else {
                    return @tokens, Snoop::Core::Token::Error->new( error => 'Mismatched context found: char('.$char.') ('.$context[-1].') expected Object('.IN_OBJECT.') chars['.(join ', ', @chars).']' );
                }
            }
            elsif ($char eq ':') {
                if ( $context[-1] == IN_OBJECT ) {
                    if ( $stack[-1] isa Snoop::Core::Token::AddString ) {
                        my $key = pop @stack;
                        push @context => IN_PROPERTY;
                        return Snoop::Core::Token::StartProperty->new, $key;
                    }
                    else {
                        return Snoop::Core::Token::Error->new( error => 'Expected AddString token, got '.blessed $stack[-1] );
                    }
                }
                else {
                    return Snoop::Core::Token::Error->new( error => 'Mismatched context found: char('.$char.') ('.$context[-1].') expected Object('.IN_OBJECT.') chars['.(join ', ', @chars).']' );
                }
            }

            elsif ($char eq ',') {
                if ( $context[-1] == IN_PROPERTY ) {
                    pop @context;
                    return Snoop::Core::Token::EndProperty->new;
                }
                elsif ( $context[-1] == IN_ITEM ) {
                    return Snoop::Core::Token::EndItem->new,
                           Snoop::Core::Token::StartItem->new;
                }
            }

            elsif ($char eq '[') {
                push @context => IN_ARRAY, IN_ITEM;
                return Snoop::Core::Token::StartArray->new,
                       Snoop::Core::Token::StartItem->new;
            }
            elsif ($char eq ']') {
                my @tokens;
                if ( $context[-1] == IN_ITEM ) {
                    pop @context;
                    push @tokens => Snoop::Core::Token::EndItem->new;
                }

                if ( $context[-1] == IN_ARRAY ) {
                    pop @context;
                    return @tokens, Snoop::Core::Token::EndArray->new;
                }
                else {
                    return @tokens, Snoop::Core::Token::Error->new( error => 'Mismatched context found: char('.$char.') ('.$context[-1].') expected Array('.IN_ARRAY.') chars['.(join ', ', @chars).']' );
                }
            }

            elsif ($char eq '"') {
                my $string = '';
                my $is_closed = 0;

                while (@chars) {
                    if ($chars[0] eq '"') {
                        shift @chars;
                        $is_closed++;
                        last;
                    }
                    else {
                        $string .= shift @chars;
                    }
                }

                return Snoop::Core::Token::Error->new( error => "Unclosed string" ) unless $is_closed;

                return Snoop::Core::Token::AddString->new( value => $string );
            }
            elsif ($char =~ /\d/) {
                my $number = $char;
                my $is_float = 0;

                while (@chars) {
                    if ($chars[0] =~ /\d/) {
                        $number .= shift @chars;
                    }
                    elsif ($chars[0] eq '.') {
                        $is_float++;
                        $number .= shift @chars;
                    }
                    else {
                        last;
                    }
                }

                return $is_float
                    ? Snoop::Core::Token::AddFloat->new( value => $number )
                    : Snoop::Core::Token::AddInt->new( value => $number )
            }
            elsif ($char eq 't') {
                my $true = $char;
                foreach my $c ('r','u','e') {
                    if ($chars[0] ne $c) {
                        return Snoop::Core::Token::Error->new( error => "Invalid token, expected (true), got ($true)" );
                    }
                    else {
                        $true .= shift @chars;
                    }
                }

                return Snoop::Core::Token::AddTrue->new;
            }
            elsif ($char eq 'f') {
                my $false = $char;
                foreach my $c ('a','l','s', 'e') {
                    if ($chars[0] ne $c) {
                        return Snoop::Core::Token::Error->new( error => "Invalid token, expected (false), got ($false)" );
                    }
                    else {
                        $false .= shift @chars;
                    }
                }

                return Snoop::Core::Token::AddFalse->new;
            }
            elsif ($char eq 'n') {
                my $null = $char;
                foreach my $c ('u','l','l') {
                    if ($chars[0] ne $c) {
                        return Snoop::Core::Token::Error->new( error => "Invalid token, expected (null), got ($null)" );
                    }
                    else {
                        $null .= shift @chars;
                    }
                }

                return Snoop::Core::Token::AddNull->new;
            }
            else {
                return Snoop::Core::Token::Error->new( error => "Unrecognized char: $char" );
            }
        }

        return ();
    }
}

__END__

=pod

=encoding UTF-8

=head1 NAME

Snoop::Tokenizer - Streaming JSON Tokens

=head1 DESCRIPTION

=cut

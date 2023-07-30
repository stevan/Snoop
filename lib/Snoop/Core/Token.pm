
use v5.38;
use experimental 'class';

class Snoop::Core::Token {}

# Objects

class Snoop::Core::Token::StartObject :isa(Snoop::Core::Token) {}
class Snoop::Core::Token::EndObject   :isa(Snoop::Core::Token) {}

class Snoop::Core::Token::StartProperty :isa(Snoop::Core::Token) {}
class Snoop::Core::Token::EndProperty   :isa(Snoop::Core::Token) {}

# Arrays

class Snoop::Core::Token::StartArray :isa(Snoop::Core::Token) {}
class Snoop::Core::Token::EndArray   :isa(Snoop::Core::Token) {}

class Snoop::Core::Token::StartItem :isa(Snoop::Core::Token) {}
class Snoop::Core::Token::EndItem   :isa(Snoop::Core::Token) {}

# Literals

class Snoop::Core::Token::AddTrue  :isa(Snoop::Core::Token) {}
class Snoop::Core::Token::AddFalse :isa(Snoop::Core::Token) {}
class Snoop::Core::Token::AddNull  :isa(Snoop::Core::Token) {}

class Snoop::Core::Token::AddString :isa(Snoop::Core::Token) {
    field $value :param;

    method value { $value }
}
class Snoop::Core::Token::AddInt    :isa(Snoop::Core::Token) {
    field $value :param;

    method value { $value }
}
class Snoop::Core::Token::AddFloat  :isa(Snoop::Core::Token) {
    field $value :param;

    method value { $value }
}

# Errors

class Snoop::Core::Token::Error :isa(Snoop::Core::Token) {
    field $error :param;

    method value { $error }
    method error { $error }
}

__END__

=pod

=encoding UTF-8

=head1 NAME

Snoop::Core::Token - Streaming JSON Tokens

=head1 DESCRIPTION

=cut

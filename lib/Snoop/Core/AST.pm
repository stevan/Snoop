use v5.38;
use experimental 'class', 'try', 'builtin';
use builtin 'blessed';

class Snoop::Core::AST {
    method to_JSON { ... }
    method to_Perl { ... }
}

# basic literals ...

class Snoop::Core::AST::True :isa(Snoop::Core::AST) {
    method to_JSON { "true" }
    method to_Perl { 1 }
}

class Snoop::Core::AST::False :isa(Snoop::Core::AST) {
    method to_JSON { "false" }
    method to_Perl { 0 }
}

class Snoop::Core::AST::Null :isa(Snoop::Core::AST) {
    method to_JSON { "null" }
    method to_Perl { undef }
}

# value literals ...

class Snoop::Core::AST::String :isa(Snoop::Core::AST) {
    field $string :param;

    ADJUST {
        defined $string || die 'The `string` param must be a defined value';
    }

    method string { $string }

    method to_JSON { '"'.$string.'"' }
    method to_Perl { $string }
}

class Snoop::Core::AST::Int :isa(Snoop::Core::AST) {
    field $int :param;

    ADJUST {
        defined $int || die 'The `int` param must be a defined value';
    }

    method int { $int }

    method to_JSON { $int }
    method to_Perl { int $int }
}

class Snoop::Core::AST::Float :isa(Snoop::Core::AST) {
    field $float :param;

    ADJUST {
        defined $float || die 'The `float` param must be a defined value';
    }

    method float { $float }

    method to_JSON { $float }
    method to_Perl { 0.0+$float }
}

# complex objects ...

class Snoop::Core::AST::Object :isa(Snoop::Core::AST) {
    field $properties :param;

    ADJUST {
        ref $properties eq 'ARRAY'        || die 'The `properties` param must be an ARRAY ref';
        $_ isa Snoop::Core::AST::Property || die 'The `properties` param all be an Snoop::Core::AST::Property'
            foreach @$properties;
    }

    method properties { $properties }

    method to_JSON { '{ '.(join ', ' => map { $_->to_JSON } @$properties).' }' }
    method to_Perl { +{ map { $_->to_Perl } @$properties } }
}

class Snoop::Core::AST::Property :isa(Snoop::Core::AST) {
    field $key   :param;
    field $value :param;

    ADJUST {
        $key                        || die 'The `key` param must be a defined value';
        $value isa Snoop::Core::AST || die 'The `value` param must be an Snoop::Core::AST';
    }

    method key   { $key   }
    method value { $value }

    method to_JSON { '"'.$key.'" : '.$value->to_JSON }
    method to_Perl { $key => $value->to_Perl }
}

class Snoop::Core::AST::Array :isa(Snoop::Core::AST) {
    field $items :param;

    ADJUST {
        ref $items eq 'ARRAY'         || die 'The `items` param must be an ARRAY ref';
        $_ isa Snoop::Core::AST::Item || die 'The `items` param all be an Snoop::Core::AST::Item'
            foreach @$items;
    }

    method items { $items }

    method to_JSON { '[ '.(join ', ' => map { $_->to_JSON } @$items).' ]' }
    method to_Perl { +[ map { $_->to_Perl } @$items ] }
}

class Snoop::Core::AST::Item :isa(Snoop::Core::AST) {
    field $index :param;
    field $value :param;

    ADJUST {
        $index >= 0                 || die 'The `index` param must be greater than 0';
        $value isa Snoop::Core::AST || die 'The `value` param must be an Snoop::Core::AST';
    }

    method index { $index }
    method value { $value }

    method to_JSON { $value->to_JSON }
    method to_Perl { $value->to_Perl }
}

__END__

=pod

=encoding UTF-8

=head1 NAME

Snoop::Core::AST - Streaming JSON Tokens

=head1 DESCRIPTION

=cut

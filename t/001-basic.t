#!perl

use v5.38;
use experimental 'class', 'try', 'builtin';
use builtin 'blessed';

use Data::Dumper;

use Test::More;

use ok 'Snoop';
use ok 'Snoop::Tokenizer';
use ok 'Snoop::Parser';

my $AST = Snoop::Core::AST::Object->new(
    properties => [
        Snoop::Core::AST::Property->new(
            key   => 'foo',
            value => Snoop::Core::AST::String->new( string => 'bar' )
        ),
        Snoop::Core::AST::Property->new(
            key   => 'baz',
            value => Snoop::Core::AST::Array->new(
                items => [
                    Snoop::Core::AST::Item->new( index => 0, value => Snoop::Core::AST::Int->new( int => 10 ) ),
                    Snoop::Core::AST::Item->new( index => 1, value => Snoop::Core::AST::Float->new( float => 2.1 ) ),
                    Snoop::Core::AST::Item->new( index => 2, value => Snoop::Core::AST::True->new ),
                    Snoop::Core::AST::Item->new( index => 3, value => Snoop::Core::AST::False->new ),
                    Snoop::Core::AST::Item->new( index => 4, value => Snoop::Core::AST::Null->new ),
                ]
            )
        ),
    ]
);
isa_ok($AST, 'Snoop::Core::AST');

my $t = Snoop::Tokenizer->new;
isa_ok($t, 'Snoop::Tokenizer');

my @tokens = $t->tokenize( $AST->to_JSON );

isa_ok($_, 'Snoop::Core::Token') foreach @tokens;

my $p = Snoop::Parser->new;
isa_ok($p, 'Snoop::Parser');

my @nodes = $p->parse( @tokens );

isa_ok($_, 'Snoop::Core::AST') foreach @nodes;

is_deeply([ $nodes[0]->to_Perl ], [ $AST->to_Perl ], '... parsed is the same as original (in Perl)');
is($nodes[0]->to_JSON, $AST->to_JSON, '... parsed is the same as original (in JSON)');

warn $AST->to_JSON, "\n";
warn Dumper $AST->to_Perl;
warn Dumper [ map { blessed($_).($_->can('value') ? ' ['.$_->value.']' : '') } @tokens ];
warn Dumper [ map { $_->to_Perl } @nodes ];

done_testing;


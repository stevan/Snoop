#!perl

use v5.38;
use experimental 'class', 'try', 'builtin';
use builtin 'blessed';

use Data::Dumper;

use Test::More;

use ok 'Snoop';
use ok 'Snoop::Tokenizer';
use ok 'Snoop::Parser';


my $t = Snoop::Tokenizer->new;
isa_ok($t, 'Snoop::Tokenizer');

my $p = Snoop::Parser->new;
isa_ok($p, 'Snoop::Parser');

subtest '... test the first partial parse' => sub {
    my @tokens = $t->tokenize( '[ 10, 2.5, ' );
    #warn Dumper [ map { blessed($_).($_->can('value') ? ' ['.$_->value.']' : '') } @tokens ];
    isa_ok($_, 'Snoop::Core::Token') foreach @tokens;

    my @nodes = $p->parse( @tokens );
    #warn Dumper \@nodes;
};

subtest '... test the second partial parse' => sub {
    my @tokens = $t->tokenize( '{ "foo" : true, "bar" :' );
    #warn Dumper [ map { blessed($_).($_->can('value') ? ' ['.$_->value.']' : '') } @tokens ];
    isa_ok($_, 'Snoop::Core::Token') foreach @tokens;

    my @nodes = $p->parse( @tokens );
    #warn Dumper \@nodes;
};

subtest '... test the third partial parse' => sub {
    my @tokens = $t->tokenize( '[null,false] }, "END" ]' );
    #warn Dumper [ map { blessed($_).($_->can('value') ? ' ['.$_->value.']' : '') } @tokens ];
    isa_ok($_, 'Snoop::Core::Token') foreach @tokens;

    my @nodes = $p->parse( @tokens );
    #warn Dumper \@nodes;
};

my @tokens = $t->accumulated_tokens;
isa_ok($_, 'Snoop::Core::Token') foreach @tokens;

my @nodes = $p->accumulated_nodes;
isa_ok($_, 'Snoop::Core::AST') foreach @nodes;

#warn Dumper $nodes[0]->to_Perl;
my $result = [ 10, 2.5, { 'bar' => [ undef, 0 ], 'foo' => 1 }, 'END' ];

is_deeply($nodes[0]->to_Perl, $result, '... got the result we expected');


done_testing;


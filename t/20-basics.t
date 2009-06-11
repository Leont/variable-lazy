#!perl -T

use Test::More tests => 13;
use Variable::Lazy;

my $num = 1;

lazy my $x = { $num++ }

is($num, 1, '$num == 1');
is($x,   1, '$x   == 1');
is($num, 2, '$num == 2');
is($x,   1, '$x   == 1');

is((lazy { $num }), $num, 'lazy $num = $num');


sub foo {
	is($num, 2, '$num == 2');
	my $arg = shift;
	is($num, 3, '$num == 2');
}

foo(lazy { $num++ } );

my $y;

lazy $y = { --$num }

is($num, 3, '$num == 3');
is($y,   2, '$y   == 2');
is($num, 2, '$num == 2');
is($y,   2, '$y   == 2');

TODO: {
	$reference = $num;
	local $TODO = "Arguments and return values are still tricky";

	sub bar {
		return lazy { $_[0]++ }
	}

	my $ret = bar($num);

	is($num, $reference + 1, '$num == ' . ($reference + 1));
	is($ret, $reference, '$ret == $reference');
}

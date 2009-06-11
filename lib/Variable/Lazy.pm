package Variable::Lazy;

use strict;
use warnings;

BEGIN {
	our $VERSION = '0.01';
}
use Variable::Lazy::Util ();

use Devel::Declare ();
use B::Hooks::EndOfScope;

sub import {
	my $class = shift;
	my $package = caller;

	Devel::Declare->setup_for(
		$package,
		{ lazy => { const => \&_parser } }
	);
	{
		no strict 'refs';
		*{$package.'::lazy'} = \&Variable::Lazy::Util::lazy;
	}
}

my $counter = 0;

sub _parser {
	my ($declarator, $offset) = @_;
	my $linestr = Devel::Declare::get_linestr;
	for (substr($linestr, $offset)) {
		s/ ^ lazy \s* ( (?:my \s*)? \$ \w+ ) \s* = \s* {/lazy $1, \\\@_, sub { BEGIN { Variable::Lazy::_inject_scope }; /xms
			or s/ ^ lazy \s* {/lazy \\\@_, sub { /xms;
	}
#	warn qq{# "$linestr"};
	Devel::Declare::set_linestr($linestr);
}

sub _inject_scope {
    on_scope_end {
		my $linestr = Devel::Declare::get_linestr;
		my $offset = Devel::Declare::get_linestr_offset;
		substr($linestr, $offset, 0) = ';';
		Devel::Declare::set_linestr($linestr);
    };
}

1; # End of Variable::Lazy

__END__

=head1 NAME

Variable::Lazy - Lazy variables

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

 lazy $var = foo();

=head1 DESCRIPTION

This module implements lazy variables. It's different from other similar modules in that it works B<completely> transparant: there is no way to see from the outside that the variable was lazy, and there is no speed penalty once the variable has been evaluated.

=head1 AUTHOR

Leon Timmermans, C<< <leont at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-variable-lazy at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Variable-Lazy>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Variable::Lazy


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Variable-Lazy>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Variable-Lazy>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Variable-Lazy>

=item * Search CPAN

L<http://search.cpan.org/dist/Variable-Lazy>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2009 Leon Timmermans, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

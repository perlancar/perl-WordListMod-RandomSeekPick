package WordListMod::RandomSeekPick;

# AUTHORITY
# DATE
# DIST
# VERSION

use strict 'subs', 'vars';
use warnings;

our @patches = (
    ['pick', 'replace', sub {
         my ($self, $n) = @_;

         $n = 1 if !defined $n;
         die "Please don't pick too many items" if $n >= 10_000;

         my $class = ref($self);
         my $fh = \*{"$class\::DATA"};
         my $start = ${"$class\::DATA_POS"};
         my $end   = -s $fh;

         my %items;
         my $iter = 0;
         while (keys(%items) < $n) {

             seek $fh, $start + int(rand() * ($end-$start+1)), 0;
             <$fh>; # skip the line fragment
             seek $fh,0,0 if eof $fh; # wrap if hit EOF
             chomp(my $item = scalar <$fh>); # get the next line

             $items{$item}++;
             last if $iter++ > 50_000;
         }
         keys %items;
     }],
);

1;
# ABSTRACT: Provide a pick() implementation that random-seeks DATA

=head1 SYNOPSIS

 use WordListMod qw(get_mod_wordlist);
 my $wl = get_mod_wordlist("EN::Enable", "RandomSeekPick");
 say for $wl->pick(3);


=head1 DESCRIPTION

The default L<WordList>'s C<pick()> performs a scan on the whole word list once
while collecting random items. This role provides an alternative implementation
that random-seeks on DATA, discard the line fragment, then get the next line.
This algorithm does not provide uniformly random picking, but for many cases it
should be random enough. It is faster if you have a huge word list and just want
to pick one or a few items.

Note: since this role's C<pick()> operates on the DATA filehandle directly
instead of using C<each_word()>, it cannot be used on dynamic wordlists.


=head1 SEE ALSO

L<File::RandomLine> provides a similar algorithm.

L<WordListMod>, L<WordList>
xs

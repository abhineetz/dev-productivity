use strict;
use warnings;

my $fruits = ["apple", "banana"]; #anonymous array reference

print "ref $fruits\n";  # this will print the reference address

print "fetch ref value @$fruits\n"; # this will print reference values
print "fetch ref value @{$fruits}\n"; # this will also rint reference values

print "Get indexed value from array reference: @{$fruits}[0]\n"; 

my $indVal =  @{$fruits}[0];
print "indexed val $indVal\n";
my $indVal1 =  @$fruits[0];	# Curly parenthesis can be removed
print "INdexed val 1 $indVal1\n";


my $indVal2 = $fruits -> [0];
print "INdexed val 2 $indVal2\n";


#!/usr/bin/perl

use strict;
use warnings;

use Text::CSV_XS;
use IO::Handle;

use ImportRaboCsvHelper::Process;
use ImportRaboCsvHelper::Example;

my $filename = $ARGV[0] || 'mut.txt';

ImportRaboCsvHelper::prepare();

# Open the INPUT file
my $csv = Text::CSV_XS->new ({ binary => 1 });
open my $fh, "<", $filename or die "$filename: $!";

print "\# Mutations imported from $filename\n";

while (my $row = $csv->getline ($fh)) {
	next if (@$row <= 1);	# Skip the final, empty line. It sometimes has a ^Z char in files from Rabobank

	my $hash = ImportRaboCsvHelper::interpretArrayToHash($row);

	# Do the real work
	my $out = ImportRaboCsvHelper::analyse($hash);

	print $out . "\n\n";
}
close $fh or die "$filename: $!";

ImportRaboCsvHelper::finish();

1;

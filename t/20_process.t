use strict;
use warnings;

use lib '../';
use Test::More tests => 3;
use_ok("ImportRaboCsvHelper::Process");
use_ok("ImportRaboCsvHelper::Example");


# Example input
my $row = [
   '0329458485',
   'EUR',
   '20080911',
   'C',
   '92.23',
   '0371234567',
   'Acme Corp.',
   '20080911', 
   'BY',
   '',
   'FACTUURNR 2008001',
   '', 
   '',
   '',
   '',
   ''
]; 

my %hashrow = (
	'date' => '2008-09-11',
	'debcred' => 'C',
	'desc' => 'FACTUURNR 2008001',
	'euro' => '92.23',
	'bankaccount' => '371234567', 
	'name' => 'Acme Corp.',
	'bankcode' => 'BY',
);

my $out = ImportRaboCsvHelper::interpretArrayToHash($row);

is_deeply($out, \%hashrow, "process CSV array into hash");


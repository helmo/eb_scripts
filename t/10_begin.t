use strict;
use warnings;

use lib '../';
use Test::More tests => 4;
use_ok("ImportRaboCsvHelper::Process");
use_ok("ImportRaboCsvHelper::Example");

# Test some very generic stuff from teh helper functions

my %hashrow = (
	'date' => '2008-01-11',
	'debcred' => 'C',
	'desc' => 'FACTUURNR 2008001',
	'euro' => '92.23',
	'bankaccount' => '123456001', 
	'name' => 'Acme Corp.',
	'bankcode' => 'BY',
);

# IsAgainstPrivateAccount
ok(ImportRaboCsvHelper::IsAgainstPrivateAccount(\%hashrow), 'IsAgainstPrivateAccount');

# IsAgainstPrivateAccount negative case
$hashrow{'bankaccount'} = '123456002';
ok(!ImportRaboCsvHelper::IsAgainstPrivateAccount(\%hashrow), 'IsAgainstPrivateAccount for non private account');



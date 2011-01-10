use strict;
use warnings;

use lib '../';
use Test::More tests => 8;
use_ok("ImportRaboCsvHelper::Process");
use_ok("ImportRaboCsvHelper::Example");


my %hashrow = ();
my $out = undef;

# Some simple ACME case
%hashrow = (
	'date' => '2008-01-11',
	'debcred' => 'C',
	'desc' => 'FACTUURNR 2008001',
	'euro' => '92.23',
	'bankaccount' => '0371234567', 
	'name' => 'Acme Corp.',
	'bankcode' => 'BY',
);

$out = ImportRaboCsvHelper::analyse(\%hashrow);

is($out, "rabobank 2008-01-11 \"FACTUURNR 2008001\" \n\tcrd \"ACME\" +92.23", "Some simple ACME case");


#  Test with Unknown corporation, ebcode will not be found
%hashrow = (
	'date' => '2008-01-11',
	'debcred' => 'C',
	'desc' => 'FACTUURNR 2008001',
	'euro' => '92.23',
	'bankaccount' => '123456003', 
	'name' => 'Some unknown Corp.',
	'bankcode' => 'BY',
);

$out = ImportRaboCsvHelper::analyse(\%hashrow);

is($out, "rabobank 2008-01-11 \"FACTUURNR 2008001\" \n\tcrd \"UNKNOWN\" +92.23", "Unknown corporation");


#  Test with Prive opname
%hashrow = (
	'bankaccount' => '123456001',
	'bankcode' => 'bg',
	'desc' => 'Winst uitkering',
	'date' => '2010-12-31',
	'name' => 'Me',
	'debcred' => 'D',
	'euro' => '1000.00'
);

$out = ImportRaboCsvHelper::analyse(\%hashrow);

is($out, "rabobank 2010-12-31 \"Winst uitkering\" \n\tstd \"Winst uitkering\" -1000.00 3120", "Prive opname");

#  Test with Prive storting
%hashrow = (
	'bankaccount' => '123456001',
	'bankcode' => 'bg',
	'desc' => 'Extra cash injectie',
	'date' => '2010-12-31',
	'name' => 'Me',
	'debcred' => 'C',
	'euro' => '1000.00'
);

$out = ImportRaboCsvHelper::analyse(\%hashrow);

is($out, "rabobank 2010-12-31 \"Extra cash injectie\" \n\tstd \"Extra cash injectie\" +1000.00 3110", "Prive storting");

#  Test with Rabobank kosten
%hashrow = (
          'bankaccount' => '',
          'bankcode' => 'db',
          'desc' => 'Periode 01-10-2009 t/m 31-12-200',	# The missing final year digit is an upstream bug, not a typo here
          'date' => '2010-01-01',
          'name' => 'Kosten',
          'debcred' => 'D',
          'euro' => '42.42'
        );
$out = ImportRaboCsvHelper::analyse(\%hashrow);

is($out, "rabobank 2010-01-01 \"Periode 01-10-2009 t/m 31-12-200\" \n\tcrd \"RABOBANK\" -42.42", "Banking costs");

#  Test with uitgave
%hashrow = (
          'bankaccount' => 'P4683839',
          'bankcode' => 'ma',
          'desc' => 'BETALINGSKENM.  ARNL-1234567891- BETREFT*23456789 XS4ALL INTERNET BV',
          'date' => '2010-01-14',
          'name' => 'XS4ALL INTERNET BV',
          'debcred' => 'D',
          'euro' => '39.95'
        );
$out = ImportRaboCsvHelper::analyse(\%hashrow);

is($out, "rabobank 2010-01-14 \"BETALINGSKENM.  ARNL-1234567891- BETREFT*23456789 XS4ALL INTERNET BV\" \n\tcrd \"XS4ALL\" -39.95", "Regular outgoing");



# TODO 

# uitgave
# belastingdienst



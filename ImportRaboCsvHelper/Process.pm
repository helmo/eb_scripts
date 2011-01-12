
package ImportRaboCsvHelper;

use strict;
use warnings;

use Data::Dumper;

sub interpretArrayToHash($) {
	my $row = shift;

	# Ignore incomplete and empty lines
	if (@$row < 16) {
		warn "col count < 16: " . @$row;
		warn Dumper $row;
	}

	# Convert the date format from yyyymmdd to yyyy-mm-dd
	my $date = @$row[2] ;
	$date =~ s/(\d{4})(\d{2})(\d{2})/$1-$2-$3/;

	my $description = @$row[10] .' '. @$row[11] .' '. @$row[12] .' '. @$row[13];
	$description =~ s/\s*$//;

	# Interpret some usefull fields from the CSV data into our own strcuture
	my %hashrow = (
		'date' => $date,
		'debcred' => @$row[3],
		'desc' => $description,
		'euro' => @$row[4],
		'bankaccount' => @$row[5],
		'name' => @$row[6],
		'bankcode' => @$row[8],
	);

	$hashrow{'bankaccount'} =~ s/^0+//;  # Remove leading zero's

	return \%hashrow;
}

sub analyse {
	my $ref = shift;
	my %hashrow = %{$ref};
	# Speciale filters
	#  TODO   iets voor de balasting dienst 

	my $out;
	our $unknown_count;

	#warn Dumper \%hashrow;

	# Lookup ebcode to reference the relation
	$hashrow{'ebcode'} = ImportRaboCsvHelper::getEekboekCodeBy(\%hashrow);

	if (!defined $hashrow{'ebcode'}) {
		$hashrow{'ebcode'} = 'UNKNOWN';
		$unknown_count++;	

		# Print all info to let the user fill in the UNKNOWN's later 
		print Dumper \%hashrow;
	}

	# Debet or Credit
	my $sign = '';
	$out .= ImportRaboCsvHelper::getBalansRekening() . " $hashrow{date} \"$hashrow{desc}\" \\\n";
	if ( $hashrow{'debcred'} eq 'C' ) {
		$sign = '+';

	} elsif ( $hashrow{'debcred'} eq 'D' ) {
		$sign = '-';
	}

	# Handle the transaction based on it's bankcode (See README for a list of bankcode abbreviations)

	# Binnenkomend bedrag
	if ( $hashrow{'bankcode'} =~ /(bg|cb)/i &&  $hashrow{'debcred'} eq 'C' ) {

		if ( ImportRaboCsvHelper::IsAgainstPrivateAccount(\%hashrow) ) {
			$out .= "\tstd \"$hashrow{desc}\" $sign$hashrow{euro} " . ImportRaboCsvHelper::schemaPriveStoring();
		} else {
			$out .= "\tdeb \"$hashrow{ebcode}\" $sign$hashrow{euro}";
		}

	# Boeking naar Prive
	} elsif ( $hashrow{'bankcode'} =~ /bg/i 
			&& $hashrow{'debcred'} eq 'D'
			&& ImportRaboCsvHelper::IsAgainstPrivateAccount(\%hashrow)) {
		
		$out .=  "\tstd \"$hashrow{desc}\" $sign$hashrow{euro} " . ImportRaboCsvHelper::schemaPriveOpname();
		

	# Eigen rekening
	} elsif ( $hashrow{'bankcode'} =~ /tb/i ) {
		my $rek = ImportRaboCsvHelper::BankaccountToSchema($hashrow{'bankaccount'}) || 'UNKNOWN';
		
		$out .= "\tstd \"$hashrow{desc}\" $sign$hashrow{euro} $rek";
		$unknown_count--;
	
	# Overige uitgaande betalingen
	} else {
		# Overig, uitgaand codes o.a (See README for a full list of bankcode abbreviations)
		# OV - overmaking  ( ook iDeal)
		# MA - Machtiging
		# GA - Geld automaat - muurpinnen
		# BA - Betaal automaat - winkel pinnen
		# AC - Acceptgiro?
		$out .= "\tcrd \"$hashrow{ebcode}\" $sign$hashrow{euro}";
	}
#	warn Dumper $row;
	return $out;
}
1;


package ImportRaboCsvHelper;

use Carp;

=pod

Used account numbers:

123456001	Private account - tegenrekening bij Prive opname/storting
123456002	Company savings account - eigen rekening
123456003	Some unknown company
123456004	Company checking account this import relates to - eigen rekening 
0371234567	ACME Corp

=cut

sub getEekboekCodeBy {
	my $hashrow = shift;

	my $ebcode = 'UNKNOWN';
	# Rabobank kosten
	if ( $hashrow->{'bankaccount'} eq ''
   			&& ($hashrow->{'bankcode'} =~ /DB/i 
				 || $hashrow->{'bankcode'} =~ /DA/i ) ) {
		$ebcode = 'RABOBANK';	
	}

	if ( $hashrow->{'name'} =~ /ACME/i ) {
		$ebcode = 'ACME';
	}
	if ( $hashrow->{'name'} =~ /XS4ALL INTERNET BV/i ) {
		$ebcode = 'XS4ALL';
	}
	# Database lookup
#	if ( !defined $ebcode ) {
#		($ebcode, $company_id) = $dbh->selectrow_array("
#			SELECT ebcode, id
#					FROM company
#					WHERE MATCH(name) AGAINST(?) 
#						", {}, $hashrow->{'name'});
#	}		

	return $ebcode;
}

# Test whether this transaction relates to a Personal Private account
sub IsAgainstPrivateAccount{
	my $hashrow = shift;
	return $hashrow->{'bankaccount'} =~ /0*123456001/;
}

sub schemaPriveStoring{
	return '3110';
}
sub schemaPriveOpname{
	return '3120';
}

# Get the name of the eekboek balansrekening this import relates to
sub getBalansRekening{
	return 'rabobank';
}

# Map a numeric bankaccount to an eekboek schema number
sub BankaccountToSchema{
	my $bankaccount_number = shift;
	my $rek;
	SWITCH: for ($bankaccount_number) {
		/^123456002$/ && do {
			$rek = '2330';
			last; };

		croak "Unknown eigen rekening, please add to BankaccountToSchema()";
	}
	return $rek
}

# Some preparation before we can begin
sub prepare{
    our $unknown_count = 0;
}

# Some cleanup tasks
sub finish{
    our $unknown_count;
    warn "Unknown count was: $unknown_count";
}


1;

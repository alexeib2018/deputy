package Deputy;
use strict;
use warnings;
use Exporter;
use Net::Curl::Easy;

require "settings.pl";
our $endpoint;
our $token;

our @ISA= qw( Exporter );

# these CAN be exported.
our @EXPORT_OK = qw( POST );

# these are exported by default.
# our @EXPORT = qw( export_me );

sub POST {
	my $url = shift;
	my $postvars = shift;

	my $curl = Net::Curl::Easy->new;

	$curl->setopt(Net::Curl::Easy::CURLOPT_HTTPGET(), 1);
	$curl->setopt(Net::Curl::Easy::CURLOPT_RESUME_FROM(), 0);
	$curl->setopt(Net::Curl::Easy::CURLOPT_URL(), $endpoint.$url);
	#$curl->setopt(Net::Curl::Easy::CURLOPT_RETURNTRANSFER(), 1);
	$curl->setopt(Net::Curl::Easy::CURLOPT_FOLLOWLOCATION(), 1);

	$curl->setopt(Net::Curl::Easy::CURLOPT_SSL_VERIFYHOST(), 0);
	$curl->setopt(Net::Curl::Easy::CURLOPT_SSL_VERIFYPEER(), 0);
	$curl->setopt(Net::Curl::Easy::CURLOPT_TIMEOUT(), 500);

	if($postvars){
		$curl->setopt(Net::Curl::Easy::CURLOPT_POST(), 1);
		$curl->setopt(Net::Curl::Easy::CURLOPT_POSTFIELDS(), $postvars);
	}

	$curl->setopt(Net::Curl::Easy::CURLOPT_HTTPHEADER(), [ 'Content-type: application/json',
														   'Accept: application/json',
														   'Authorization : OAuth ' . $token,
														   'dp-meta-option : none' ]);

	my $response_body;
	$curl->setopt(Net::Curl::Easy::CURLOPT_WRITEDATA(), \$response_body);

	my $retcode = $curl->perform;

	$response_body;
}

1;

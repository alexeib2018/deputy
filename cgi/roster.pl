#!/usr/bin/env perl
use strict;
use warnings;
use Net::Curl::Easy;

require "settings.pl";
our $endpoint;
our $token;

my $url = '/api/v1/resource/Roster/QUERY';
my $postvars = '{"search": {"f1": {"field":"Id", "type":"gt", "data":0}, "f2": {"field":"Date", "type":"eq", "data":"'.$ARGV[0].'"}}}';

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

my $retcode = $curl->perform;

#!/usr/bin/env perl
use strict;
use warnings;
use Net::Curl::Easy;
#use JSON;
use JSON::Parse 'parse_json';


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

my $response_body;
$curl->setopt(Net::Curl::Easy::CURLOPT_WRITEDATA(), \$response_body);

my $retcode = $curl->perform;

my $filename = "roster.csv";
open(FH, '>', $filename) or die $!;

my @json_arr = parse_json($response_body);

my @arr = @{$json_arr[0]};
my $arr_size = scalar @arr;
for(my $i=0; $i<$arr_size; $i++) {
	my %rec = %{$arr[$i]};
	my $display_name = $rec{"Comment"};
	my $schedule_date = $rec{"Date"};
	my $schedule_start_time = $rec{"StartTime"};
	my $schedule_end_time = $rec{"EndTime"};
	my $schedule_meal_break = $rec{"Mealbreak"};
	my $schedule_total_time = $rec{"TotalTime"};
	my $timesheet_start_time = $rec{"StartTimeLocalized"};
	my $timesheet_end_time = $rec{"EndTimeLocalized"};
	my $position = $rec{"Id"};

	print FH "$display_name,$schedule_date,$schedule_start_time,$schedule_end_time,$schedule_meal_break,$schedule_total_time,$timesheet_start_time,$timesheet_end_time,$position\n";
}

close FH;
#print "pretty:\n".JSON->new->pretty->encode(\@arr);

0;

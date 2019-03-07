#!/usr/bin/env perl
use strict;
use warnings;
use Net::Curl::Easy;
#use JSON;
use JSON::Parse 'parse_json';

require "settings.pl";
our $endpoint;
our $token;

my $url = '/api/v1/resource/Timesheet/QUERY';
my $postvars = '{"search": {"f1": {"field":"Date", "type":"ge", "data":"'.$ARGV[0].'"}, "f2": {"field":"Date", "type":"le", "data":"'.$ARGV[1].'"}}}';

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

my $filename = "timesheet.csv";
open(FH, '>', $filename) or die $!;

my @json_arr = parse_json($response_body);

my @arr = @{$json_arr[0]};
my $arr_size = scalar @arr;
for(my $i=0; $i<$arr_size; $i++) {
	my %rec = %{$arr[$i]};
	my $display_name = $rec{"EmployeeComment"} ? $rec{"EmployeeComment"} : "";
	my $timesheet_date = $rec{"Date"};
	my $timesheet_start_time = $rec{"StartTime"};
	my $timesheet_end_time = $rec{"EndTime"};
	my $timesheet_total_time = $rec{"TotalTime"};
	my $schedule_start_time = $rec{"StartTimeLocalized"};
	my $schedule_end_time = $rec{"EndTimeLocalized"};
	my $employee_payroll_export_code = $rec{"Employee"};

	print FH "$display_name,$timesheet_date,$timesheet_start_time,$timesheet_end_time,$timesheet_total_time,$schedule_start_time,$schedule_end_time,$employee_payroll_export_code\n";
}

close FH;
#print "pretty:\n".JSON->new->pretty->encode(\@arr);

0;

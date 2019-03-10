#!/usr/bin/env perl
use strict;
use warnings;
use Net::Curl::Easy;
#use JSON;
use JSON::Parse 'parse_json';
use Deputy;

require "settings.pl";
our $endpoint;
our $token;

my $url = '/api/v1/resource/Timesheet/QUERY';
my $postvars = '{"search": {"f1": {"field":"Date", "type":"ge", "data":"'.$ARGV[0].'"}, "f2": {"field":"Date", "type":"le", "data":"'.$ARGV[1].'"}}}';
my $response_body = Deputy::POST($url, $postvars);

my $filename = "timesheet.csv";
open(FH, '>', $filename) or die $!;
print FH "\"Display Name\",\"Timesheet Date\",\"Timesheet Start Time\",\"Timesheet End Time\",\"Timesheet Total Time\",\"Schedule Start Time\",\"Schedule End Time\",\"Employee Export Code\"\n";

my @json_arr = parse_json($response_body);

my @arr = @{$json_arr[0]};
my $arr_size = scalar @arr;
for(my $i=1; $i<=$arr_size; $i++) {
	my %rec = %{$arr[$i]};

	my @employee_arr = @{Deputy::get_employee($rec{"Employee"})};
	my %employee = %{$employee_arr[0]};

	# print "employee:\n".JSON->new->pretty->encode(\%employee);
	my $display_name = $employee{"DisplayName"};
	my $employee_id = $employee{"Id"};
	print "$i($arr_size) $display_name ($employee_id)\n";

	my $employee_export_code = $employee{"PayrollId"};

	my $timesheet_date = substr $rec{"StartTimeLocalized"}, 0, 10;
	my $timesheet_start_time = substr $rec{"StartTimeLocalized"}, 11, 5;
	my $timesheet_end_time = substr $rec{"EndTimeLocalized"}, 11, 5;
	my $timesheet_total_time = $rec{"TotalTime"};
	my $schedule_start_time = substr $rec{"StartTimeLocalized"}, 11, 5;
	my $schedule_end_time = substr $rec{"EndTimeLocalized"}, 11, 5;

	print FH "\"$display_name\",\"$timesheet_date\",\"$timesheet_start_time\",\"$timesheet_end_time\",\"$timesheet_total_time\",\"$schedule_start_time\",\"$schedule_end_time\",\"$employee_export_code\"\n";
}

close FH;
#print "pretty:\n".JSON->new->pretty->encode(\@arr);

exit(0);

<<EOF
[{
	"Id":1,
	"Employee":1,										# Display name, employee export code
	"EmployeeHistory":2566,
	"EmployeeAgreement":3,
	"Date":"2019-03-02T00:00:00-05:00",					# timesheet date
	"StartTime":1551502800,								# timesheet start time
	"EndTime":1551520800,								# timesheet end time
	"Mealbreak":"2019-03-02T01:00:00-05:00",
	"MealbreakSlots":"",
	"Slots":[{
		"blnEmptySlot":false,
		"strType":"B",
		"intStart":3600,
		"intEnd":5400,
		"intUnixStart":1551506400,
		"intUnixEnd":1551508200,
		"mixedActivity":{
			"intState":4,
			"blnCanStartEarly":1,
			"blnCanEndEarly":1,
			"blnIsMandatory":1,
			"strBreakType":"M"},
		"strTypeName":"Meal Break",
		"strState":"Finished Duration"},
		{
		"blnEmptySlot":false,
		"strType":"B",
		"intStart":3600,
		"intEnd":5400,
		"intUnixStart":1551506400,
		"intUnixEnd":1551508200,
		"mixedActivity":{
			"intState":4,
			"blnCanStartEarly":1,
			"blnCanEndEarly":1,
			"blnIsMandatory":1,
			"strBreakType":"M"},
		"strTypeName":"Meal Break",
		"strState":"Finished Duration"}],
	"TotalTime":4,										# timesheet total time
	"TotalTimeInv":4,
	"Cost":0,
	"Roster":1,
	"EmployeeComment":null,
	"SupervisorComment":null,
	"Supervisor":null,
	"Disputed":false,
	"TimeApproved":true,
	"TimeApprover":1,
	"Discarded":null,
	"ValidationFlag":0,
	"OperationalUnit":1,
	"IsInProgress":null,
	"IsLeave":false,
	"LeaveId":null,
	"LeaveRule":null,
	"Invoiced":false,
	"InvoiceComment":null,
	"PayRuleApproved":true,
	"Exported":null,
	"StagingId":null,
	"PayStaged":false,
	"PaycycleId":5798,
	"File":null,
	"CustomFieldData":null,
	"RealTime":false,
	"AutoProcessed":false,
	"AutoRounded":false,
	"AutoTimeApproved":false,
	"AutoPayRuleApproved":true,
	"Creator":1,
	"Created":"2019-03-02T10:58:25-05:00",
	"Modified":"2019-03-02T10:58:25-05:00",
	"OnCost":0,
	"StartTimeLocalized":"2019-03-02T00:00:00-05:00",	schedule start time
	"EndTimeLocalized":"2019-03-02T05:00:00-05:00"		schedule end time
}]

Timesheet: Columns (in order): Display name, timesheet date, timesheet start time, timesheet end time, timesheet total time, schedule start time, schedule end time, employee payroll export code
EOF

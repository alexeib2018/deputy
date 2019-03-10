#!/usr/bin/env perl
use strict;
use warnings;
use Net::Curl::Easy;
use JSON;
use JSON::Parse 'parse_json';
use Deputy;


my $url = '/api/v1/resource/Roster/QUERY';
my $postvars = '{"search": {"f1": {"field":"Id", "type":"gt", "data":0}, "f2": {"field":"Date", "type":"eq", "data":"'.$ARGV[0].'"}}}';
my $response_body = Deputy::POST($url, $postvars);

my $filename = "roster.csv";
open(FH, '>', $filename) or die $!;

my @json_arr = parse_json($response_body);
# print $response_body."\n";

my @arr = @{$json_arr[0]};
my $arr_size = scalar @arr;
for(my $i=1; $i<=$arr_size; $i++) {
	my %rec = %{$arr[$i]};

	my @employee_arr = @{Deputy::get_employee($rec{"Employee"})};
	my %employee = %{$employee_arr[0]};

	# print "employee:\n".JSON->new->pretty->encode(\%employee);
	my $display_name = $employee{"DisplayName"};
	print "$i($arr_size) $display_name\n";

	my $position = $employee{"Position"} ? $employee{"Position"} : "";

	my $schedule_date = $rec{"Date"};
	my $schedule_start_time = $rec{"StartTime"};
	my $schedule_end_time = $rec{"EndTime"};
	my $schedule_meal_break = $rec{"Mealbreak"};
	my $schedule_total_time = $rec{"TotalTime"};
	my $timesheet_start_time = $rec{"StartTimeLocalized"};
	my $timesheet_end_time = $rec{"EndTimeLocalized"};

	print FH "$display_name,$schedule_date,$schedule_start_time,$schedule_end_time,$schedule_meal_break,$schedule_total_time,$timesheet_start_time,$timesheet_end_time,$position\n";
}

close FH;
#print "pretty:\n".JSON->new->pretty->encode(\@arr);

exit(0);

<<EOF
[{
	"Id":1,
	"Date":"2019-03-02T00:00:00-05:00",					# schedule date
	"StartTime":1551535200,								# schedule start time
	"EndTime":1551564000,								# schedule end time
	"Mealbreak":"2019-03-04T00:30:00-05:00",			# schedule meal break (Total)
	"Slots":[{
		"blnEmptySlot":false,
		"strType":"B",
		"intStart":0,
		"intEnd":1800,
		"intUnixStart":1551535200,
		"intUnixEnd":1551537000,
		"mixedActivity":{
			"intState":3,
			"blnCanStartEarly":1,
			"blnCanEndEarly":1,
			"blnIsMandatory":1,
			"strBreakType":"M"},
		"strTypeName":"Meal Break",
		"strState":"Scheduled Duration"}],
	"TotalTime":7.5,								 	# schedule total time
	"Cost":0,
	"OperationalUnit":1,
	"Employee":1,										# Display name, position
	"Comment":"Test version",
	"Warning":"",
	"WarningOverrideComment":"",
	"Published":false,
	"MatchedByTimesheet":1,
	"Open":false,
	"ConfirmStatus":0,
	"ConfirmComment":"",
	"ConfirmBy":0,
	"ConfirmTime":0,
	"SwapStatus":0,
	"SwapManageBy":null,
	"ShiftTemplate":1,
	"ConnectStatus":null,
	"Creator":1,
	"Created":"2019-03-02T10:56:44-05:00",
	"Modified":"2019-03-02T10:58:25-05:00",
	"OnCost":0,
	"StartTimeLocalized":"2019-03-02T09:00:00-05:00",	# timesheet start time
	"EndTimeLocalized":"2019-03-02T17:00:00-05:00",		# timesheet end time
	"ExternalId":null,
	"ConnectCreator":null
}]

Schedule (roster): Columns (in order): Display name, schedule date, schedule start time, schedule end time, schedule meal break (Total), schedule total time, timesheet start time, timesheet end time, position
EOF

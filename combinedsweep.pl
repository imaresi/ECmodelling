#Welcome to the Perl-Zacros hybrid. This script is designed to run an unpwards and downwards voltage sweep to be used in Zacros.
use warnings;
use strict;

my $simulation = "simulation_input.dat";
my $editedsimulation ="simulation_input_new.dat";

#Define temperature ramp: start of ramp and rate of change (K/s)
my $Tstart = 1.01;
my $Tchange = 1.5;

#Edit simulation_input file and save this as simulation_input_new.dat
open my $simupin,  '<', "$simulation" or die "Can't read $simulation: $!";
open my $simupout, '>', "$editedsimulation" or die "Can't write new file to $editedsimulation: $!";

while( <$simupin> )   # print the lines before the change
    {
    print $simupout $_;
    last if $. == 8; # line number before change
    }

my $simupline = <$simupin>;
$simupline = "temperature               ramp $Tstart $Tchange   # Will modify with other values\n";
print $simupout $simupline;

while( <$simupin> )   # print the rest of the lines
    {
    print $simupout $_;
    }

#Now we need to delete the old simulation file -- simulation_input.dat
unlink("$simulation");

#Now, renaming the new, edited, file to simulation_input.dat so that it can run in Zacros.
rename $editedsimulation,"simulation_input.dat";

my $initialCO = 2250;

#We also need to define the state.
my $stateup = "state_input.dat";
my $editedstateup ="state_input_new.dat";

my $percentageup = $initialCO/2500*100;

open my $stateinup,  '<', "$stateup" or die "Can't read $stateup: $!";
open my $stateoutup, '>', "$editedstateup" or die "Can't write new file to $editedstateup: $!";

while( <$stateinup> )   # print the lines before the change
    {
    print $stateoutup $_;
    last if $. == 7; # line number before change
    }

my $statelineup = <$stateinup>;
$statelineup = "   seed_multiple CO*        $initialCO # This is $percentageup% coverage \n";
print $stateoutup $statelineup;

while( <$stateinup> )   # print the rest of the lines
    {
    print $stateoutup $_;
    }

#Now we need to delete the old state file -- state_input.dat
unlink("$stateup");

#Rename the file
rename $editedstateup,"state_input.dat";

#Now we run Zacros with these input files.
my $ZacrosSpecies =  "specnum_output.txt";
my $speciesCounts  = "speciesVsTime.txt";              # Frequency is same as for specnum_output.txt

#Precleaning
system("rm -f $ZacrosSpecies");

#Run Zacros
system("./zacros.x");

#Create speciesVsTime file.
system("tr -s ' ' < $ZacrosSpecies | cut -d ' ' -f2,4,5,7,8,9,10 > $speciesCounts");

#Now we need to save the final state in the speciesVsTime file. This means saving the end amount of OH*
open my $finalstatefile, "<", $speciesCounts or die "Can't open $speciesCounts: $!\n";

my $lastline;
$lastline = $_ while <$finalstatefile>;

my @values = split(' ', $lastline);

#Ok so this prints the final value of OH* from the speciesVsTime file. Now that we have this it's time to edit
#the input file with this value.
my $finalOH = $values[4];
print "At the end of the sweep-up, the OH coverage is: $finalOH\n";

#Lets also find the last value in the time column. This is to be used later to adjust the time of the appended values.
my $finaltime = $values[1];
print "At the end of the sweep-up, the time is: $finaltime s\n";

#Editing state_input file
my $state = "state_input.dat";
my $editedstate ="state_input_new.dat";

my $percentage = $finalOH/2500*100;

open my $statein,  '<', "$state" or die "Can't read $state: $!";
open my $stateout, '>', "$editedstate" or die "Can't write new file to $editedstate: $!";

while( <$statein> )   # print the lines before the change
    {
    print $stateout $_;
    last if $. == 7; # line number before change
    }

my $stateline = <$statein>;
$stateline = "   seed_multiple OH*        $finalOH # This is $percentage% coverage \n";
print $stateout $stateline;

while( <$statein> )   # print the rest of the lines
    {
    print $stateout $_;
    }

#Now we need to delete the old state file -- state_input.dat
unlink("$state");

#Lets change the temperature ramp in the simulation_input.dat file so that it now has a downwards sweep.
#Define temperature ramp: start of ramp and rate of change (K/s)
my $Tstartdown = 1.01;
my $Tchangedown = -0.005;

#my $simulation = "simulation_input.dat";
#my $editedsimulation ="simulation_input_new.dat";

#Edit simulation_input file and save this as simulation_input_new.dat
open my $simdownin,  '<', "$simulation" or die "Can't read $simulation: $!";
open my $simdownout, '>', "$editedsimulation" or die "Can't write new file to $editedsimulation: $!";

while( <$simdownin> )   # print the lines before the change
    {
    print $simdownout $_;
    last if $. == 8; # line number before change
    }

my $simdownline = <$simdownin>;
$simdownline = "temperature               ramp $Tstartdown $Tchangedown   # Will modify with other values\n";
print $simdownout $simdownline;

while( <$simdownin> )   # print the rest of the lines
    {
    print $simdownout $_;
    }

#Now we need to delete the old simulation file -- simulation_input.dat
unlink("$simulation");

#Now, renaming the new, edited, file to simulation_input.dat so that it can run in Zacros.
rename $editedsimulation,"simulation_input.dat";

#Now, renaming the new, edited, file to simulation_input.dat so that it can run in Zacros.
rename $editedstate,"state_input.dat";

#Before we run Zacros let's save the output files from the sweep up so that we can then combine them with the sweep down. Could probably do a loop or something.
rename "specnum_output.txt","specnum_output_UP.txt";
rename "general_output.txt","general_output_UP.txt";
rename "history_output.txt","history_output_UP.txt";
rename "lattice_output.txt","lattice_output_UP.txt";
rename "procstat_output.txt","procstat_output_UP.txt";

#Now we run Zacros with the new state_input file for the down sweep.
system("./zacros.x");

#Rename the sweep down files for clarity.
rename "specnum_output.txt","specnum_output_DOWN.txt";
rename "general_output.txt","general_output_DOWN.txt";
rename "history_output.txt","history_output_DOWN.txt";
rename "lattice_output.txt","lattice_output_DOWN.txt";
rename "procstat_output.txt","procstat_output_DOWN.txt";

#The next, and challening step, is to append to the speciesVsTime file.
my $ZacrosSpeciesdown = "specnum_output_DOWN.txt";

#This gets rid of the headers and first line of specnum_output_DOWN.txt and appends it to speciesVsTime.
system("tail -n +2 $ZacrosSpeciesdown > down.txt");
system("tr -s ' ' < down.txt | cut -d ' ' -f2,4,5,7,8,9,10 >> $speciesCounts");

unlink("down.txt");

#The next ambitious step is to change the time in the speciesVsTime file. Basically, when the sweep down data is appended the time starts over.
#This is not ideal for plotting reasons. The ideal solution would add the last value of the time from the time column to each time column entry
#in the appended part. Let's try this. Should be easy enough to isolate the final time value. And then to loop the addition over the column.

#The last time value has been calculated. Now we need to add this to each time entry in the speciesVsTime file. THIS NEEDS WORK!

#Before doing anything else, let's create a file with the values used in the simulation.
open(my $fh, '>', 'values.txt');
print $fh "Input values that are used in the following simulation:\n

Sweep up:
Starting voltage = $Tstart
Change in voltage = $Tchange

Sweep down:
Starting voltage = $Tstartdown
Change in voltage = $Tchangedown

The initial CO coverage is $initialCO or $percentageup %
The finial OH coverage is $finalOH or $percentage %";

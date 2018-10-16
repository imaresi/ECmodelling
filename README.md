# ECmodelling
Electrochemical modelling with Zacros and Perl

This Perl script was written to automate Zacros 2.0 to perform an upwards and subsequent downwards voltage sweep for our electrochemical models. Note that Zacros 2.0 is not written for electrochemical applications, so we have had to trick the program into working with voltage rather than temperature. By re-defining constants in Zacros we are able to model a temperature ramp to behave as a voltage ramp.

Requirements:
- The necessary files to run this Perl script are included in this Github folder. These most be located in the same directory when executing the Perl file.
- Zacros 2.0 must be installed on your computer in order for the 'zacros.x' file to work.

The final data is recorded in 'speciesVsTime.txt'. A sample 'speciesVsTime.txt' file is included in the master folder for reference. This file is not a requirement to run the program, it should just serve as a reference, if needed. The sweep down values are appended to the end of the file. This file can the be used for plotting the population values of CO, OH or CO2.





Authors: Ilaria Maresi and Dr. Joel Ager III.

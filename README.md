# ECmodelling
Electrochemical modelling with Zacros and Perl

This Perl script was written to automate Zacros 2.0 to perform an upwards and subsequent downwards voltage sweep for our electrochemical models. Note that Zacros 2.0 is not written for electrochemical applications, so we have had to trick the program into working with voltage rather than temperature. By re-defining constants in Zacros we are able to model a temperature ramp to behave as a voltage ramp.


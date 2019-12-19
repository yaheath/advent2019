#!/bin/sh
# Here, our input is the "intcode" program, which is a list of
# comma separated numbers. So the special variable FS is set to
# a comma so awk will split up the input line(s) for us. The
# input is provided all in one line, but I coded it to support
# multiple input lines. Once the input program is read in, it
# is executed all in the END block.
#
# Here we first make use of awk "arrays". The scare quotes are
# because awk's arrays are not really arrays, they work like
# a python dict: the "index" is actually a key and doesn't have
# to be an integer. This is why we have to use a counter variable
# to populate `mem`, as there's no equivalent to `push` or
# `append` that other languages have for their real array types.
#
# This also illustrates a way to get values into the awk program
# from awk's command line arguments.
NOUN=$1
VERB=$2
if [ -z "$NOUN" ]; then NOUN=12; fi
if [ -z "$VERB" ]; then VERB=2; fi
awk '
    BEGIN {
        FS=",";
        counter=0;
    }
    {
        for (i = 1; i <= NF; i++) {
            if ($i != "") {
                mem[counter] = $i;
                counter++;
            }
        }
    }
    END {
        pc = 0;
        mem[1] = NOUN;
        mem[2] = VERB;
        while (mem[pc] == 1 || mem[pc] == 2) {
            v1 = mem[mem[pc+1]];
            v2 = mem[mem[pc+2]];
            if (mem[pc] == 1) {
                mem[mem[pc+3]] = v1 + v2;
            } else if (mem[pc] == 2) {
                mem[mem[pc+3]] = v1 * v2;
            }
            pc += 4;
        }
        print mem[0];
    }
' NOUN=$NOUN VERB=$VERB < day02.input

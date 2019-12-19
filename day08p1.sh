#!/bin/sh

# Here I use an awk program to do a bit of pre-processing
# to the input data; the output of which is sent to a second
# awk program; which makes the second awk program a bit simpler.
#
# The preprocessing step takes the input and inserts newlines
# after every `lyrsize` characters. That way, the second program's
# main block will execute for each "layer" of the input.
#
# The FS = "" makes awk split the input line into individual
# characters, so then we can just iterate from $1 to $NF and
# count the zeros, ones, and twos.

let width=25
let height=6
# awkward shell math...
let "lyrsize = width * height"

# Here we use double-quotes for the first awk's program so that
# the shell will interpolate the layersize value into the regex.
# This means we have to be careful about escaping other significant
# characters within a double-quote string.
awk "{ gsub(/.{$lyrsize}/, \"&\\n\"); printf \"%s\", \$0;}" <day08.input | awk '
BEGIN {
    FS = "";
    fewestzeros = -1;
}
{
    nzeros = 0;
    nones = 0;
    ntwos = 0;
    for (i = 1; i <= NF; i++) {
        if ($i == "0") nzeros++;
        if ($i == "1") nones++;
        if ($i == "2") ntwos++;
    }
    if (fewestzeros == -1 || nzeros < fewestzeros) {
        fewestzeros = nzeros;
        product = nones * ntwos;
    }
}
END {
    print product;
}
'

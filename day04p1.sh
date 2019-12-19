#!/bin/sh

# Similarly to adding 0 to a variable to coerce it into
# a number, you can concatenate an empty string to it to
# coerce it into a string, which I do here so I can split()
# the value in `v` into individual characters (digits).
#
# You can also see awk's proclivity toward 1-indexing stuff
# in the `digits` array that split() creates, which is why
# we iterate starting with 1.

awk '
BEGIN { FS="-"; }
{
    FROM = $1;
    TO = $2;
}
END {
    count=0;
    for (v = FROM+0; v <= TO+0; v++) {
        split(v "", digits, "");
        last=-1;
        gotdup=0;
        for(i = 1; i < 7; i++) {
            n=digits[i] + 0;
            if (n < last) break;
            if (n == last) gotdup = 1;
            last = n;
        }
        if (gotdup && i == 7) count++;
    }
    print count;
}' < day04.input

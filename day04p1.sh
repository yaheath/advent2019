#!/bin/sh

awk '
BEGIN { FS="-"; }
{
    FROM = $1;
    TO = $2;
}
END {
    count=0;
    for (v = FROM+0; v <= TO+0; v++) {
        split(v+"", digits, "");
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

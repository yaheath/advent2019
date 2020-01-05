#!/bin/sh

# a Game of Life, sorta

INPUT=${INPUT:-day24.input}

awk '
BEGIN {
    FS = "";
    hgt = 0;
}
{
    for (x = 1; x <= NF; x++) {
        bugs[x-1, hgt] = ($x == "#");
    }
    wid = wid > NF ? wid : NF;
    hgt++;
}
END {
    # printboard();
    vals[getval()] = 1;
    while (1) {
        step();
        # printboard();
        v = getval();
        if (vals[v]) {
            print v;
            break;
        }
        vals[v] = 1;
    }
}
function getval() {
    val = 0;
    for (y = hgt - 1; y >= 0; y--) {
        for (x = wid - 1; x >= 0; x--) {
            val *= 2;
            if (bugs[x, y]) val += 1;
        }
    }
    return val;
}
function step() {
    for (y = 0; y < hgt; y++) {
        for (x = 0; x < wid; x++) {
            newbugs[x, y] = bugs[x, y];
            neighs = 0;
            if (bugs[x-1, y]) neighs++;
            if (bugs[x+1, y]) neighs++;
            if (bugs[x, y-1]) neighs++;
            if (bugs[x, y+1]) neighs++;
            if (bugs[x, y]) {
                if (neighs != 1) {
                    newbugs[x, y] = 0;
                }
            } else {
                if (neighs >= 1 && neighs <= 2) {
                    newbugs[x, y] = 1;
                }
            }
        }
    }
    for (b in newbugs)
        bugs[b] = newbugs[b];
}
function printboard() {
    for (y = 0; y < hgt; y++) {
        for (x = 0; x < wid; x++) {
            printf "%s", bugs[x, y] ? "#" : ".";
        }
        print "";
    }
    print "";
}
' <$INPUT

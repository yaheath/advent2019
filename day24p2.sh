#!/bin/sh

# Neat twist on a game of life!
# Figuring out the neighbor count is a bit tedious, but otherwise
# it's mostly just adding another dimension.

INPUT=${INPUT:-day24.input}

awk '
BEGIN {
    FS = "";
    hgt = 0;
    minz = -1;
    maxz = 1;
}
{
    for (x = 1; x <= NF; x++) {
        bugs[x-1, hgt, 0] = ($x == "#");
    }
    wid = wid > NF ? wid : NF;
    hgt++;
}
END {
    for (c = 0; c < 200; c++) {
        step();
    }
    total = 0;
    for (b in bugs) {
        if (bugs[b]) total++;
    }
    print total;
}
function step() {
    newminz = minz;
    newmaxz = maxz;
    for (z = minz; z <= maxz; z++) {
        for (y = 0; y < hgt; y++) {
            for (x = 0; x < wid; x++) {
                if (x == 2 && y == 2) continue;
                newbugs[x, y, z] = bugs[x, y, z];
                neighs = getneighcount(x, y, z);
                if (bugs[x, y, z]) {
                    if (neighs != 1) {
                        newbugs[x, y, z] = 0;
                    }
                } else {
                    if (neighs >= 1 && neighs <= 2) {
                        newbugs[x, y, z] = 1;
                        if (z == minz) newminz = minz - 1;
                        if (z == maxz) newmaxz = maxz + 1;
                    }
                }
            }
        }
    }
    minz = newminz;
    maxz = newmaxz;
    for (b in newbugs)
        bugs[b] = newbugs[b];
}
function getneighcount(x, y, z) {
    n = 0;

    # left neighbor(s)
    if (x == 0) {
        if (bugs[1, 2, z-1]) n++;
    } else if (x == 3 && y == 2) {
        for (j = 0; j < 5; j++) {
            if (bugs[4, j, z+1]) n++;
        }
    } else {
        if (bugs[x-1, y, z]) n++;
    }

    # right neighbor(s)
    if (x == 4) {
        if (bugs[3, 2, z-1]) n++;
    } else if (x == 1 && y == 2) {
        for (j = 0; j < 5; j++) {
            if (bugs[0, j, z+1]) n++;
        }
    } else {
        if (bugs[x+1, y, z]) n++;
    }

    # top neighbor(s)
    if (y == 0) {
        if (bugs[2, 1, z-1]) n++;
    } else if (y == 3 && x == 2) {
        for (j = 0; j < 5; j++) {
            if (bugs[j, 4, z+1]) n++;
        }
    } else {
        if (bugs[x, y-1, z]) n++;
    }

    # bottom neighbor(s)
    if (y == 4) {
        if (bugs[2, 3, z-1]) n++;
    } else if (y == 1 && x == 2) {
        for (j = 0; j < 5; j++) {
            if (bugs[j, 0, z+1]) n++;
        }
    } else {
        if (bugs[x, y+1, z]) n++;
    }

    return n;
}
' <$INPUT

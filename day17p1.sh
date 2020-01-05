#!/bin/sh

awk -v PROG=day17.input -f lib/intcode.awk | awk '
BEGIN {
    hgt = 0;
    wid = 0;
    x = 0;
}
{
    if ($1 == "10") {
        if (x > 0) hgt++;
        x = 0;
    }
    else {
        char = sprintf("%c", $1+0);
        grid[x, hgt] = char;
        x++;
        wid = x > wid ? x : wid;
    }
}
END {
    sum = 0;
    for (y = 1; y < hgt-1; y++) {
        for (x = 1; x < wid-1; x++) {
            if (grid[x, y] == "#" &&
                grid[x+1, y] == "#" &&
                grid[x-1, y] == "#" &&
                grid[x, y+1] == "#" &&
                grid[x, y-1] == "#")
            {
                sum += (x * y);
            }
        }
    }
    print sum;
}
'

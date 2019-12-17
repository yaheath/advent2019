#!/bin/sh

PROG=day11.input

robotprog='
BEGIN {
    dir = 0;
    posx = 0;
    posy = 0;

    print "0" > BRAININ;
    while (1) {
        if ((getline paint < BRAINOUT) <= 0) break;
        if ((getline turn < BRAINOUT) <= 0) break;
        paint += 0;
        turn += 0;
        grid[posx "," posy] = paint;
        dir += (turn == 1 ? 90 : -90);
        if (dir < 0) dir += 360;
        else if (dir >= 360) dir -= 360;
        if (dir == 0) posy--;
        else if (dir == 90) posx++;
        else if (dir == 180) posy++;
        else posx--;
        print !!grid[posx "," posy] > BRAININ;
    }
    npainted = 0;
    for (p in grid)
        if (grid[p] != "")
            npainted++;
    print npainted;
}
'
mkfifo day11.brainin day11.brainout
cat <day11.brainin | awk -v PROG=$PROG -f intcode.awk >day11.brainout &
awk -v BRAININ="day11.brainin" -v BRAINOUT="day11.brainout" "${robotprog}" </dev/null
wait
rm day11.brainin day11.brainout

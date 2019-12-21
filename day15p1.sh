#!/bin/sh

# For this puzzle, I do use recursion. In this case, the recursive
# function explore() doesn't need much local state, so it's feasible.
#
# When building the map, I store in each cell 0 for a wall, 1 for the
# starting point, and incrementing for each step beyond the starting
# point. Since the recursion is depth-first, it might not reach the
# target via the shortest path first. So I allow the explore to "re-
# explore" an area that was previously explored, if that area was
# reached by a longer path when it was previously explored. This is
# less efficient but it gets the job done.

PROG=day15.input
mkfifo day15.droid.in day15.droid.out
awk -v PROG=$PROG -f intcode.awk <day15.droid.in >day15.droid.out &
awk -v IN=day15.droid.in -v OUT=day15.droid.out '
END {
    queueHead = 0;
    queueTail = 0;

    explore(0, 0, 1);
    printmap();

    # The numbers stored in each cell represent the number of
    # steps to that cell from the center, including the center
    # cell. Since the puzzle calls for the number of movement
    # commands needed to reach the target, that should not
    # include the center, hence the minus one here.
    print map[oxyX "," oxyY] - 1;
}

function printmap() {
    for (y = minY; y <= maxY; y++) {
        for (x = minX; x <= maxX; x++) {
            cell = map[x "," y];
            if (x == 0 && y == 0) printf "S";
            else if (x == oxyX && y == oxyY) printf "O";
            else printf "%s", (!cell ? "#" : " ");
        }
        print ""
    }
}

function go(x, y, steps, move, back) {
    if (map[x "," y] == "" || map[x "," y] > steps) {
        i = droid(move);
        if (i == 0) {
            map[x "," y] = 0;
            updateminmax(x, y);
        } else {
            if (i == 2) {
                oxyX = x;
                oxyY = y;
            }
            explore(x, y, steps);
            droid(back);
        }
    }
}

function explore(x, y, steps) {
    map[x "," y] = steps++;
    updateminmax(x, y);

    # north
    go(x, y+1, steps, 1, 2);

    # south
    go(x, y-1, steps, 2, 1);

    # west
    go(x-1, y, steps, 3, 4);

    # east
    go(x+1, y, steps, 4, 3);
}

function droid(move) {
    print move > IN;
    fflush IN;
    getline response < OUT;
    return response + 0;
}

function updateminmax(x, y) {
    if (x < minX) minX = x;
    if (x > maxX) maxX = x;
    if (y < minY) minY = y;
    if (y > maxY) maxY = y;
}
' </dev/null

rm day15.droid.in day15.droid.out

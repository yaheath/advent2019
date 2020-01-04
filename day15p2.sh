#!/bin/sh

# Similar to part one, but first I map out the maze then
# do a flood fill from the oxygen source. The explore recursion
# now does not repeat already-explored areas making it a bit
# more efficient. THe flood fill is breadth-first and not
# recursive, just to be different.

PROG=day15.input
mkfifo day15.droid.in day15.droid.out
awk -v PROG=$PROG -f lib/intcode.awk <day15.droid.in >day15.droid.out &

main='
END {
    resetqueue()
    explore(0, 0);
    # printmap();
    floodfill();

    print maxsteps - 1;
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

function go(x, y, move, back) {
    if (map[x "," y] == "") {
        i = droid(move);
        if (i == 0) {
            map[x "," y] = 0;
            updateminmax(x, y);
        } else {
            if (i == 2) {
                oxyX = x;
                oxyY = y;
            }
            explore(x, y);
            droid(back);
        }
    }
}

function explore(x, y) {
    map[x "," y] = " ";
    updateminmax(x, y);

    # north
    go(x, y+1, 1, 2);

    # south
    go(x, y-1, 2, 1);

    # west
    go(x-1, y, 3, 4);

    # east
    go(x+1, y, 4, 3);
}

function droid(move) {
    print move > IN;
    fflush(IN);
    getline response < OUT;
    return response + 0;
}
function updateminmax(x, y) {
    if (x < minX) minX = x;
    if (x > maxX) maxX = x;
    if (y < minY) minY = y;
    if (y > maxY) maxY = y;
}

function floodfill() {
    enqueue(oxyX "," oxyY);
    map[oxyX "," oxyY] = 1;
    while (queuesize() > 0) {
        coords = dequeue();
        split(coords, c, ",");
        x = c[1]; y = c[2];
        steps = map[x "," y];
        maxsteps = steps > maxsteps ? steps : maxsteps;
        if (map[x+1 "," y] == " " || map[x+1 "," y] > steps + 1) {
            map[x+1 "," y] = steps + 1;
            enqueue(x+1 "," y);
        }
        if (map[x-1 "," y] == " " || map[x-1 "," y] > steps + 1) {
            map[x-1 "," y] = steps + 1;
            enqueue(x-1 "," y);
        }
        if (map[x "," y+1] == " " || map[x "," y+1] > steps + 1) {
            map[x "," y+1] = steps + 1;
            enqueue(x "," y+1);
        }
        if (map[x "," y-1] == " " || map[x "," y-1] > steps + 1) {
            map[x "," y-1] = steps + 1;
            enqueue(x "," y-1);
        }
    }
}
'

queue_lib=$(cat lib/queue.awk)

awk -v IN=day15.droid.in -v OUT=day15.droid.out "${main}${queue_lib}" </dev/null

rm day15.droid.in day15.droid.out

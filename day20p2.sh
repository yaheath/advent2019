#!/bin/bash

# Now the maze is basically 3D; the portals on the inner edge take you
# z+1 and the portals on the outer edge take you z-1 (in addition to
# putting you at the matching portal's x,y)

INPUT=${INPUT:-day20.input}

pq_lib=$(cat lib/priorityqueue.awk);

main='
BEGIN {
    FS="";
    hgt = 0;
    wid = 0;
}
{
    # read in the grid
    for (x = 1; x <= NF; x++) {
        if ($x == "." || ($x >= "A" && $x <= "Z")) {
            grid[x - 1, hgt] = $x;
        }
    }
    hgt++;
    wid = wid > NF ? wid : NF;
}
END {
    # find the portals
    for (y = 1; y < hgt - 1; y++) {
        for (x = 1; x < wid - 1; x++) {
            if (grid[x, y] >= "A" && grid[x, y] <= "Z") {
                if (x == 1 || y == 1 || x == wid - 2 || y == hgt - 2) {
                    isouter = 1;
                } else {
                    isouter = 0;
                }
                if (grid[x, y+1] == ".") {
                    label = grid[x, y-1] grid[x, y];
                    delete grid[x, y-1];
                    delete grid[x, y];
                    register(label, x, y+1, isouter);
                } else if (grid[x, y-1] == ".") {
                    label = grid[x, y] grid[x, y+1];
                    delete grid[x, y];
                    delete grid[x, y+1];
                    register(label, x, y-1, isouter);
                } else if (grid[x-1, y] == ".") {
                    label = grid[x, y] grid[x+1, y];
                    delete grid[x, y];
                    delete grid[x+1, y];
                    register(label, x-1, y, isouter);
                } else if (grid[x+1, y] == ".") {
                    label = grid[x-1, y] grid[x, y];
                    delete grid[x-1, y];
                    delete grid[x, y];
                    register(label, x+1, y, isouter);
                }
            }
        }
    }
    if (startx == "" || endx == "") {
        print "AA or ZZ not found";
        exit 1;
    }
    pq_reset();
    goal = endx SUBSEP endy SUBSEP 0;
    dist[startx, starty, 0] = 0;
    pq_add(startx SUBSEP starty SUBSEP 0, 0);
    while (!pq_is_empty()) {
        item = pq_take_min();
        if (item == "") continue;
        if (item == goal) {
            print dist[item];
            exit 0;
        }
        split(item, c, SUBSEP);
        x = c[1] + 0;
        y = c[2] + 0;
        level = c[3] + 0;
        if (bycoord[x, y] != "") {
            label = bycoord[x, y];
            if (oports[label] == x SUBSEP y) {
                if (level > 0) {
                    split(iports[label], c, SUBSEP);
                    check(c[1], c[2], level - 1);
                }
            } else if (iports[label] == x SUBSEP y) {
                split(oports[label], c, SUBSEP);
                check(c[1], c[2], level + 1);
            }
        }
        check(x + 1, y, level);
        check(x - 1, y, level);
        check(x, y + 1, level);
        check(x, y - 1, level);
    }
    print "failed to find exit";
}
function check(cx, cy, cz) {
    if (grid[cx, cy] != ".") return;
    d = dist[item] + 1;
    if (dist[cx, cy, cz] == "" || d < dist[cx, cy, cz]) {
        dist[cx, cy, cz] = d;
        pq_add(cx SUBSEP cy SUBSEP cz, d);
    }
}
function register(label, x, y, isouter) {
    if (label == "AA") {
        startx = x;
        starty = y;
    } else if (label == "ZZ") {
        endx = x;
        endy = y;
    } else {
        bycoord[x, y] = label;
        if (isouter) {
            oports[label] = x SUBSEP y;
        } else {
            iports[label] = x SUBSEP y;
        }
    }
}
'

awk "${main}${pq_lib}" < $INPUT

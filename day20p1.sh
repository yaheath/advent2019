#!/bin/bash

# The trickiest part of this one was just parsing the grid to find the
# labelled portals. Once this was working, it just needed a Dijkstra
# to find the shortest path.

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
                if (grid[x, y+1] == ".") {
                    label = grid[x, y-1] grid[x, y];
                    delete grid[x, y-1];
                    delete grid[x, y];
                    register(label, x, y+1);
                } else if (grid[x, y-1] == ".") {
                    label = grid[x, y] grid[x, y+1];
                    delete grid[x, y];
                    delete grid[x, y+1];
                    register(label, x, y-1);
                } else if (grid[x-1, y] == ".") {
                    label = grid[x, y] grid[x+1, y];
                    delete grid[x, y];
                    delete grid[x+1, y];
                    register(label, x-1, y);
                } else if (grid[x+1, y] == ".") {
                    label = grid[x-1, y] grid[x, y];
                    delete grid[x-1, y];
                    delete grid[x, y];
                    register(label, x+1, y);
                }
            }
        }
    }
    if (startx == "" || endx == "") {
        print "AA or ZZ not found";
        exit 1;
    }
    pq_reset();
    goal = endx SUBSEP endy;
    dist[startx, starty] = 0;
    pq_add(startx SUBSEP starty, 0);
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
        if (bycoord[item] != "") {
            label = bycoord[item];
            if (labels1[label] == item) {
                check(labels2[label]);
            } else {
                check(labels1[label]);
            }
        }
        check(x + 1 SUBSEP y);
        check(x - 1 SUBSEP y);
        check(x SUBSEP y + 1);
        check(x SUBSEP y - 1);
    }
    print ("failed to find exit");
}
function check(newitem) {
    if (grid[newitem] != ".") return;
    d = dist[item] + 1;
    if (dist[newitem] == "" || d < dist[newitem]) {
        dist[newitem] = d;
        pq_add(newitem, d);
    }
}
function register(label, x, y) {
    if (label == "AA") {
        startx = x;
        starty = y;
    } else if (label == "ZZ") {
        endx = x;
        endy = y;
    } else {
        bycoord[x, y] = label;
        if (labels1[label] != "") {
            labels2[label] = x SUBSEP y;
        } else {
            labels1[label] = x SUBSEP y;
        }
    }
}
'

awk "${main}${pq_lib}" < $INPUT

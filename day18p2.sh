#!/bin/bash

# This is a tweak of the part 1 solution, where the space
# gets segmented into four separate regions. Instead of
# a "START", I create pseudo-keys 1,2,3,4 for each of the
# four new start points.
#
# Then, in the Dijkstra's algorithm impementation, the
# vertices have values that encode the key locations of
# each of the four "robots" plus the list of visited keys.
# The neighbors of each vertex are each possible next move
# for each robot.

INPUT="${INPUT:-day18.input}"

queue_lib=$(cat lib/queue.awk)
pq_lib=$(cat lib/priorityqueue.awk)

main1='
BEGIN {
    FS = "";
    hgt = 0;
    allkeys = "1234";
}
{
    for (x = 1; x < NF; x++) {
        coord = (x-1) SUBSEP hgt;
        if ($x >= "a" && $x <= "z") {
            keycoords[$x] = coord;
            allkeys = allkeys $x;
            map[coord] = $x;
        }
        else if ($x >= "A" && $x <= "Z") {
            doors[$x] = coord;
            map[coord] = $x;
        }
        else if ($x == "@") {
            keycoords["START"] = coord
            keycoords["1"] = (x-2) SUBSEP (hgt-1);
            map[(x-2) SUBSEP (hgt-1)] = "1";
            keycoords["2"] = (x-2) SUBSEP (hgt+1);
            map[(x-2) SUBSEP (hgt+1)] = "2";
            keycoords["3"] = x SUBSEP (hgt-1);
            map[x SUBSEP (hgt-1)] = "3";
            keycoords["4"] = x SUBSEP (hgt+1);
            map[x SUBSEP (hgt+1)] = "4";
            map[coord] = 0;
            map[(x-1) SUBSEP (hgt-1)] = 0;
            map[(x-1) SUBSEP (hgt+1)] = 0;
            map[(x-2) SUBSEP hgt] = 0;
            map[x SUBSEP hgt] = 0;
        }
        else if ($x == "." && map[coord] == "") {
            map[coord] = ".";
        }
    }
    hgt++;
}
END {
    OFS=",";
    for (i = 1; i < length(allkeys); i++) {
        ii = substr(allkeys, i, 1);
        for (j = i + 1; j <= length(allkeys); j++) {
            jj = substr(allkeys, j, 1);
            dx = dist(keycoords[ii], keycoords[jj]);
            if (dx != "") {
                print dx, ii, jj;
            }
        }
    }
}
function dist(from, to) {
    resetqueue();
    delete traversed;
    traversed[from] = 1;
    enqueue(from ",");
    while (queuesize() > 0) {
        item = dequeue();
        split(item, c, ",");
        coords = c[1];
        dd = c[2];
        steps = traversed[coords];
        split(coords, c, SUBSEP);
        cx = c[1]; cy = c[2];
        if (coords == to) {
            return steps - 1 "," dd;
        }
        if (map[coords] >= "A" && map[coords] <= "Z") {
            dd = dd map[coords];
        }
        if (map[cx+1, cy] && (!traversed[cx+1, cy] || traversed[cx+1, cy] > steps + 1)) {
            traversed[cx+1, cy] = steps + 1;
            enqueue(cx+1 SUBSEP cy "," dd);
        }
        if (map[cx-1, cy] && (!traversed[cx-1, cy] || traversed[cx-1, cy] > steps + 1)) {
            traversed[cx-1, cy] = steps + 1;
            enqueue(cx-1 SUBSEP cy "," dd);
        }
        if (map[cx, cy+1] && (!traversed[cx, cy+1] || traversed[cx, cy+1] > steps + 1)) {
            traversed[cx, cy+1] = steps + 1;
            enqueue(cx SUBSEP cy+1 "," dd);
        }
        if (map[cx, cy-1] && (!traversed[cx, cy-1] || traversed[cx, cy-1] > steps + 1)) {
            traversed[cx, cy-1] = steps + 1;
            enqueue(cx SUBSEP cy-1 "," dd);
        }
    }
    return "";
}
'

main2='
BEGIN { FS=","; }
{
    costs[$3, $4] = $1 + 0;
    prereqs[$3, $4] = tolower($2);
    neighs[$3] = neighs[$3] $4;
    allkeys[$4] = 1;
    if ($3 > "4") {
        allkeys[$3] = 1;
        costs[$4, $3] = $1 + 0;
        prereqs[$4, $3] = tolower($2);
        neighs[$4] = neighs[$4] $3;
    }
    numkeys = 0;
    for (k in allkeys) numkeys++;
}
END {
    pq_reset();
    dist["1,2,3,4,"] = 0;
    pq_add("1,2,3,4,", 0);
    while (!pq_is_empty()) {
        item = pq_take_min();
        if (item == "") continue;
        split(item, items, ",");
        k1 = items[1];
        k2 = items[2];
        k3 = items[3];
        k4 = items[4];
        visited = normalize(items[5] k1 k2 k3 k4);
        if (length(visited) == numkeys) {
            print dist[item];
            exit;
        }
        addneighbors(k1, 1);
        addneighbors(k2, 2);
        addneighbors(k3, 3);
        addneighbors(k4, 4);
    }
}
function addneighbors(key, whichkey) {
    nextkeys = findkeys(key, visited);
    for (i = 1; i <= length(nextkeys); i++) {
        nkey = substr(nextkeys, i, 1);
        d = dist[item] + costs[key, nkey];
        newitem = sprintf("%s,%s,%s,%s,%s",
                    whichkey == 1 ? nkey : items[1],
                    whichkey == 2 ? nkey : items[2],
                    whichkey == 3 ? nkey : items[3],
                    whichkey == 4 ? nkey : items[4],
                    visited);
        if (dist[newitem] == "" || d < dist[newitem]) {
            dist[newitem] = d;
            pq_add(newitem, d);
        }
    }
}
function normalize(path) {
    # Reorder the letters in path to alphabetical order;
    # also removes the numeric psuedo-keys.
    out = "";
    for (cc = 97; cc <= 122; cc++) {
        c = sprintf("%c", cc);
        if (index(path, c) > 0)
            out = out c;
    }
    return out;
}
function findkeys(atkey, prefix, i) {
    # Find all of the keys reachable from atkey that arent already
    # in prefix.
    result = ""
    for (i = 1; i <= length(neighs[atkey]); i++) {
        ne = substr(neighs[atkey], i, 1);
        if (index(prefix, ne) > 0) continue;
        if (!checkPrereqs(atkey, ne, prefix)) continue;
        if (ne >= "1" && ne <= "4") continue;
        result = result ne;
    }
    return result;
}
function checkPrereqs(key1, key2, prefix, j) {
    for (j = 1; j <= length(prereqs[key1, key2]); j++) {
        pk = substr(prereqs[key1, key2], j, 1);
        if (index(prefix, pk) == 0) return 0;
    }
    return 1;
}
'

awk "${main1}${queue_lib}" < $INPUT | awk "${main2}${pq_lib}"

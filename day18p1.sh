#/bin/bash

# There were several iterations before I finally came up
# with a solution that worked in a reasonable amount of time.
# My first attempt did a brute-force recursion which turned
# out to be O(n!), i.e., way too slow. Even the example with
# 16 keys was going to take a gigantic amount of time; the
# real input with 26 keys would not finish before the heat-
# death of the universe.
#
# I ended up splitting the processing into two separate awks.
# The first calculates the distance between each pair of keys,
# and also includes which doors need to be opened before the
# path between the two keys can be traversed. There's an
# assumption that there will not be a path with a door and
# another path without said door.
#
# The second awk program takes in the graph generated by the
# first and implements Dijkstra's algorithm; generating a new
# graph where each vertex is a key plus the keys picked up on
# the way to that key, and associated distance traveled. The
# algorithm finishes when a vertex is reached contaning all
# the keys; since it's a breadth-first search the first such
# vertex will have the shortest distance.

INPUT="${INPUT:-day18.input}"

queue_lib=$(cat lib/queue.awk)
pq_lib=$(cat lib/priorityqueue.awk)

main1='
BEGIN {
    FS = "";
    hgt = 0;
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
            keycoords["START"] = coord;
            map[coord] = ".";
        }
        else if ($x == ".") {
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
        dx = dist(keycoords["START"], keycoords[ii]);
        if (dx != "") {
            print dx, "START", ii;
        }
    }
    dx = dist(keycoords["START"], keycoords[jj]);
    if (dx != "") {
        print dx, "START", jj;
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
    if ($3 != "START") {
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
    dist["START,"] = 0;
    pq_add("START,", 0);
    while (!pq_is_empty()) {
        item = pq_take_min();
        if (item == "") continue;
        split(item, items, ",");
        key = items[1];
        visited = items[2];
        if (key != "START") {
            visited = normalize(visited key);
        }
        nextkeys = findkeys(key, visited);
        if (nextkeys == "" || length(visited) == numkeys) {
            print dist[item];
            exit;
        }
        for (i = 1; i <= length(nextkeys); i++) {
            nkey = substr(nextkeys, i, 1);
            d = dist[item] + costs[key, nkey];
            newitem = nkey "," visited;
            if (dist[newitem] == "" || d < dist[newitem]) {
                dist[newitem] = d;
                pq_add(newitem, d);
            }
        }
    }
}
function normalize(path) {
    # reorder the letters in path to alphabetical order
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

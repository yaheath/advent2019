awk '
BEGIN {
    FS = "";
    hgt = 0;
}
{
    for (x = 1; x < NF; x++) {
        coord = (x-1) SUBSEP hgt;
        if ($x >= "a" && $x <= "z") {
            allkeys[$x] = coord;
            map[coord] = $x;
        }
        else if ($x >= "A" && $x <= "Z") {
            doors[$x] = coord;
            map[coord] = 0;
        }
        else if ($x == "@") {
            posX = x-1;
            posY = hgt;
            map[coord] = ".";
        }
        else if ($x == ".") {
            map[coord] = ".";
        }
    }
    hgt++;
}
END {
    n = main(posX, posY, 0, 0);
    print n;
}
function main(x, y, nMoves, level, prefix, keys, i, n, min, key, tokey, tokeymin) {
    delete traversed;
    keys = findkeys(x, y);
    if (level < 10) print level, x "," y, prefix, keys, nMoves;
    if (keys == "") {
        return nMoves;
    }
    min = 0;
    for (i = 1; i <= length(keys); i++) {
        key = substr(keys, i, 1);
        tokey = distto(x, y, allkeys[key]);
        # remove the key from the map
        map[allkeys[key]] = ".";
        # remove the corresponding door from the map
        map[doors[toupper(key)]] = ".";

        split(allkeys[key], kc, SUBSEP);
        n = main(kc[1], kc[2], nMoves + tokey, level + 1, prefix key);
        if (min == 0 || min > n) {
            min = n;
            tokeymin = tokey;
        }
        # put the key and door back for the next iteration
        map[allkeys[key]] = key;
        map[doors[toupper(key)]] = 0;
    }
    return min;
}
function findkeys(x, y) {
    # Find all of the keys reachable from the
    # given position. Be sure to delete traversed
    # before reusing.
    if (!map[x, y] || traversed[x, y]) return "";
    traversed[x, y] = 1;
    if (map[x, y] != ".") return map[x, y];
    return findkeys(x+1, y) findkeys(x-1, y) findkeys(x, y+1) findkeys(x, y-1);
}
function distto(fx, fy, target) {
    resetqueue();
    delete traversed;
    traversed[fx, fy] = 1;
    enqueue(fx SUBSEP fy);
    while (queuesize() > 0) {
        coords = dequeue();
        steps = traversed[coords];
        split(coords, c, SUBSEP);
        cx = c[1]; cy = c[2]
        if (coords == target) {
            return steps - 1;
        }
        if (map[cx+1, cy] && (!traversed[cx+1, cy] || traversed[cx+1, cy] > steps + 1)) {
            traversed[cx+1, cy] = steps + 1;
            enqueue(cx+1 SUBSEP cy);
        }
        if (map[cx-1, cy] && (!traversed[cx-1, cy] || traversed[cx-1, cy] > steps + 1)) {
            traversed[cx-1, cy] = steps + 1;
            enqueue(cx-1 SUBSEP cy);
        }
        if (map[cx, cy+1] && (!traversed[cx, cy+1] || traversed[cx, cy+1] > steps + 1)) {
            traversed[cx, cy+1] = steps + 1;
            enqueue(cx SUBSEP cy+1);
        }
        if (map[cx, cy-1] && (!traversed[cx, cy-1] || traversed[cx, cy-1] > steps + 1)) {
            traversed[cx, cy-1] = steps + 1;
            enqueue(cx SUBSEP cy-1);
        }
    }
    # should not get here
    print "Warning: did not find location", target;
}
function resetqueue() {
    queueHead = 0;
    queueTail = 0;
    delete fifo;
}
function enqueue(item) {
    fifo[queueHead] = item;
    queueHead++;
}
function dequeue() {
    if (queueHead == queueTail) return "";
    queueitem = fifo[queueTail];
    delete fifo[queueTail];
    queueTail++;
    return queueitem;
}
function queuesize() {
    return queueHead - queueTail;
}

# oq_* functions: ordered queue.
function oq_reset() {
    delete oq;
    oq_min = "";
    oq_max = "";
}
# Add an item at the given value. Value must be an integer.
function oq_add(item, value) {
    if (oq[value] != "") {
        oq[value] = oq[value] RS;
        return;
    }
    if (oq_min == "" || value < oq_min) oq_min = value;
    if (oq_max == "" || value > oq_max) oq_max = value;
}
# Remove and return the item with the lowest value. If
# multiple items were added at the same value, they are
# returned in FIFO order.
function oq_take_min() {
    if (oq_min == "") return "";  # empty
    oq_i = index(oq[oq_min], RS);
    if (oq_i > 0) {
        oq_ret = substr(oq[oq_min], 1, oq_i-1);
        oq[oq_min] = substr(oq[oq_min], oq_i+1);
        return oq_ret;
    }
    oq_ret = oq[oq_min];
    delete oq[oq_min];
    do {
        oq_min++;
        if (oq[oq_min]) return oq_ret;
    } while (oq_min < oq_max);
    oq_min = "";
    oq_max = "";
    return oq_ret;
}
'

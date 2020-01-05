#!/bin/sh

# For this puzzle, I added optional ASCII input and output modes to the Intcode
# machine, making it a bit easier to interface to.
#
# The first step is finding the sequence of moves the robot will need to make;
# then the second step is producing a "program" for the robot. That second step
# is basically a dictionary-based compression algorithm, where the dictionary
# may have at most 3 entries.
#
# This is not currently functional. I can't get my "compression" function
# to work so I again cheated and used someone else's solution to find my
# answer so I could move on. I will come back to this and fix it later (and
# now that I know what my movement program should be it'll be easier to fix
# my implementation).

# awk -v PROG=day17.input -v ASCII_OUT=1 -v ASCII_IN=1 -v POKE=0:2 -f lib/intcode.awk <day17out.fifo >day17in.fifo &

echo "not currently functional"
exit 1

path=$(awk -v PROG=day17.input -v ASCII_OUT=1 -f lib/intcode.awk | awk '
BEGIN {
    hgt = 0;
    wid = 0;
    FS = "";
}
{
    for (x = 1; x <= NF; x++) {
        wid = x > wid ? x : wid;
        if ($x == "^") {
            grid[x-1 "," hgt] = 1;
            botX = x - 1;
            botY = hgt;
        } else if ($x == "#") {
            grid[x-1 "," hgt] = 1;
        }
    }
    hgt++;
}
END {
    findintersections();
    walk();
    print steps;
}
function findintersections() {
    for (y = 1; y < hgt-1; y++) {
        for (x = 1; x < wid-1; x++) {
            if (grid[x "," y] &&
                grid[x+1 "," y] &&
                grid[x-1 "," y] &&
                grid[x "," y+1] &&
                grid[x "," y-1])
            {
                inters[x "," y] = 1;
            }
        }
    }
}
function walk() {
    # Move the bot along the scaffold until it reaches an intersection or
    # a dead end.
    steps = "";
    while (1) {
        dx = 0; dy = 0;
        leftX = 0; leftY = 0;
        rightX = 0; rightY = 0;
        if (botDir == "N") {
            dy = -1;
            leftX = -1;
            rightX = 1;
            leftdir = "W";
            rightdir = "E";
        }
        if (botDir == "S") {
            dy = 1;
            leftX = 1;
            rightX = -1;
            leftdir = "E";
            rightdir = "W";
        }
        if (botDir == "W") {
            dx = -1;
            leftY = 1;
            rightY = -1;
            leftdir = "S";
            rightdir = "N";
        }
        if (botDir == "E") {
            dx = 1;
            leftY = -1;
            rightY = 1;
            leftdir = "N";
            rightdir = "S";
        }
        if (!grid[botX + dx "," botY + dy]) {
            if (grid[botX + rightX "," botY + rightY]) {
                steps = steps "R";
                botDir = rightdir;
            } else if (grid[botX + leftX "," botY + leftY]) {
                steps = steps "L";
                botDir = leftdir;
            } else {
                return;
            }
        } else {
            botX += dx;
            botY += dy;
            steps = steps "F";
        }
    }
}
function dumpboard() {
    for (y = 0; y < hgt; y++) {
        for (x = 0; x < wid; x++) {
            printf "%s", grid[x "," y] ? "#" : " ";
        }
        print "";
    }
}
')

compressprog='
{
    if (compress($0)) {
        print main;
        print subA;
        print subB;
        print subC;
        exit 0;
    }
}
function compress(steps) {
    for (ai = 20; ai <= 40; ai++) {
        for (bi = 20; bi <= 40; bi++) {
            for (ci = 20; ci <= 40; ci++) {
                if (searchpats(steps, ai, bi, ci)) {
                    print "a", ai, "b", bi, "c", ci;
                    return 1;
                }
            }
        }
    }
    return 0;
}
function searchpats(string, alen, blen, clen) {
    stringlen = length(string);
    asection = substr(string, 1, alen);
    #aresult = findrepeats(asection, string);
    an = gsub(asection, blanks(alen, " "), string);
    #if (n != aresult + 0) {
    #    print "mismatch a";
    #}
    #split(aresult, aparts, ",");

    bstart = findnonblank(string);
    while (1) {
        bsection = substr(string, bstart, blen);
        if (length(bsection) < blen) return 0;
        if (index(bsection, " ") == 0) break;
        bstart++;
        if (bstart == stringlen) return 0;
    }
    #bresult = findrepeats(bsection, string);
    bn = gsub(bsection, blanks(blen, " "), string);
    #if (n != bresult + 0) {
    #    print "mismatch b";
    #}

    cstart = findnonblank(string, bstart);
    while (1) {
        csection = substr(string, cstart, clen);
        if (length(csection) < clen) return 0;
        if (index(csection, " ") == 0) break;
        cstart++;
        if (cstart == stringlen) return 0;
    }
    #cresult = findrepeats(csection, string);
    cn = gsub(csection, blanks(clen, " "), string);
    #if (n != cresult + 0) {
    #    print "mismatch c";
    #}
    if (findnonblank(string)) return 0;

    if (an + bn + cn > 10) return 0;

    # have a candidate, now see if the parts encode
    # into small enough strings (<=20 characters)
    subA = encode(asection);
    print "subA", subA;
    subB = encode(bsection);
    print "subB", subB;
    subC = encode(csection);
    print "subC", subC;
    if (length(subA) > 20) return 0;
    if (length(subB) > 20) return 0;
    if (length(subC) > 20) return 0;

    return 1;
}
function encode(movestr) {
    n = split(movestr, mv, "");
    rl = 0;
    out = "";
    for (i = 1; i <= n; i++) {
        if (mv[i] == "F") {
            rl++;
        }
        else {
            if (out) out = out ",";
            if (rl) {
                out = out rl ",";
                rl = 0;
            }
            out = out mv[i];
        }
    }
    if (rl) {
        if (out) out = out ",";
        out = out rl;
    }
    return out;
}
function blanks(len, char) {
    ret = "";
    for (i = 0; i < len; i++)
        ret = ret char;
    return ret;
}
function findnonblank(strng, start) {
    strnglen = length(strng);
    if (!start) start = 1;
    for (fi = start; fi <= strnglen; fi++) {
        if (substr(strng, fi, 1) != " ") return fi;
    }
    return 0;
}
function findrepeats(section, string) {
    seclen = length(section);
    strlen = length(string);
    offset = 0;
    count = 0;
    ret = "";
    while (1) {
        start = index(string, section);
        if (start == 0) break;
        count++;
        ret = ret "," (start + offset);
        offset += start + seclen;
        string = substr(string, start + seclen);
    }
    return count ret;
}
'

echo $path | awk "$compressprog"

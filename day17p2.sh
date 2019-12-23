#!/bin/sh

mkfifo day17in.fifo day17out.fifo

awk -v PROG=day17.input -v ASCII_OUT=1 -v ASCII_IN=1 -v POKE=0:2 -f intcode.awk <day17out.fifo >day17in.fifo &
awk -v OUT=day17out.fifo -v IN=day17in.fifo '
BEGIN {
    hgt = 0;
    wid = 0;
    print "" > OUT;
    while((getline line < IN) > 0) {
        nf = split(line, chars, "");
        if (nf == 0) break;
        for (x = 1; x <= nf; x++) {
            wid = x > wid ? x : wid;
            if (chars[x] == "^") {
                grid[x-1 "," hgt] = 1;
                botX = x - 1;
                botY = hgt;
            } else if (chars[x] == "#") {
                grid[x-1 "," hgt] = 1;
            }
        }
        hgt++;
    }

    findintersections();

    # First look for solutions for the path that goes forward at
    # every intersection. This assumes that there will be no
    # T intersections and the start and end points are dead ends.
    botDir = "N";
    walk(0, 0);
    delete traversed;

    # findsolution will exit if it finds a solution
    findsolution(steps);

    # Enumerate all the possible paths (will be slow)
    findpaths();

    for (i = 1; i < nPaths; i++) {
        findsolution(paths[i]);
    }
    print "no solution found";
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
function findpaths() {
    # Find every possible path that traverses all the cells.
    # Makes these assumptions:
    #  * there is not more than one dead end other than one
    #      at the starting point, and
    #  * there are no T intersections.
    # These are the case for the input I was given.
    traversed[botX "," botY] = 1;
    botDir = "N";
    nPaths = 0;
    traverse("", "N", 0);
    #for (i = 0; i < nPaths; i++) {
    #    print paths[i];
    #}
}
function traverse(path, dir, levels) {
    v = walk(0, 1);
    path = path steps;
    dir = botDir;
    if (v) {
        if (dir != "S" && !traversed[botX "," botY-1]) {
            botDir = "N";
            turn = "";
            if (dir == "E") turn = "L";
            if (dir == "W") turn = "R";
            traverse(path turn, "N", levels+1);
        }
        if (dir != "N" && !traversed[botX "," botY+1]) {
            botDir = "S";
            turn = "";
            if (dir == "E") turn = "R";
            if (dir == "W") turn = "L";
            traverse(path turn, "S", levels+1);
        }
        if (dir != "E" && !traversed[botX-1 "," botY]) {
            botDir = "W";
            turn = "";
            if (dir == "N") turn = "R";
            if (dir == "S") turn = "L";
            traverse(path turn, "W", levels+1);
        }
        if (dir != "W" && !traversed[botX+1 "," botY]) {
            botDir = "E";
            turn = "";
            if (dir == "N") turn = "L";
            if (dir == "S") turn = "R";
            traverse(path turn, "E", levels+1);
        }
    }
    else {
        if (!alltraversed()) {
            botDir = dir;
            walk(1, 1);
            return;
        }
        paths[nPaths++] = path;
    }
    botDir = dir;
    walk(1, 1);
}

function alltraversed() {
    for (item in grid) {
        if (grid[item] && !traversed[item]) {
            return 0;
        }
    }
    return 1;
}

function walk(back, stopatinters) {
    # Move the bot along the scaffold until it reaches an intersection or
    # a dead end.
    steps = "";
    while (1) {
        traversed[botX "," botY] = !back;
        dx = 0; dy = 0;
        leftX = 0; leftY = 0;
        rightX = 0; rightY = 0;
        if (botDir == "N") {
            dy = back ? 1 : -1;
            leftX = back ? 1 : -1;
            rightX = back ? -1 : 1;
            leftdir = "W";
            rightdir = "E";
        }
        if (botDir == "S") {
            dy = back ? -1 : 1;
            leftX = back ? -1 : 1;
            rightX = back ? 1 : -1;
            leftdir = "E";
            rightdir = "W";
        }
        if (botDir == "W") {
            dx = back ? 1 : -1;
            leftY = back ? -1 : 1;
            rightY = back ? 1 : -1;
            leftdir = "S";
            rightdir = "N";
        }
        if (botDir == "E") {
            dx = back ? -1 : 1;
            leftY = back ? 1 : -1;
            rightY = back ? -1 : 1;
            leftdir = "N";
            rightdir = "S";
        }
        if (inters[botX + dx "," botY + dy] && stopatinters) {
            botX += dx;
            botY += dy;
            traversed[botX "," botY] = !back;
            if (!back) steps = steps "F";
            return 1;
        }
        if (!grid[botX + dx "," botY + dy]) {
            if (grid[botX + rightX "," botY + rightY]) {
                if (!back) steps = steps "R";
                botDir = rightdir;
            } else if (grid[botX + leftX "," botY + leftY]) {
                if (!back) steps = steps "L";
                botDir = leftdir;
            } else {
                return 0;
            }
        } else {
            botX += dx;
            botY += dy;
            if (!back) steps = steps "F";
        }
        if (!stopatinters && alltraversed()) return 0;
    }
}
function dumpboard() {
    for (y = 0; y < hgt; y++) {
        for (x = 0; x < wid; x++) {
            printf "%s", grid[x "," y] ? (traversed[x "," y] ? "t" : "#") : " ";
        }
        print "";
    }
}
function findsolution(steps) {
    if (compress(steps)) {
        getline line < OUT;
        print main > IN;
        getline line < OUT;
        print subA > IN;
        getline line < OUT;
        print subB > IN;
        getline line < OUT;
        print subC > IN;
        while ((getline line < OUT) >= 0) {
            lastline = line;
        }
        print lastline;
        exit 0;
    }
}
function compress(steps) {
    return 0
}
' </dev/null
rm day17in.fifo day17out.fifo

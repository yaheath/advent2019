# Now we're getting into more difficult tasks that will start to
# illustrate why you probably won't be using awk to write your next
# Big App.
#
# Even though awk has functions (made use of here) and other big-boy
# language features like the usual if/else and looping constructs
# and a nice* associative array type, there are some things that
# make awk ...unpleasant.
#    *if you use them right
#
# For example, you have to be careful about naming your variables,
# especially when using functions, because all variables (other than
# function arguments) are global!
#
# For the solution, we utilize awk's line-by-line invocation of
# the "main" block to read in the asteroid grid, tracking its height
# and width as we go so that when we start processing we know how
# big the grid is (and the program will work with any size grid).
#
# All of the business happens in the END block, where we test each
# asteroid to see which can see the most other asteroids.
#
# The way getvisible works is: first duplicate the grid into a
# temporary grid, so that we can mutate the temporary grid all we
# like but still have the original there to test the next location.
#
# Then it sort of spirals out from the center asteroid (where the
# center is the coordinates passed in to the function), testing
# the square of 8 cells immediately surrounding the center asteroid,
# then the square of cells around that, etc. until we cover the whole
# map. If we find an astroid in one of the tested cells, we find the
# slope of the line connecting the found asteroid with the center
# asteroid, and then search along that slope outward, deleting
# any asteroid we might find from tgrid. For example, if we find
# an asteroid 2 units south and 6 units west of the center asteroid,
# the slope would be -3/1, so we'd repeatedly jump 3 units west and 1
# unit south (until we leave the bounds of the grid) deleting any
# asteroids that might happen to be at those locations.

awk '
BEGIN {
    FS = "";
    hgt=0;
    wid=0;
}
{
    x=0;
    for (i = 1; i <= NF; i++) {
        if ($i == "#") {
            grid[x "," hgt] = 1;
        }
        x++;
    }
    wid = x > wid ? x : wid;
    hgt++;
}
END {
    size = wid > hgt ? wid : hgt;
    maxvis = 0;
    for (gy = 0; gy < hgt; gy++) {
        for (gx = 0; gx < wid; gx++) {
            if (grid[gx "," gy] == 1) {
                cnt = getvisible(gx, gy);
                if (cnt > maxvis) {
                    maxvis = cnt;
                }
            }
        }
    }
    print maxvis;
}
function dupgrid() {
    for (item in grid) {
        tgrid[item] = grid[item];
    }
}
function getvisible(cx, cy) {
    dupgrid();
    numroids = 0;
    for (level = 1; level <= size; level++) {
        for (x = cx - level; x <= cx + level; x++) {
            y = cy - level;
            if (tgrid[x "," y] == 1) {
                numroids++;
                removeroids(cx, cy, x, y);
            }
            y = cy + level;
            if (tgrid[x "," y] == 1) {
                numroids++;
                removeroids(cx, cy, x, y);
            }
        }
        for (y = cy - (level-1); y <= cy + (level-1); y++) {
            x = cx - level;
            if (tgrid[x "," y] == 1) {
                numroids++;
                removeroids(cx, cy, x, y);
            }
            x = cx + level;
            if (tgrid[x "," y] == 1) {
                numroids++;
                removeroids(cx, cy, x, y);
            }
        }
    }
    return numroids;
}
function removeroids(cx, cy, tx, ty) {
    diffx = tx - cx;
    diffy = ty - cy;
    if (diffy == 0) diffx = diffx < 0 ? -1 : 1;
    else if (diffx == 0) diffy = diffy < 0 ? -1 : 1;
    else {
        d = gcd(diffx, diffy);
        if (d < 0) d = -d;
        diffx /= d;
        diffy /= d;
    }
    tx += diffx;
    ty += diffy;
    while (tx >= 0 && tx < wid && ty >= 0 && ty < hgt) {
        delete tgrid[tx "," ty];
        tx += diffx;
        ty += diffy;
    }
}
function gcd(a, b) {
    while (b) {
        t = a;
        a = b;
        b = t % b;
    }
    return a;
}
' < day10.input

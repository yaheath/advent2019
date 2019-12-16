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

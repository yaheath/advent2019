awk '
BEGIN {
    FS = "";
    hgt=0;
    wid=0;
    PI=atan2(0, -1);
}
{
    wid = NF > wid ? NF : wid;
    hgt++;
}
END {
    for (y = -hgt+1; y < hgt; y++) {
        for (x = -wid+1; x < wid; x++) {
            if (x != 0 || y != 0) {
                a = getangle(x, y);
                print a, x, y;
            }
        }
    }
}
function getangle(x, y) {
    a = atan2(y, x) + PI/2;
    if (a < 0) a += 2*PI;
    return a;
}
' <day10.input |sort -n >day10.angles

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
    FS = ",";
    size = wid > hgt ? wid : hgt;
    maxvis = 0;
    for (gy = 0; gy < hgt; gy++) {
        for (gx = 0; gx < wid; gx++) {
            if (grid[gx "," gy] == 1) {
                cnt = getvisible(gx, gy);
                if (cnt > maxvis) {
                    maxvis = cnt;
                    laserx = gx;
                    lasery = gy;
                }
            }
        }
    }
    dupgrid();
    nangles = 0;
    while ((getline line <"day10.angles") > 0) {
        split(line, items, " ");
        x = items[2] + 0;
        y = items[3] + 0;
        if (y == 0) x = x < 0 ? -1 : 1;
        else if (x == 0) y = y < 0 ? -1 : 1;
        else {
            d = gcd(x, y);
            if (d < 0) d = -d;
            x /= d;
            y /= d;
        }
        if (nangles == 0 || angles[nangles-1] != x "," y) {
            angles[nangles] = x "," y;
            nangles++;
        }
    }
    vaporized = 0;
    while (vaporized < 200) {
        gotone=0;
        for (n = 0; n < nangles; n++) {
            split(angles[n], coord, ",");
            xo = coord[1] + 0;
            yo = coord[2] + 0;

            if (shootat(laserx, lasery, xo, yo)) {
                vaporized++;
                gotone=1;
            }
            if (vaporized == 200) {
                x200 = laserx + xo;
                y200 = lasery + yo;
                break;
            }
        }
        if (!gotone) {
            print "no hits after full revolution";
            break;
        }
    }
    print x200 * 100 + y200;
}
function shootat(lx, ly, xdiff, ydiff) {
    tx = lx + xdiff;
    ty = ly + ydiff;
    while (tx >= 0 && tx < wid && ty >= 0 && ty < hgt) {
        if (tgrid[tx "," ty] == 1) {
            delete tgrid[tx "," ty];
            return 1;
        }
        tx += xdiff;
        ty += ydiff;
    }
    return 0;
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

rm day10.angles

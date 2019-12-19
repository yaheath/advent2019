# Solution spoiler: the key here is that the three axes
# are independent of one another; and while the entire
# state will take a gazillion iterations to repeat,
# each of the three axes' states will individually repeat
# after a reasonable number of iterations. So we find
# the number of iterations that each axis repeats at, then
# calculate the Least Common Multiple of the three values
# which will be the number of iterations for the whole
# system to repeat.
awk '
BEGIN { nmoons = 0; }
{
    n = split($0, items, /[xyz=<>, ]+/);
    if (n >= 4) {
        xpos[nmoons] = items[2];
        ypos[nmoons] = items[3];
        zpos[nmoons] = items[4];
        initxpos[nmoons] = items[2];
        initypos[nmoons] = items[3];
        initzpos[nmoons] = items[4];
        xvel[nmoons] = 0;
        yvel[nmoons] = 0;
        zvel[nmoons] = 0;
        nmoons++;
    }
}
END {
    xrepeat = 0; yrepeat = 0; zrepeat=0;
    steps = 0;
    while (xrepeat==0 || yrepeat==0 || zrepeat==0) {
        steps++;
        for (m1 = 0; m1 < nmoons-1; m1++) {
            for (m2 = m1+1; m2 < nmoons; m2++) {
                d = xpos[m1] - xpos[m2];
                if (d < -1) d = -1;
                if (d > 1) d = 1;
                xvel[m1] -= d;
                xvel[m2] += d;
                d = ypos[m1] - ypos[m2];
                if (d < -1) d = -1;
                if (d > 1) d = 1;
                yvel[m1] -= d;
                yvel[m2] += d;
                d = zpos[m1] - zpos[m2];
                if (d < -1) d = -1;
                if (d > 1) d = 1;
                zvel[m1] -= d;
                zvel[m2] += d;
            }
        }
        mxr=0; myr=0; mzr=0;
        for (m = 0; m < nmoons; m++) {
            xpos[m] += xvel[m];
            ypos[m] += yvel[m];
            zpos[m] += zvel[m];
            if (xvel[m] == 0 && xpos[m] == initxpos[m]) mxr++;
            if (yvel[m] == 0 && ypos[m] == initypos[m]) myr++;
            if (zvel[m] == 0 && zpos[m] == initzpos[m]) mzr++;
        }
        if (xrepeat == 0 && mxr == nmoons) xrepeat = steps;
        if (yrepeat == 0 && myr == nmoons) yrepeat = steps;
        if (zrepeat == 0 && mzr == nmoons) zrepeat = steps;
    }
    print lcm(lcm(xrepeat, yrepeat), zrepeat);
}
function lcm(a, b) {
    return (a * b) / gcd(a, b);
}
function gcd(a, b) {
    while (b) {
        t = a;
        a = b;
        b = t % b;
    }
    return a;
}
' < day12.input

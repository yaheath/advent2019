# Not much new here, other than the fancy regex in
# the split() which basically strips out everything
# but the numbers themselves.

NSTEPS=1000
awk -v NSTEPS=$NSTEPS '
BEGIN { nmoons = 0; }
{
    n = split($0, items, /[xyz=<>, ]+/);
    if (n >= 4) {
        xpos[nmoons] = items[2];
        ypos[nmoons] = items[3];
        zpos[nmoons] = items[4];
        xvel[nmoons] = 0;
        yvel[nmoons] = 0;
        zvel[nmoons] = 0;
        nmoons++;
    }
}
END {
    for (i = 0; i < NSTEPS; i++) {
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
        for (m = 0; m < nmoons; m++) {
            xpos[m] += xvel[m];
            ypos[m] += yvel[m];
            zpos[m] += zvel[m];
        }
    }
    energy = 0;
    for (m = 0; m < nmoons; m++) {
        p = xpos[m] < 0 ? -xpos[m] : xpos[m];
        p += ypos[m] < 0 ? -ypos[m] : ypos[m];
        p += zpos[m] < 0 ? -zpos[m] : zpos[m];
        k = xvel[m] < 0 ? -xvel[m] : xvel[m];
        k += yvel[m] < 0 ? -yvel[m] : yvel[m];
        k += zvel[m] < 0 ? -zvel[m] : zvel[m];
        energy += p * k;
    }
    print energy;
}
' < day12.input

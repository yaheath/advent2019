#!/bin/sh

#
# slope1 * x1 = y1
# slope2 * x2 = y2
# x1 = x2 + 100
# y1 = y2 - 100
#
# slope1 * x1 = (slope2 * (x1 - 100)) - 100
#   x1 = (100 * (slope2 + 1)) / (slope2 - slope1)
#
# y1 = slope1 * ((y1 + 100) / slope2 + 100)
#   y1 = -(100 * (slope1 * (slope2 + 1)) / (slope1 - slope2))
#
main='
END {
    # first find the approximate slopes of the edges of the beam
    state = 0;
    for (y=0; y<1000; y++) {
        x = 999 - y;
        check_coords(x, y);
        # at this point, reply should be set
        if (state == 0 && reply) {
            state = 1;
            l1_x = x;
            l1_y = y;
        }
        else if (state == 1 && !reply) {
            l2_x = x + 1;
            l2_y = y - 1;
            break;
        }
    }
    slope1 = l1_y / l1_x;
    slope2 = l2_y / l2_x;
    # using 97 here instead of 100 because we want to find the closest
    # point which satisfies the condition, and it works better to start
    # a little closer and then move outward.
    x1 = int((97 * (slope2 + 1)) / (slope2 - slope1));
    y1 = int(-(97 * (slope1 * (slope2 + 1)) / (slope1 - slope2)));
    if (check_coords(x1, y1)) {
        # inside the beam, move up until we hit the edge
        while (check_coords(x1, --y1))
            ;
        y1++;
    } else {
        while (!check_coords(x1, ++y1))
            ;
    }
    x2 = x1 - 99;
    y2 = y1 + 99;
    if (check_coords(x2, y2)) {
        print "need to adjust the constant in the equations downward"
        exit;
    }
    #showedges();
    # point 2 is outside the beam. Move outward until point2 hits the edge.
    while (1) {
        if (check_coords(x1 + 1, y1)) {
            x1++;
        } else {
            y1++;
        }
        x2 = x1 - 99;
        y2 = y1 + 99;
        if (check_coords(x2, y2)) break;
    }
    #showedges();
    print x2 * 10000 + y1;
}
function showedges() {
    print x1, y1, x2, y2;
    for (y = y1 - 10; y < y1 + 10; y++) {
        for (x = x1 - 10; x < x1 + 10; x++) {
            if (x == x1 && y == y1)
                printf("%s", check_coords(x, y) ? "+" : "%");
            else
                printf("%s", check_coords(x, y) ? "#" : ".");
        }
        print "";
    }
    print "";
    for (y = y2 - 10; y < y2 + 10; y++) {
        for (x = x2 - 10; x < x2 + 10; x++) {
            if (x == x2 && y == y2)
                printf("%s", check_coords(x, y) ? "+" : "%");
            else
                printf("%s", check_coords(x, y) ? "#" : ".");
        }
        print "";
    }
}
function intcode_output(value) {
    reply = value;
}
function check_coords(x, y) {
    intcode_load("day19.input");
    intcode_run();
    intcode_run(x);
    intcode_run(y);
    return reply;
}
'

intcode_lib=$(cat lib/intcode_lib.awk)
awk "${main}${intcode_lib}" </dev/null


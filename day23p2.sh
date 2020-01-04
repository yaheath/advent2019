#!/bin/bash

# Now this is more up my alley. I can make use of named pipes
# to connect up the nodes that run the intcode program.
#
# Note: the BSD-based awk provided by macOS has a rediculously
# low limit on the number of files it can have open at once;
# so the router program will fail. You will need the GNU version
# of awk (you can get that via Homebrew: `brew install gawk`)

intcode_lib=$(cat lib/intcode_lib.awk)

# node program: contains the intcode interpreter and
# interfaces to the router program
node='
BEGIN {
    OFS = ",";
    outcounter = 0;
    intcode_load("day23.input");
    intcode_run();
    intcode_run(MYADDR);
    while (1) {
        # when intcode_run returns, it wants input.
        # Ask the router for a value:
        print "recv", MYADDR;
        fflush();
        r = getline input;
        if (r <= 0) exit;
        intcode_run(input);
    }
}
function intcode_output(value) {
    outvals[outcounter++] = value;
    if (outcounter == 3) {
        print "send", outvals[0], outvals[1], outvals[2];
        fflush();
        outcounter = 0;
    }
}
'

router='
BEGIN {
    FS = ",";
}
/^recv/ {
    addr = $2 + 0;
    if (queue[addr] == "") {
        sendto(addr, -1);
        checkidle();
    } else {
        idx = index(queue[addr], ",");
        if (idx > 0) {
            val = substr(queue[addr], 1, idx - 1);
            queue[addr] = substr(queue[addr], idx + 1);
        } else {
            val = queue[addr];
            queue[addr] = "";
        }
        sendto(addr, val);
    }
}
/^send/ {
    addr = $2 + 0;
    if (addr == 255) {
        natx = $3;
        naty = $4;
    } else {
        if (queue[addr] != "") {
            queue[addr] = queue[addr] ",";
        }
        queue[addr] = queue[addr] $3 "," $4;
    }
}
function sendto(a, m) {
    f = "d23sockets/node" a;
    print m > f;
    fflush(f);
}
function checkidle() {
    isidle = 1;
    for (a in queue) {
        if (queue[a] != "") {
            isidle = 0;
            break;
        }
    }
    if (isidle && natx != "") {
        if (lastnaty == naty) {
            print naty;
            exit;
        }
        queue[0] = natx "," naty;
        lastnaty = naty;
        natx = ""; naty = "";
    }
}
'

mkdir d23sockets
mkfifo d23sockets/return

for N in $(seq 0 49); do
    mkfifo "d23sockets/node${N}"
    cat "d23sockets/node${N}" | awk -v MYADDR=$N "${node}${intcode_lib}" > d23sockets/return &
done

cat d23sockets/return | awk "${router}"

rm -rf d23sockets

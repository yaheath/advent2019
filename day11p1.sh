#!/bin/sh

# For this problem we need to run the provided Intcode program
# which implements the "brain" of the robot, and interface to
# our own program which models the robot itself.
#
# Again, fifos for the win. We create two fifos, redirect
# the intcode awk's stdin and stdout to the fifos, then run
# our awk which prints into and reads from the same fifos.
# By the way, awk lets you write to things other than stdout.
# We needed to keep our awk's stdout free to print the
# solution.

PROG=day11.input

robotprog='
BEGIN {
    dir = 0;
    posx = 0;
    posy = 0;

    print "0" > BRAININ;
    while (1) {
        if ((getline paint < BRAINOUT) <= 0) break;
        if ((getline turn < BRAINOUT) <= 0) break;
        paint += 0;
        turn += 0;
        grid[posx "," posy] = paint;
        dir += (turn == 1 ? 90 : -90);
        if (dir < 0) dir += 360;
        else if (dir >= 360) dir -= 360;
        if (dir == 0) posy--;
        else if (dir == 90) posx++;
        else if (dir == 180) posy++;
        else posx--;
        print !!grid[posx "," posy] > BRAININ;
    }
    npainted = 0;
    for (p in grid)
        if (grid[p] != "")
            npainted++;
    print npainted;
}
'

mkfifo day11.brainin day11.brainout

# The `cat` here seems unnecessary: why not just put <day11.brainin
# directly on the awk? See the comment below. TLDR: it protects the
# "robotprog" awk from getting a SIGPIPE.
cat <day11.brainin | awk -v PROG=$PROG -f intcode.awk >day11.brainout &

# here's where the magic happens...
awk -v BRAININ="day11.brainin" -v BRAINOUT="day11.brainout" "${robotprog}" </dev/null

# wait for the background pipeline to stop
wait

# clean up
rm day11.brainin day11.brainout

# Here's the looong-winded expanation for why I use a `cat` in the
# intcode pipeline above. If the `cat` isn't there, and the intcode
# awk's stdin is redirected from the fifo itself, here's what'll happen:
#
# When the intcode program decides that it is done, it prints its last
# two values and then exits. Our code executes the body of the while
# loop and then outputs another value, unaware that the process that
# was reading from the other end of the fifo has exited.
#
# When you attempt to write to a pipe whose reader has closed its file
# descriptor, your process gets a SIGPIPE, the default behaviour of which
# is to kill your process. In awk's case, it catches that signal, but its
# response is to exit immediately. So the code that counts up the result
# never gets a chance to execute.
#
# Hence, the use of cat which simply copies its input to its output.
# When the intcode awk exits, no big deal; the cat is still there to read
# that last write. Of course, the cat will die of acute SIGPIPE as soon as
# it tries to write that last value, but that's OK because we're about
# to break out of the while loop because the getline will return 0
# which means EOF.

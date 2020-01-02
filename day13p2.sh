# This one was pretty fun. I had to add another feature to Intcode:
# there's now a way to change one or more memory locations after the
# intcode program is loaded (and before it is executed) via the POKE
# variable. Its value is addr1:value1[,addrN:valueN ...]
#
# I first was thinking about how to make it read from the keyboard
# so that you could play the game yourself, but quickly realized
# that it was going to be super tedious to actually play it all
# the way through. Turns out it's super simple to automate playing
# the game, it's easy to make the paddle track the ball's X
# coordinate. The only tricky thing was determining when to actually
# input the value to move the paddle, because the number of integers
# being output per "frame" varies. One way might be to use a timeout
# to detect when the frame is done "rendering" and the intcode
# program is blocked waiting for its next input. But you can't do
# that in awk. Another way could be to modify intcode.awk so that
# it outputs a prompt string whenever it is about to execute an
# input instruction. The easiest way turned out to be to assume
# that the ball position update happens exactly once per frame,
# and send the controller input when we receive a new ball position.
#
# It's not strictly necessary to actually render the game in order
# to "play" it. You could just look for the ball and paddle values
# and ignore everything else. But it's neat to actually watch the
# game being played. Comment out the two `printf`s if your terminal
# is slow and you're impatient.

clear
mkfifo day13.fifo

cat day13.fifo | awk -v PROG=day13.input -v POKE=0:2 -f lib/intcode.awk |
    awk -v FIFO=day13.fifo '
BEGIN {
    print "";
}
{
    if ((NR % 3) == 1) {
        x = $0 + 0;
        maxx = x > maxx ? x : maxx;
    }
    if ((NR % 3) == 2) {
        y = $0 + 0;
        maxy = y > maxy ? y : maxy;
    }
    if ((NR % 3) == 0) {
        if (x == -1) {
            score = $0 + 0;
            printf "\033[%d;1HScore: %d\n", maxy + 3, score;
        }
        else {
            if ($0 == "0") tile = " ";
            if ($0 == "1") tile = "@";
            if ($0 == "2") tile = "#";
            if ($0 == "3") {
                tile = "=";
                paddlex = x;
            }
            if ($0 == "4") {
                tile = "*";
                ballx = x;
            }
            printf "\033[%d;%dH%s", y+1, x+1, tile;
        }
        if ($0 == "4") {
            if (ballx > paddlex) print 1 > FIFO;
            else if (ballx < paddlex) print -1 > FIFO;
            else print 0 > FIFO;
        }
        fflush "";
    }
}
END { print score }
'

rm -f day13.fifo

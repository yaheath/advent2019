clear
mkfifo day13.fifo

cat day13.fifo | awk -v PROG=day13.input -v POKE=0:2 -f intcode.awk |
    awk -v FIFO=day13.fifo '
BEGIN {
    print "";
    print 0 > FIFO;
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
        if (x == -1) score = $0 + 0;
        else {
            if ($0 == "0") tile = " ";
            if ($0 == "1") tile = "@";
            if ($0 == "2") tile = "#";
            if ($0 == "3") {
                tile = "-";
                paddlex = x;
            }
            if ($0 == "4") {
                tile = "*";
                ballx = x;
            }
            printf "\033[%d;%dH%s", y+1, x+1, tile;
        }
        if (score != "") {
            printf "\033[%d;1HScore: %d\n", maxy + 3, score;
            if ($0 == "4") {
                if (ballx > paddlex) print 1 > FIFO;
                else if (ballx < paddlex) print -1 > FIFO;
                else print 0 > FIFO;
            }
            fflush "";
        }
    }
}
END { print score }
'

rm -f day13.fifo

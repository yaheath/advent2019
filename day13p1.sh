# This one's pretty simple. Just need to do a bit of counting
# of the output of the supplied intcode program.
# That output is a series of values (x, y, type) that repeats
# a bunch of times. The values are one per line though, so we
# use the NR special variable which counts up for each input line
# (starting at 1, of course), so (NR % 3) goes 1, 2, 0, 1, 2, 0 ...

awk -v PROG=day13.input -f intcode.awk | awk '
{
    if (!(NR % 3) && $0 == "2") count++;
}
END {print count;}'

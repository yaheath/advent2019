# One new thing here is the use of the dict-like behavior
# of arrays to simulate a 2D array. `awk` provides syntactic
# sugar within the square brackets: variables or constants
# separated by commas, e.g.: `array[x, y]` which is equivalent
# to: `array[x SUBSEP y]`
#
# SUBSEP is by default ascii 28 (a control character). The
# expression `x SUBSEP y` is a string concatenation of three
# variables: x, SUBSEP, and y. So the key is a single string.
#
# Other languages let you concatenate string constants by
# separating them with a space, but awk includes variables and
# number constants.
#
# There's also some places where I explicitly convert a string
# to a number by adding 0 to it. This isn't always necessary as
# awk will do that automatically when used in a mathematical
# expression. However, when the variable is going to be used
# in a comparison (e.g.  a < b ), if either side of the comparison
# is a string (even a string representation of a number) then
# both values are compared as strings.
#
#    if ("2" > 10) print "gotcha";   <-- will print "gotcha"
#
# Also, we have to deal with a lack of a builtin absolute value
# function.
awk '
    BEGIN {
        FS=","
        ncrossings=0
        wire=0
    }
    {
        x = 0;
        y = 0;
        wire++;
        for (i = 1; i <= NF; i++) {
            dir=substr($i, 1, 1);
            count=substr($i, 2) + 0;
            for (j = 0; j < count; j++) {
                if (dir == "U") y++;
                if (dir == "D") y--;
                if (dir == "R") x++;
                if (dir == "L") x--;
                if (wire == 2 && grid[x, y] == 1) {
                    cross[ncrossings++] = x "," y;
                }
                grid[x, y] = wire;
            }
        }
    }
    END {
        closest = 0
        for (i = 0; i < ncrossings; i++) {
            split(cross[i], coord);
            x = coord[1] + 0; y = coord[2] + 0;
            if (x < 0) x = -x;
            if (y < 0) y = -y;
            if (closest == 0 || x + y < closest) {
                closest = x + y;
            }
        }
        print closest;
    }
' < day03.input

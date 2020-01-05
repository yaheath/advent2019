awk '
    BEGIN {
        FS=","
        ncrossings=0
        wire=0
    }
    {
        x = 0;
        y = 0;
        steps = 0;
        wire++;
        for (i = 1; i <= NF; i++) {
            dir=substr($i, 1, 1);
            count=substr($i, 2) + 0;
            for (j = 0; j < count; j++) {
                steps++;
                if (dir == "U") y++;
                if (dir == "D") y--;
                if (dir == "R") x++;
                if (dir == "L") x--;
                if (wire == 2) {
                    if (grid[x, y] > 0) {
                        cross[ncrossings++] = grid[x, y] "," steps
                    }
                } else {
                    grid[x, y] = steps;
                }
            }
        }
    }
    END {
        closest = 0
        for (i = 0; i < ncrossings; i++) {
            split(cross[i], lengths);
            w1 = lengths[1] + 0;
            w2 = lengths[2] + 0;
            if (closest == 0 || w1 + w2 < closest) {
                closest = w1 + w2;
            }
        }
        print closest;
    }
' < day03.input

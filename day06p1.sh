awk '
BEGIN { FS=")" }
{
    map[$2] = $1;
}
END {
    n = 0;
    for (obj in map) {
        while (obj != "COM") {
            n++;
            obj = map[obj];
        }
    }
    print n;
}' < day06.input

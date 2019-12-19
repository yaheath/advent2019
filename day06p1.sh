# Here we're using the awk array's dict/hash properties
# directly, which makes this implementation really simple
# and elegant. Note the "for..in" syntax, which iterates
# over the *keys* in the `map` array (kinda like
# Javascript when you do "for..in" on an object).
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

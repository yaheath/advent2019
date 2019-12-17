awk -v PROG=day13.input -f intcode.awk | awk '
{
    if (!(NR % 3) && $0 == "2") count++;
}
END {print count;}'

# UGH.
# I have to admit I cheated on this one and looked up how
# others solved it. I'm not a mathematician; I'm not a PhD-
# level computer scientist; and I just didn't have the
# patience to figure out the more optimal algorithm.
#
awk '
{
    data = $0;
}
END {
    offset = substr(data, 1, 7) + 0;
    datalen = length(data);
    lenx10k = datalen * 10000;
    ndigits = 0;
    for (i = offset; i < lenx10k; i++) {
        o = i % datalen;
        digits[ndigits++] = substr(data, o+1, 1);
    }
    for (phase = 0; phase < 100; phase++) {
        for (i = ndigits - 2; i >= 0; i--) {
            digits[i] = (digits[i] + digits[i+1]) % 10;
        }
    }
    for (i = 0; i < 8; i++) {
        printf("%d", digits[i]);
    }
    print "";
}
' < day16.input

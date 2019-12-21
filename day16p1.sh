awk '
{
    data = $0;
}
END {
    datalen = length(data);
    for (phase = 0; phase < 100; phase++) {
        newdata = "";
        for (i = 1; i <= datalen; i++) {
            sum = 0;
            k = i;
            while (k <= datalen) {
                for (j = 1; j <= i && k <= datalen; j++) {
                    n = substr(data, k++, 1);
                    sum += n;
                }
                k += i;
                for (j = 1; j <= i && k <= datalen; j++) {
                    n = substr(data, k++, 1);
                    sum -= n;
                }
                k += i;
            }
            d = sum % 10;
            if (d < 0) d = -d;
            newdata = newdata "" d;
        }
        data = newdata;
    }
    print substr(data, 1, 8);
}
' < day16.input

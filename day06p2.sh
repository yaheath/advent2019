awk '
BEGIN { FS=")" }
{
    map[$2] = $1;
}
END {
    obj = map["SAN"];
    c = 0;
    while (obj != "COM") {
        santa[obj] = c;
        c++;
        obj = map[obj];
    }
    obj = map["YOU"];
    c = 0;
    while (obj != "COM") {
        if (santa[obj] != "") break;
        c++;
        obj = map[obj];
    }
    print (c + santa[obj]);
}'

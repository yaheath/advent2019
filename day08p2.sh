#!/bin/sh

let width=25
let height=6
let "lyrsize = width * height"
awk "{ gsub(/.{$lyrsize}/, \"&\\n\"); print;}" | awk -v height=$height -v width=$width '
BEGIN {
    FS = "";
}
{
    for (i = 1; i <= NF; i++) {
        if (grid[i] == "" || grid[i] == "2") {
            grid[i] = $i;
        }
    }
}
END {
    c = 1;
    for (v = 0; v < height; v++) {
        for (h = 0; h < width; h++) {
            printf("%s", grid[c++] == 1 ? "#" : " ");
        }
        print "";
    }
}
'

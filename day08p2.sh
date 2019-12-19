#!/bin/sh

let width=25
let height=6
let "lyrsize = width * height"

# Why not just use `-v lyrsize=$lyrsize` for the first awk instead of mucking
# about with all that ugly shell escaping, you might ask?
# It's because you can't compose a regex within awk using a variable; a regex
# has to be a literal. So we compose it outside of awk via the shell.
awk "{ gsub(/.{$lyrsize}/, \"&\\n\"); printf \"%s\", \$0;}" <day08.input | awk -v height=$height -v width=$width '
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

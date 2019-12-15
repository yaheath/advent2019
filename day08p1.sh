#!/bin/sh

let width=25
let height=6
let "lyrsize = width * height"
awk "{ gsub(/.{$lyrsize}/, \"&\\n\"); print;}" <day08.input | awk '
BEGIN {
    FS = "";
    fewestzeros = -1;
}
{
    if (NF == 0) next;
    nzeros = 0;
    nones = 0;
    ntwos = 0;
    for (i = 1; i <= NF; i++) {
        if ($i == "0") nzeros++;
        if ($i == "1") nones++;
        if ($i == "2") ntwos++;
    }
    if (fewestzeros == -1 || nzeros < fewestzeros) {
        fewestzeros = nzeros;
        product = nones * ntwos;
    }
}
END {
    print product;
}
'

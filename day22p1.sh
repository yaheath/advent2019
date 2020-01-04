#!/bin/bash

# Here we make use of awk's pattern matching, which I think is
# the first time in this series.
# Since we only need the position of one card, there's no need
# to maintain the entire deck. Each operation updates the position
# of a card in the deck in a certain way.
INPUT=${INPUT:-day22.input}

awk 'BEGIN {
    NCARDS = 10007;
    card = 2019;
}
/new stack/ {
    # reversal
    card = NCARDS - 1 - card;
}
/^cut/ {
    # rotation
    cutat = $2 + 0;
    card = card - cutat;
    if (card < 0) card += NCARDS;
    else card = card % NCARDS;
}
/deal with increment/ {
    # multiplication
    incr = $4 + 0;
    card = (card * incr) % NCARDS;
}
END {
    print card;
}' < $INPUT

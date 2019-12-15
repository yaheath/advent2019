#!/bin/sh

NOUN=0

for VERB in $(seq 0 99); do
    for NOUN in $(seq 0 99); do
        val=$(sh day02p1.sh $NOUN $VERB)
        if [ $val == 19690720 ]; then
            let "ans = 100 * $NOUN + $VERB"
            echo $ans
            exit
        fi
    done
done

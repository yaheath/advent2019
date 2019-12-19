#!/bin/sh

# Whoo, a solution using sh script this time; but still also
# using awk via the part 1 solution. The unix 'seq' command
# comes in handy here to iterate through values.

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

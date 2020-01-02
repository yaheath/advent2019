#!/bin/sh

# We have to try every combination of phase settings, which
# is to say every ordering of the digits 0 1 2 3 4.
#
# The permute() function recursivly produces all of the possible
# orderings. The run() function invokes the "amplifier" for each
# digit, grabbing the output and feeding it to the next "amplifier".

PROG=day07.input

amp() {
    echo "$1\n$2" | awk -v PROG=$PROG -f lib/intcode.awk
}

run() {
    acc=0
    # "grep -o ." splits its input into individual characters
    for p in $(echo $1 | grep -o .); do
        acc=$(amp $p $acc)
    done
    echo $acc
}

permute() {
  local prefix=$1
  local chars=$2
  if [ -z "$chars" ]; then
      echo $prefix
      return
  fi
  for char in $(echo $chars | grep -o .); do
      permute "${prefix}${char}" $(echo $chars | sed -e "s/$char//")
  done
}

max=0
maxc=""
for c in $(permute "" "01234"); do
    val=$(run $c)
    # echo "$c = $val"
    if [[ $val -gt $max ]]; then
        max=$val
        maxc=$c
    fi
done

echo $max

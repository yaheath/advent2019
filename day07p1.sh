#!/bin/sh

PROG=day07.input

amp() {
    echo "$1\n$2" | awk -v PROG=$PROG -f intcode.awk
}

run() {
    acc=0
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

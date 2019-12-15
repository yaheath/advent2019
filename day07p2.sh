#!/bin/sh

PROG=day07.input

amp() {
    phases=($(echo $1 | grep -o .))
    awk -v PROG=$PROG -v FIRSTINPUT=${phases[0]} -f intcode.awk |
        awk -v PROG=$PROG -v FIRSTINPUT=${phases[1]} -f intcode.awk |
        awk -v PROG=$PROG -v FIRSTINPUT=${phases[2]} -f intcode.awk |
        awk -v PROG=$PROG -v FIRSTINPUT=${phases[3]} -f intcode.awk |
        awk -v PROG=$PROG -v FIRSTINPUT=${phases[4]} -f intcode.awk
}

run() {
    mkfifo in out
    amp $1 <in >out &
    exec 3>in 4<out
    echo 0 >&3
    while read val <&4; do
        echo $val >&3
        lastval=$val
    done
    echo $lastval
    rm in out
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
for c in $(permute "" "56789"); do
    val=$(run $c)
    # echo "$c = $val"
    if [[ $val -gt $max ]]; then
        max=$val
        maxc=$c
    fi
done

echo $max

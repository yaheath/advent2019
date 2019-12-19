#!/bin/sh

# Fun with pipes and FIFOs!
# For this puzzle, I modified intcode.awk to let you pass in an
# initial input on the command line. When the program executes the
# `input` instructions for the first time, it will use the value of
# FIRSTINPUT (if provided) instead of reading it from stdin.
# Subsequent `input` instructions read from stdin as normal. This
# way, we can simply chain together the "amplifiers" which now will
# repeatedly read inputs and write outputs.
#
# We also need to feed back the output of the last stage into the
# first stage. To accomplish that, the run() function will read the
# values from the end of the pipeline and then write them into the
# start of the pipeline. FIFOs (also called named pipes) are employed
# to make this possible.

PROG=day07.input

amp() {
    # split the input string into an array of characters
    phases=($(echo $1 | grep -o .))
    # PIPES!!
    awk -v PROG=$PROG -v FIRSTINPUT=${phases[0]} -f intcode.awk |
        awk -v PROG=$PROG -v FIRSTINPUT=${phases[1]} -f intcode.awk |
        awk -v PROG=$PROG -v FIRSTINPUT=${phases[2]} -f intcode.awk |
        awk -v PROG=$PROG -v FIRSTINPUT=${phases[3]} -f intcode.awk |
        awk -v PROG=$PROG -v FIRSTINPUT=${phases[4]} -f intcode.awk
}

run() {
    # Make two fifos
    mkfifo in out
    # run the ampifier pipeline, connecting its stdin and stdout to
    # each fifo
    amp $1 <in >out &
    # Create file descriptors in the shell connected to the fifos
    exec 3>in 4<out
    # Now we can echo stuff into the amplifier pipeline using &3
    # and read from the pipeline using &4
    echo 0 >&3
    # The while loop will stop when the pipeline exits and the write
    # end of the "out" fifo closes (because the read returns a falsey
    # value when that happens)
    while read val <&4; do
        echo $val >&3
        lastval=$val
    done
    echo $lastval
    # cleanup
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

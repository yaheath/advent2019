# I played the puzzle manually. Though it shouldn't be too difficult
# to automate it. Maybe I'll do that at some point.
awk -v PROG=day25.input -v ASCII_OUT=1 -v ASCII_IN=1 -f lib/intcode.awk

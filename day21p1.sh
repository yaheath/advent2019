# if any of A B or C are 0 and D is 1, then jump.
#
echo 'NOT A T
NOT B J
OR T J
NOT C T
OR T J
AND D J
WALK' | awk -v PROG=day21.input -v ASCII_OUT=1 -v ASCII_IN=1 -f lib/intcode.awk

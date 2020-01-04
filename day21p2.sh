echo 'OR B J
AND C J
NOT J J
AND D J
AND H J
NOT A T
OR T J
RUN' | awk -v PROG=day21.input -v ASCII_OUT=1 -v ASCII_IN=1 -f lib/intcode.awk

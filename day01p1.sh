awk 'BEGIN { s = 0 } { s += int($1/3) - 2 } END { print s }' < day01.input

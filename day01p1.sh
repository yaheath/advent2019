# This is a kind of problem for which it's actually appropriate to
# use awk (as opposed to later days of the advent where it's increasingly
# absurd). The BEGIN block is not actually necessary, as an unitialized
# variable defaults to an empty string, which is treated as 0 in a
# mathematical context. I think in later days I get lazy and stop
# explicitly initializing things.
awk 'BEGIN { s = 0 } { s += int($1/3) - 2 } END { print s }' < day01.input

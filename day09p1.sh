# Looks trivial; the actual work for this puzzle was modifying
# intcode.awk for a new addressing mode. See the git commit
# that added this file for changes made in inctode.awk

awk -v PROG=day09.input -v FIRSTINPUT=1 -f lib/intcode.awk

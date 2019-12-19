# When the problem was first solved, I hadn't yet split
# out the "Intcode" implementation into its own file.
# You can see the older implementation in the first git
# commit of this repo. That implementation was what
# became intcode.awk; and it is where I switched
# intcode to read its "program" from a file instead of
# awk's stdin; so that I could use stdin for the opcode
# 3 input instruction.
#
# I switched this script to use the shared intcode.awk
# when I fixed the scripts so they can be invoked in a
# consistent way.
#
echo 1 | awk -v PROG=day05.input -f intcode.awk

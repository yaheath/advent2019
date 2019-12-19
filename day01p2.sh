# The calculation here is a bit more involved, but the problem
# is still within awk's wheelhouse.
awk '
   BEGIN { s = 0 }
   {
     ss = int($1/3) - 2;
     while (ss > 0) {
        s += ss;
        ss = int(ss/3) - 2;
     }
   }
   END { print s }' < day01.input

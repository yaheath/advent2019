#!/bin/sh

# The provided intcode progam exits after testing just one coordinate.
# So we have to invoke it for every test. To improve performance, I
# made a "library" version of intcode, so we can reload and run the
# intcode VM repeatedly in the main awk program.

main='
END {
    count = 0;
    for (y=0; y<50; y++) {
        for (x=0; x<50; x++) {
            intcode_load("day19.input");
            intcode_run();
            intcode_run(x);
            intcode_run(y);
            if (reply == 1) count++;
            # printf("%s", reply ? "#" : ".");
        }
        # print "";
    }
    print count;
}
function intcode_output(value) {
    reply = value;
}
'

intcode_lib=$(cat lib/intcode_lib.awk)
awk "${main}${intcode_lib}" </dev/null


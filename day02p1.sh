NOUN=$1
VERB=$2
if [ -z "$NOUN" ]; then NOUN=12; fi
if [ -z "$VERB" ]; then VERB=2; fi
awk '
    BEGIN {
        FS=",";
        counter=0;
    }
    {
        for (i = 1; i <= NF; i++) {
            if ($i != "") {
                mem[counter] = $i;
                counter++;
            }
        }
    }
    END {
        pc = 0;
        mem[1] = NOUN;
        mem[2] = VERB;
        while (mem[pc] == 1 || mem[pc] == 2) {
            v1 = mem[mem[pc+1]];
            v2 = mem[mem[pc+2]];
            if (mem[pc] == 1) {
                mem[mem[pc+3]] = v1 + v2;
            } else if (mem[pc] == 2) {
                mem[mem[pc+3]] = v1 * v2;
            }
            pc += 4;
        }
        print mem[0];
    }
' NOUN=$NOUN VERB=$VERB < day02.input

awk '
    BEGIN {
        FS=",";
        counter=0;
    }
    {
        for (i = 1; i <= NF; i++) {
            if ($i != "") {
                mem[counter] = $i + 0;
                counter++;
            }
        }
    }
    END {
        print "program length " counter
        pc = 0;
        while (1) {
            inst = sprintf("%05d", mem[pc]);
            opcode = substr(inst, 4)+0;
            arg1mode = substr(inst, 3, 1)+0;
            arg2mode = substr(inst, 2, 1)+0;
            arg3mode = substr(inst, 1, 1)+0;

            if (opcode == 99) break;

            arg1 = arg1mode ? mem[pc+1] : mem[mem[pc+1]];
            arg2 = arg2mode ? mem[pc+2] : mem[mem[pc+2]];
            if (opcode == 1) {
                if (V) print pc " ADD " (arg1mode ? arg1 : "[" mem[pc+1] "]") " " (arg2mode ? arg2 : "[" mem[pc+2] "]") " -> [" mem[pc+3] "] :: " arg1 " + " arg2;
                mem[mem[pc+3]] = arg1 + arg2;
                pc += 4;
            }
            else if (opcode == 2) {
                if (V) print pc " MUL " (arg1mode ? arg1 : "[" mem[pc+1] "]") " " (arg2mode ? arg2 : "[" mem[pc+2] "]") " -> [" mem[pc+3] "] :: " arg1 " * " arg2;
                mem[mem[pc+3]] = arg1 * arg2;
                pc += 4;
            }
            else if (opcode == 3) {
                if (V) print pc " IN -> [" mem[pc+1] "]";
                printf("input: ");
                getline val <"/dev/tty";
                mem[mem[pc+1]] = val + 0;
                pc += 2;
            }
            else if (opcode == 4) {
                if (V) print pc " OUT " (arg1mode ? arg1 : "[" mem[pc+1] "]");
                print arg1;
                pc += 2;
            }
            else if (opcode == 5 || opcode == 6) {
                if (V) print pc " JMP" (opcode == 5 ? "T" : "F") (arg1mode ? arg1 : "[" mem[pc+1] "]") " " (arg2mode ? arg2 : "[" mem[pc+2] "]") " :: " arg1 " " arg2;
                if ((opcode == 5 && arg1 != 0) || (opcode == 6 && arg1 == 0)) {
                    pc = arg2;
                }
                else {
                    pc += 3;
                }
            }
            else if (opcode == 7) {
                if (V) print pc " LT " (arg1mode ? arg1 : "[" mem[pc+1] "]") " " (arg2mode ? arg2 : "[" mem[pc+2] "]") " [" mem[pc+3] "] :: " arg1 " " arg2;
                mem[mem[pc+3]] = (arg1 < arg2 ? 1 : 0);
                pc += 4;
            }
            else if (opcode == 8) {
                if (V) print pc " EQ " (arg1mode ? arg1 : "[" mem[pc+1] "]") " " (arg2mode ? arg2 : "[" mem[pc+2] "]") " [" mem[pc+3] "] :: " arg1 " " arg2;
                mem[mem[pc+3]] = (arg1 == arg2 ? 1 : 0);
                pc += 4;
            }
            else {
                print "Illegal instruction " inst;
                exit 1;
            }
        }
    }
'

# Reset the machine and load the program from the given file
function intcode_load(program) {
    delete intc_mem;
    intc_pc = 0;
    while ((getline intc_line <program) > 0) {
        intc_n = split(intc_line, intc_items, ",");
        for (intc_i = 1; intc_i <= intc_n; intc_i++) {
            intc_mem[intc_pc++] = intc_items[intc_i] + 0;
        }
    }
    close program;
    intc_pc = 0;
    intc_relbase=0;
    intc_opcode=0;
}
# Run until the program terminates or needs input.
function intcode_run(input) {
    if (intc_opcode == 3 && input != "") {
        intc_mem[intc_arg1addr] = input + 0;
        intc_pc += 2;
    }
    while (1) {
        intc_inst = sprintf("%05d", intc_mem[intc_pc]);
        intc_opcode = substr(intc_inst, 4)+0;
        intc_arg1mode = substr(intc_inst, 3, 1)+0;
        intc_arg2mode = substr(intc_inst, 2, 1)+0;
        intc_arg3mode = substr(intc_inst, 1, 1)+0;

        if (intc_opcode == 99) return 0;

        intc_arg1addr = (intc_arg1mode == 2 ? intc_relbase : 0) + intc_mem[intc_pc+1];
        intc_arg2addr = (intc_arg2mode == 2 ? intc_relbase : 0) + intc_mem[intc_pc+2];
        intc_arg3addr = (intc_arg3mode == 2 ? intc_relbase : 0) + intc_mem[intc_pc+3];
        intc_arg1 = intc_arg1mode == 1 ? intc_mem[intc_pc+1] : intc_mem[intc_arg1addr];
        intc_arg2 = intc_arg2mode == 1 ? intc_mem[intc_pc+2] : intc_mem[intc_arg2addr];

        if (intc_opcode == 1) {
            intc_mem[intc_arg3addr] = intc_arg1 + intc_arg2;
            intc_pc += 4;
        }
        else if (intc_opcode == 2) {
            intc_mem[intc_arg3addr] = intc_arg1 * intc_arg2;
            intc_pc += 4;
        }
        else if (intc_opcode == 3) {
            # caller needs to invoke intcode_run again with an integer argument
            return 1;
        }
        else if (intc_opcode == 4) {
            intcode_output(intc_arg1);
            intc_pc += 2;
        }
        else if (intc_opcode == 5 || intc_opcode == 6) {
            if ((intc_opcode == 5 && intc_arg1 != 0) || (intc_opcode == 6 && intc_arg1 == 0)) {
                intc_pc = intc_arg2;
            }
            else {
                intc_pc += 3;
            }
        }
        else if (intc_opcode == 7) {
            intc_mem[intc_arg3addr] = (intc_arg1 < intc_arg2 ? 1 : 0);
            intc_pc += 4;
        }
        else if (intc_opcode == 8) {
            intc_mem[intc_arg3addr] = (intc_arg1 == intc_arg2 ? 1 : 0);
            intc_pc += 4;
        }
        else if (intc_opcode == 9) {
            intc_relbase += intc_arg1;
            intc_pc += 2;
        }
        else {
            print "Illegal instruction " intc_inst;
            exit 1;
        }
    }
}

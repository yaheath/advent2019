BEGIN {
    _ord_init();
    counter=0;
    while ((getline line <PROG) > 0) {
        n = split(line, items, ",");
        for (i = 1; i <= n; i++) {
            mem[counter] = items[i] + 0;
            counter++;
        }
    }
    if (POKE != "") {
        n = split(POKE, pokes, ",");
        for (i = 1; i <= n; i++) {
            split(pokes[i], poke, ":");
            mem[poke[1] + 0] = poke[2] + 0;
        }
    }
    if (V) print "program length " counter;
    pc = 0;
    relbase=0;
    while (1) {
        inst = sprintf("%05d", mem[pc]);
        opcode = substr(inst, 4)+0;
        arg1mode = substr(inst, 3, 1)+0;
        arg2mode = substr(inst, 2, 1)+0;
        arg3mode = substr(inst, 1, 1)+0;

        if (opcode == 99) break;

        arg1addr = (arg1mode == 2 ? relbase : 0) + mem[pc+1];
        arg2addr = (arg2mode == 2 ? relbase : 0) + mem[pc+2];
        arg3addr = (arg3mode == 2 ? relbase : 0) + mem[pc+3];
        arg1 = arg1mode == 1 ? mem[pc+1] : mem[arg1addr];
        arg2 = arg2mode == 1 ? mem[pc+2] : mem[arg2addr];

        if (opcode == 1) {
            if (V) print pc " ADD " (arg1mode ? arg1 : "[" mem[pc+1] "]") " " (arg2mode ? arg2 : "[" mem[pc+2] "]") " -> [" mem[pc+3] "] :: " arg1 " + " arg2;
            mem[arg3addr] = arg1 + arg2;
            pc += 4;
        }
        else if (opcode == 2) {
            if (V) print pc " MUL " (arg1mode ? arg1 : "[" mem[pc+1] "]") " " (arg2mode ? arg2 : "[" mem[pc+2] "]") " -> [" mem[pc+3] "] :: " arg1 " * " arg2;
            mem[arg3addr] = arg1 * arg2;
            pc += 4;
        }
        else if (opcode == 3) {
            if (V) print pc " IN -> [" mem[pc+1] "]";
            if (FIRSTINPUT != "") {
                val = FIRSTINPUT;
                FIRSTINPUT = "";
            } else {
                if (ASCII_IN)
                    val = asciiin();
                else
                    getline val;
            }
            mem[arg1addr] = val + 0;
            pc += 2;
        }
        else if (opcode == 4) {
            if (V) print pc " OUT " (arg1mode ? arg1 : "[" mem[pc+1] "]");
            if (ASCII_OUT && arg1 >= 0 && arg1 < 128) {
                printf("%c", arg1);
            } else {
                print arg1;
            }
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
            mem[arg3addr] = (arg1 < arg2 ? 1 : 0);
            pc += 4;
        }
        else if (opcode == 8) {
            if (V) print pc " EQ " (arg1mode ? arg1 : "[" mem[pc+1] "]") " " (arg2mode ? arg2 : "[" mem[pc+2] "]") " [" mem[pc+3] "] :: " arg1 " " arg2;
            mem[arg3addr] = (arg1 == arg2 ? 1 : 0);
            pc += 4;
        }
        else if (opcode == 9) {
            relbase += arg1;
            pc += 2;
        }
        else {
            print "Illegal instruction " inst;
            exit 1;
        }
    }
}
function asciiin() {
    if (inputbuf == "") {
        getline inputbuf;
        inputbuf = inputbuf "\n";
    }
    c = substr(inputbuf, 1, 1);
    inputbuf = substr(inputbuf, 2);
    return ord(c);
}
function _ord_init() {
    for (i = 0; i < 128; i++)
        _ord_[sprintf("%c", i)] = i;
}
function ord(c) {
    return _ord_[c];
}

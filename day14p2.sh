awk '
BEGIN {
    queueHead = 0;
    queueTail = 0;
}
{
    table[$NF] = $0;
}
END {
    trillion=1000000000000;
    x = 10000;
    run(x);

    est = int(trillion / (oreConsumed/x));
    interval = int(est/10);

    while(1) {
        delete extras;
        oreConsumed = 0;
        run(est);
        if (oreConsumed == trillion) break;
        if (oreConsumed < trillion) {
            if (!lowerbound) {
                lowerbound = est;
                if (upperbound) {
                    est = lowerbound + int((upperbound - lowerbound) / 2);
                } else {
                    est += interval;
                }
            } else if (!upperbound) {
                est += interval;
            } else {
                lowerbound = est;
                est = lowerbound + int((upperbound - lowerbound) / 2);
                if (est == lowerbound) break;
            }
        } else {
            if (!upperbound) {
                upperbound = est;
                if (lowerbound) {
                    est = lowerbound + int((upperbound - lowerbound) / 2);
                } else {
                    est -= interval;
                }
            } else if (!lowerbound) {
                est -= interval;
            } else {
                upperbound = est;
                est = lowerbound + int((upperbound - lowerbound) / 2);
                if (est == lowerbound) break;
            }
        }
    }
    print est;
}
function run(numFuels) {
    enqueue(numFuels " FUEL");
    while(queuesize() > 0) {
        targetstr = dequeue();
        needed = targetstr + 0;
        targetChem = substr(targetstr, index(targetstr, " ") + 1);
        if (extras[targetChem] > 0) {
            if (extras[targetChem] >= needed) {
                extras[targetChem] -= needed;
                continue;
            }
            needed -= extras[targetChem];
            extras[targetChem] = 0;
        }
        nItems = split(table[targetChem], items, "(, )|( => )");
        nPerBatch = items[nItems] + 0;
        nBatches = int((needed + nPerBatch - 1) / nPerBatch);
        nProduced = nBatches * nPerBatch;
        extras[targetChem] += nProduced - needed;
        for (i = 1; i < nItems; i++) {
            nRequired = items[i] + 0;
            nRequired *= nBatches;
            chem = substr(items[i], index(items[i], " ") + 1);
            if (chem == "ORE") {
                oreConsumed += nRequired;
            } else {
                enqueue(nRequired " " chem);
            }
        }
    }
}
function enqueue(item) {
    fifo[queueHead] = item;
    queueHead++;
}
function dequeue() {
    if (queueHead == queueTail) return "";
    queueitem = fifo[queueTail];
    delete fifo[queueTail];
    queueTail++;
    return queueitem;
}
function queuesize() {
    return queueHead - queueTail;
}
' < day14.input

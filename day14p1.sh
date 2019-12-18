awk '
BEGIN {
    queueHead = 0;
    queueTail = 0;
}
{
    table[$NF] = $0;
}
END {
    enqueue("1 FUEL");
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
    print oreConsumed;
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

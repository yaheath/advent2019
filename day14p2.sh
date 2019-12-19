# This is a bit kludgy but seems to work OK.
# Because there are some leftovers of some chemicals after
# running all the reations, it's more efficient (in terms
# of ORE consumed per FUEL produced) to produce larger
# quantities of FUEL at once (economy of scale FTW). As
# the quantity increases, the efficiency increases until
# it converges to be close to a certain value. But it
# will still vary from one quantity to the next.
#
# Perhaps there's a way to do the math to determine
# exactly how much can be produced from a given quantity
# of ORE. Since IANAM*, my approach is to run the reaction
# on different quantites until I find the one closest to the
# target.
#    *I am not a mathematician
#
# First, get into the ballpark by running the reaction
# to get a sufficiently large (but otherwise arbitrary)
# quantity, and get an estimate of how many FUEL to make.
# Run that estimate, and adjust it up or down and repeat
# until we converge on the target.
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

        # See if we have some inventory of this chemical already
        # made, and deduct it from the needed quantity.
        if (extras[targetChem] > 0) {
            if (extras[targetChem] >= needed) {
                extras[targetChem] -= needed;
                continue;
            }
            needed -= extras[targetChem];
            extras[targetChem] = 0;
        }

        # The formula for making this chemical is in the table.
        # Split up the string into components of "[n] [chemical]".
        # The last of these is the target chemical, the others
        # are the prerequisites.
        nItems = split(table[targetChem], items, "(, )|( => )");

        # This is how many target chemical are made per reaction.
        # We have to make it in multiples of this.
        nPerBatch = items[nItems] + 0;
        nBatches = int((needed + nPerBatch - 1) / nPerBatch);
        nProduced = nBatches * nPerBatch;

        # There will be some extra if the number needed isnt
        # a multiple of the batch size. Store the extras so
        # they can be used in subsequent reactions.
        extras[targetChem] += nProduced - needed;

        for (i = 1; i < nItems; i++) {
            nRequired = items[i] + 0;
            nRequired *= nBatches;
            chem = substr(items[i], index(items[i], " ") + 1);
            if (chem == "ORE") {
                # we dont have to make ORE, just count how
                # much is consumed
                oreConsumed += nRequired;
            } else {
                # queue this chemical for production
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

# Here's an instance where it would have been nice to be able
# to use recursion. Technically, you can do recursion in awk,
# but it's REALLY tricky. Remember, the only way to make a
# variable be local to a function is to make it an argument of
# that function. So any variable you might need in your recursive
# function (e.g., a loop counter) has to be included as one
# of the arguments.
#
# And since arrays are passed by reference in awk, you can't
# make an array local to a function at all (I think).
#
# Anyway, turns out that a queue-based approach works well
# for this solution. The queue contains the chemicals that
# need to be made along with the quantity needed; and it
# starts out with just the target "FUEL" chemical. Take
# one from the head of the queue, figure out the quantities,
# and push each prerequisite onto the end of the queue,
# unless the prerequisite is "ORE" which doesn't need to
# be made. Repeat until the queue is empty.

awk '
BEGIN {
    queueHead = 0;
    queueTail = 0;
}
{
    # The last field (using the default whitespace-based
    # field splitting) will be the target chemical and is
    # the key; then we just store the whole line as the value
    table[$NF] = $0;
}
END {
    enqueue("1 FUEL");
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

# Priority queue: items (which must not be an empty string)
# are added along with an integer priority. Items are retrieved
# lowest priority first. If the same item is added multiple times
# it will be retrieved only once at whichever priority it was last
# added with.
# Because of the way it does the de-duplication, there's a case
# where pq_is_empty() might return 0 even though the queue is
# logically empty; in which case pq_take_min() will return an
# empty string.

function pq_reset() {
    delete pq_items;
    delete pq_values;
    pq_min = "";
    pq_max = "";
}

# Add an item with the given priority value.
function pq_add(item, value) {
    value += 0; # make sure it is an int
    pq_values[item] = value;
    if (pq_items[value] != "") {
        pq_items[value] = pq_items[value] RS item;
        return;
    }
    pq_items[value] = item;
    if (pq_min == "" || value < pq_min) pq_min = value;
    if (pq_max == "" || value > pq_max) pq_max = value;
}

# Remove and return the item with the lowest value. If
# multiple items were added at the same value, they are
# returned in FIFO order.
function pq_take_min() {
    while (1) {
        if (pq_min == "") return "";  # empty
        pq_retry = 0;
        pq_i = index(pq_items[pq_min], RS);
        if (pq_i > 0) {
            pq_ret = substr(pq_items[pq_min], 1, pq_i-1);
            pq_items[pq_min] = substr(pq_items[pq_min], pq_i+1);
            if (pq_values[pq_ret] != pq_min) continue;
            delete pq_values[pq_ret];
            return pq_ret;
        }
        pq_ret = pq_items[pq_min];
        pq_value = pq_values[pq_ret];
        if (pq_value != pq_min) pq_retry=1;
        delete pq_items[pq_min];
        do {
            pq_min++;
            if (pq_items[pq_min] != "") {
                if (pq_retry) break;
                delete pq_values[pq_ret];
                return pq_ret;
            }
        } while (pq_min <= pq_max);
        if (pq_min > pq_max) {
            pq_min = "";
            pq_max = "";
        }
        if (pq_retry) continue;
        delete pq_values[pq_ret];
        return pq_ret;
    }
}

function pq_is_empty() {
    return pq_min == "";
}

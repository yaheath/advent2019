function resetqueue() {
    queue_head = 0;
    queue_tail = 0;
    delete queue_fifo;
}
function enqueue(item) {
    queue_fifo[queue_head] = item;
    queue_head++;
}
function dequeue() {
    if (queue_head == queue_tail) return "";
    queue_item = queue_fifo[queue_tail];
    delete queue_fifo[queue_tail];
    queue_tail++;
    return queue_item;
}
function queuesize() {
    return queue_head - queue_tail;
}

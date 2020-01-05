# advent2019
My solutions to https://adventofcode.com/ 2019

To make it an extra challenge, I decided to implement the solutions in mostly `awk`, with a smattering of `bash` and other UNIX tools.

Most of the `awk` code is in the `.sh` files; but along the way I broke out some common awk code into a library of sorts (in the `lib` directory).

I developed against the `awk` that ships with macOS; and all of the solutions except day 23 will work with that `awk`. Presumably, other BSDs' awks will be similar to macOS's one. For day 23, you will need to get GNU awk (aka `gawk`); as the stock awk has a too-small limit on the number of open files. I may come back later and come up with a different implementation that is compatible with BSD awk.

All of the solutions can be run by simply running the `.sh` file. But you first need to put your inputs into files called `dayNN.input`.

See the comments in the `.sh` files for commentary and notes.

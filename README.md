"Woody Toy" puzzle solver
=========================

![Pieces](https://raw.githubusercontent.com/Andrepuel/Woodytoy/master/pieces.png)

Solver for wood puzzle. Output shows where each piece must be place on the 4x4x4 space.
There is no meaning on the order of the pieces.

Hacking
=======

Every piece contains a combination of four rotations on Z axis and two rotations on Y axis.

After rotated, each piece contains six possible positions on the "board". Pieces are placed
on the board always on the same position, the other six positions are reached using whole
board position.

The board is "compressed" to a bit representation using 64 bits integer, this speeds up colision
test.

The dense piece is always fixed as the first piece. Then, a deep search is done with backtracking
covering every position and rotation for each of the pieces until no piece is left. Once a combination
of positions and rotations is found, it is printed where each of the pieces should be placed.
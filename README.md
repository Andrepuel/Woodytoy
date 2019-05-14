# "Woody Toy" puzzle solver

## Sticks
![Pieces](https://raw.githubusercontent.com/Andrepuel/Woodytoy/master/pieces.png)

Solver for wood puzzle. Output shows where each piece must be place on the 4x4x4 space.
There is no meaning on the order of the pieces.

### Hacking

Every piece contains a combination of four rotations on Z axis and two rotations on Y axis.

After rotated, each piece contains six possible positions on the "board". Pieces are placed
on the board always on the same position, the other six positions are reached using whole
board position.

The board is "compressed" to a bit representation using 64 bits integer, this speeds up colision
test.

The dense piece is always fixed as the first piece. Then, a deep search is done with backtracking
covering every position and rotation for each of the pieces until no piece is left. Once a combination
of positions and rotations is found, it is printed where each of the pieces should be placed.

## Snake

![Snake](https://raw.githubusercontent.com/Andrepuel/Woodytoy/master/snake.jpg)

Solver for snake puzzle. Output shows vectors pointing the direction for each segment of the snake
making up the cube.

### Hacking

The snake is represented as a series of STRAIGHT or BRANCH kind of segment. A deep search is done,
if a segment is straight, there is only one path to follow, if the segment is branching, then there
are four new directions to be taken. At every step, it is checked if the cube is already too big or
if there is colision in the cube. Once there is no more segment left, the backlog of directions is
returned.
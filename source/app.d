import std.algorithm;
import std.array;
import std.conv;
import std.range;
import std.stdio;

// x (inside the screen)
//
//   ^
// y |
//
// z ----->

struct Woody {
	this(uint[] data) {
		size_t i = 0;
		foreach(y; 0..2) foreach(z; 0..4) foreach(x; 0..2) {
			config[x][y][z] = data[i++] > 0;
		}
	}

	//   z  y  x
	bool[4][2][2] config;

	string toString() const {
		string r;
		foreach(y; 0..2) {
			foreach(x; 0..2) {
				ulong padding = 1-x;
				r ~= ' '.repeat(padding).array;
				foreach(z; 0..4) {
					r ~= config[x][y][z] ? '#' : '_';
					// r ~= config[x][y][z].to!string;
					r ~= "  ";
				}
				r ~= '\n';
			}
		}
		return r;
	}

	void rotateZ() {
		foreach(z; 0..4) {
			auto firstPiece = config[0][0][z];
			config[0][0][z] = config[1][0][z];
			config[1][0][z] = config[1][1][z];
			config[1][1][z] = config[0][1][z];
			config[0][1][z] = firstPiece;
		}
	}

	void rotateY() {
		foreach(z; 0..2) {
			foreach(y; 0..2) {
				config[0][y][z].swap(config[1][y][3-z]);
				config[1][y][z].swap(config[0][y][3-z]);
			}
		}
	}
}

struct Board {
	this(Board b) {
		this = b;
	}

	this(uint[] data) {
		size_t i = 0;
		foreach(y; 0..4) foreach(z; 0..4) foreach(x; 0..4) {
			config[x][y][z] = data[i++] > 0;
		}
	}

	//   z  y  x
	bool[4][4][4] config;
	ulong compressed;

	void compress() {
		compressed = 0;
		foreach(z; 0..4) foreach(y; 0..4) foreach(x; 0..4) {
			compressed <<= 1;
			compressed |= cast(int)config[x][y][z];
		}
	}

	bool collision(ref const Board other) {
		return (compressed & other.compressed) > 0;
	}

	string toString() const {
		string r;
		foreach(y; 0..4) {
			foreach(x; 0..4) {
				ulong padding = 3-x;
				r ~= ' '.repeat(padding).array;
				foreach(z; 0..4) {
					r ~= config[x][y][z] ? '#' : '_';
					r ~= "  ";
				}
				r ~= '\n';
			}
		}
		return r;
	}

	ref Board rotateX() {
		auto original = this.config;
		foreach(z; 0..4) {
			foreach(y; 0..4) {
				foreach(x; 0..4) {
					config[x][y][z] = original[x][3-z][y];
				}
			}
		}
		return this;
	}

	ref Board rotateY() {
		auto original = this.config;
		foreach(z; 0..4) {
			foreach(y; 0..4) {
				foreach(x; 0..4) {
					config[x][y][z] = original[z][y][3-x];
				}
			}
		}
		return this;
	}

	ref Board rotateZ() {
		auto original = this.config;
		foreach(z; 0..4) {
			foreach(y; 0..4) {
				foreach(x; 0..4) {
					config[x][y][z] = original[y][3-x][z];
				}
			}
		}
		return this;
	}

	void join(ref const Board other) {
		compressed |= other.compressed;
	}
}

Woody one = Woody([
	0,0, 0,0, 1,1, 0,0,
	1,1, 1,1, 1,1, 1,1,
]);

Woody two = Woody([
	0,0, 0,0, 0,1, 1,1,
	1,1, 0,1, 0,1, 1,1,
]);

Woody three = Woody([
	0,0, 0,0, 0,0, 0,0,
	1,1, 1,1, 0,1, 1,1,
]);

Woody four = Woody([
	0,0, 0,0, 0,0, 0,0,
	1,1, 0,1, 0,1, 1,1,
]);

Woody five = Woody([
	1,1, 1,1, 1,1, 1,1,
	1,1, 1,1, 1,1, 1,1,
]);

Woody six = Woody([
	0,1, 0,1, 0,0, 0,0,
	1,1, 0,1, 0,1, 1,1,
]);

// Five got no holes, we can fix it in one position
Board toBoard(Woody piece) {
	Board r;

	foreach(z; 0..4) {
		foreach(y; 0..2) {
			foreach(x; 0..2) {
				r.config[x+2][z][y+1] = piece.config[x][y][z];
			}
		}
	}

	return r;
}

Board[] allBoards(Woody piece) {
	// none
	// YY
	// XZ
	// XZZZ
	// ZX
	// ZXXX

	Board[] r;
	foreach(yRot; 0..2) {
		piece.rotateY();
		foreach(zRot; 0..4) {
			piece.rotateZ();
			Board startPos = piece.toBoard();
			
			r ~= startPos;
			r ~= Board(startPos).rotateY().rotateY();
			r ~= Board(startPos).rotateX().rotateZ();
			r ~= Board(startPos).rotateX().rotateZ().rotateZ().rotateZ();
			r ~= Board(startPos).rotateZ().rotateX();
			r ~= Board(startPos).rotateZ().rotateX().rotateX().rotateX();
		}
	}

	foreach(ref board; r) {
		board.compress();
	}
	return r;
}

Board[] solve(Board current, Board[][] sets) {
	assert(sets.length > 0);

	Board[] tries = sets[0];
	sets = sets[1..$];
	foreach(ref try_; tries) {
		if (!current.collision(try_)) {
			if (sets.length == 0) {
				return [try_];
			}

			Board next = current;
			next.join(try_);
			auto remaining = solve(next, sets);

			if (remaining.length > 0) {
				return [try_] ~ remaining;
			}
		}
	}

	return [];
}

void main()
{
	auto start = five.toBoard();
	start.compress();

	Board[][] sets;
	sets ~= one.allBoards();
	sets ~= two.allBoards();
	sets ~= three.allBoards();
	sets ~= four.allBoards();
	sets ~= six.allBoards();
	auto names = [0:5, 1:1, 2:2, 3:3, 4:4, 5:6];

	Board[] solution = [start] ~ solve(start, sets);
	foreach(i, step; solution) {
		writefln("%s:", names[cast(int)i]);
		writeln(step);
	}
}

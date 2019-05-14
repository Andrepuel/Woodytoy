import std.algorithm;
import std.array;
import std.math;
import std.stdio;

struct Vector {
    int x, y, z;
    
    Vector[] branch() const {
        return [
            Vector(z, x, y),
            Vector(y, z, x),
            Vector(-z, -x, -y),
            Vector(-y, -z, -x),
        ];
    }

    Vector opBinary(string op)(Vector lhs)
    if (op == "+")
    {
        return Vector(x + lhs.x, y + lhs.y, z + lhs.z);
    }

    ulong compress() const {
        return ((cast(uint)x)<<16) |
               ((cast(uint)y)<<8) |
               ((cast(uint)z)<<0);
    }

    Vector max(Vector lhs) {
        return Vector(.max(x, lhs.x), .max(y, lhs.y), .max(z, lhs.z));
    }

    Vector min(Vector lhs) {
        return Vector(.min(x, lhs.x), .min(y, lhs.y), .min(z, lhs.z));
    }
}

enum Segment {
    STRAIGHT,
    BRANCH,
}


struct Solver {
    enum snakeInit = "SSBBBSBBSBBBSBSBBBBSBSBSBS";
    Vector position;
    Vector direction;
    Segment[] snake;
    bool[ulong] used;

    this(int) {
        position = Vector(0, 0, 0);
        direction = Vector(0, 0, 1);
        snake = snakeInit.map!((x) => x == 'S' ? Segment.STRAIGHT : Segment.BRANCH).array;
        used[position.compress] = true;
    }

    Vector[] solve(Vector[] backlog) {
        if (snake.length == 0) {
            return backlog;
        }

        // writeln(snake);
        auto next = snake[0];
        snake = snake[1..$];
        if (next == Segment.STRAIGHT) {
            Solver bellow = this;
            return bellow.collideOrContinue(position + direction, backlog);
        } else {
            foreach(branch; direction.branch) {
                Solver bellow = this;
                bellow.direction = branch;
                auto r = bellow.collideOrContinue(position + branch, backlog);
                if (r.length > 0) {
                    return r;
                }
            }
            return [];
        }
    }

    Vector[] collideOrContinue(Vector newPosition, Vector[] backlog) {
        if (newPosition.compress in used) {
            return [];
        }
        
        position = newPosition;
        used[position.compress] = true;
        scope(exit) used.remove(newPosition.compress);
        backlog ~= direction;

        auto sizes = this.sizes(backlog);
        if (sizes.x > 2 || sizes.y > 2 || sizes.z > 2) {
            // writeln(backlog);
            // writeln(sizes);
            return [];
        }

        return solve(backlog);
    }

    Vector sizes(Vector[] backlog) {
        Vector minPos;
        Vector maxPos;
        Vector pos;
        foreach(step; backlog) {
            pos = pos + step;
            maxPos = maxPos.max(pos);
            minPos = minPos.min(pos);
        }
        return Vector(maxPos.x-minPos.x, maxPos.y - minPos.y, maxPos.z - minPos.z);
    }
}

void run() {
    auto solution = Solver(0).solve([]);
    solution.writeln;
}
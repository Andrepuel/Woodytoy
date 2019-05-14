static import sticks;
static import snake;


void main(string[] args) {
    auto apps = [
        "sticks": &sticks.run,
        "snake": &snake.run
    ];
    
    auto app = args.length < 2 ? null : args[1] in apps;
    (*app)();
}
const std = @import("std");
const Game = @import("game.zig").Game;

pub fn main() !void {
    var game = Game{};

    game.init() catch {
        std.debug.print("init err", .{});
        return;
    };

    defer game.clean();

    game.run();
}

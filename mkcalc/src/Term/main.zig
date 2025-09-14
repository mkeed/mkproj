const std = @import("std");
const term = @import("term");
const Commands = @import("Commands.zig");
const Colour = @import("Colour.zig").Colour;
const Box = @import("Box.zig");

pub fn main() !void {
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;
    try stdout.print(Commands.AltScreen.Enable, .{});
    defer {
        stdout.print(Commands.AltScreen.Disable, .{}) catch {};
        stdout.flush() catch {};
    }

    for (v) |val| {
        try val.font.encode(stdout);
        try stdout.print("{s}{s}\n", .{ val.val, Commands.Font.Clear });
    }

    try Box.draw(.{
        .pos = .{ .x = 5, .y = 5 },
        .size = .{ .x = 10, .y = 10 },
    }, .double, stdout);

    try stdout.flush();

    std.Thread.sleep(1 * std.time.ns_per_s);
}

const Print = struct {
    val: []const u8,
    font: Commands.Font,
};

const red = Colour{ .r = 200, .g = 0, .b = 0 };
const green = Colour{ .r = 0, .g = 200, .b = 0 };
const blue = Colour{ .r = 0, .g = 0, .b = 200 };

const v = [_]Print{
    .{ .val = "Hello", .font = .{ .foreground = red, .underline = .{
        .colour = green,
        .style = .curly,
    } } },
};

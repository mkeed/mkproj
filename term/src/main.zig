const std = @import("std");
const term = @import("term");
const Commands = @import("Commands.zig");
const Colour = @import("Colour.zig").Colour;

pub fn main() !void {
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;

    for (v) |val| {
        try val.font.encode(stdout);
        try stdout.print("{s}{s}\n", .{ val.val, Commands.Font.Clear });
    }
    try stdout.flush();
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

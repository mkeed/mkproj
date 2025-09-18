const std = @import("std");

pub fn run_func(args: []const [:0]const u8, alloc: std.mem.Allocator) anyerror!void {
    _ = alloc;
    var stdout = std.fs.File.stdout();
    var buffer = std.mem.zeroes([512]u8);
    var writer = stdout.writer(buffer[0..]);
    for (0..10) |_| {
        //while (true) {
        for (args, 0..) |a, idx| {
            if (idx != 0) {
                try writer.interface.print(" ", .{});
            }
            try writer.interface.print("{s}", .{a});
        }
        if (args.len == 0) {
            try writer.interface.print("yes", .{});
        }
        try writer.interface.print("\n", .{});
    }
    try writer.interface.flush();
}

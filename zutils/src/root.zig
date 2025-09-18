//! By convention, root.zig is the root source file when making a library.
const std = @import("std");
const zutil = @import("zutil.zig");

pub fn run() anyerror!void {
    var gpa = std.heap.DebugAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();
    const args = try std.process.argsAlloc(alloc);
    defer std.process.argsFree(alloc, args);
    const program_name = args[1];
    inline for (zutil.Bins) |b| {
        if (std.mem.eql(u8, program_name, b.name)) {
            try b.function(args[2..], alloc);
        }
    }
}

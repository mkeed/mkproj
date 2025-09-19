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
    var stdout = std.fs.File.stdout();
    var stdout_buffer: [2048]u8 = undefined;
    var stdout_writer = stdout.writer(stdout_buffer[0..]);
    var stderr = std.fs.File.stderr();
    var stderr_buffer: [2048]u8 = undefined;
    var stderr_writer = stderr.writer(stderr_buffer[0..]);
    var stdin = std.fs.File.stdin();
    var stdin_buffer: [2048]u8 = undefined;
    var stdin_reader = stdin.reader(stdin_buffer[0..]);
    var env = zutil.Environment{
        .stdout = &stdout_writer.interface,
        .stdin = &stdin_reader.interface,
        .stderr = &stderr_writer.interface,
        .args = args[2..],
        .alloc = alloc,
    };
    inline for (zutil.Bins) |b| {
        if (std.mem.eql(u8, program_name, b.name)) {
            try b.function(&env);
            return;
        }
    }
}

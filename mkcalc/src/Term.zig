const std = @import("std");
const Commands = @import("Term/Commands.zig");

pub const Term = struct {
    alloc: std.mem.Allocator,
    stdin: std.fs.File,
    stdout: std.fs.File,
    orig_termios: std.posix.termios,
    pub fn init(alloc: std.mem.Allocator) !Term {
        var self = Term{
            .alloc = alloc,
            .stdin = std.fs.File.stdin(),
            .stdout = std.fs.File.stdout(),
            .orig_termios = try std.os.tcgetattr(std.os.STDIN_FILENO),
        };

        errdefer self.deinit();
        _ = try self.stdout.write(Commands.AltScreen.Enable);
        return self;
    }
    pub fn deinit(self: *Term) void {
        std.posix.tcsetattr(std.os.STDIN_FILENO, .FLUSH, self.orig_termios) catch {};
        _ = self.stdout.write(Commands.AltScreen.Disable) catch {};
    }
};

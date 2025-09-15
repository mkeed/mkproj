const std = @import("std");
const Commands = @import("Term/Commands.zig");
const Box = @import("Term/Box.zig");

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
            .orig_termios = try std.posix.tcgetattr(std.posix.STDIN_FILENO),
        };

        errdefer self.deinit();
        _ = try self.stdout.write(Commands.AltScreen.Enable);
        var new_termios = self.orig_termios;
        new_termios.iflag.IGNBRK = false;
        new_termios.iflag.BRKINT = false;
        new_termios.iflag.PARMRK = false;
        new_termios.iflag.ISTRIP = false;
        new_termios.iflag.INLCR = false;
        new_termios.iflag.IGNCR = false;
        new_termios.iflag.ICRNL = false;
        new_termios.iflag.IXON = false;

        new_termios.oflag.OPOST = false;
        new_termios.lflag.ECHO = false;
        new_termios.lflag.ECHONL = false;
        new_termios.lflag.ICANON = false;
        new_termios.lflag.ISIG = false;
        new_termios.lflag.IEXTEN = false;
        new_termios.cflag.CSIZE = .CS8;
        new_termios.cflag.PARENB = false;

        try std.posix.tcsetattr(std.posix.STDIN_FILENO, .FLUSH, new_termios);
        return self;
    }
    pub fn deinit(self: *Term) void {
        std.posix.tcsetattr(std.posix.STDIN_FILENO, .FLUSH, self.orig_termios) catch {};
        _ = self.stdout.write(Commands.AltScreen.Disable) catch {};
    }
    pub fn draw(self: *Term) !void {
        const size = try os_winsize(std.posix.STDIN_FILENO);
        var buf: [4096]u8 = undefined;
        var writer = self.stdout.writer(&buf);
        std.log.info("{}", .{size});
        try Box.draw(
            .{ .pos = .{ .x = 1, .y = 1 }, .size = .{ .x = size.col - 1, .y = size.row - 1 } },
            .double,
            &writer.interface,
        );

        try writer.interface.flush();
    }
};

fn os_winsize(handle: std.posix.fd_t) !std.posix.winsize {
    var wsz: std.posix.winsize = undefined;
    const fd: usize = @bitCast(@as(isize, handle));
    const rc = std.os.linux.syscall3(.ioctl, fd, std.os.linux.T.IOCGWINSZ, @intFromPtr(&wsz));
    switch (std.os.linux.E.init(rc)) {
        .SUCCESS => return wsz,
        else => return error.FailedToRead,
    }
}

const std = @import("std");

const ArgsIter = struct {
    args: []const [:0]const u8,
    index: usize = 0,
    short_pos: ?usize = null,
    pub const Arg = union(enum) {
        short: u8,
        long: [:0]const u8,
        pub fn format(self: Arg, writer: *std.Io.Writer) !void {
            switch (self) {
                .short => |s| try writer.print("Short({c})", .{s}),
                .long => |l| try writer.print("Long({s})", .{l}),
            }
        }
    };

    pub fn next(self: *ArgsIter) ?Arg {
        if (self.short_pos) |sp| {
            if (sp >= self.args[self.index].len) {
                self.short_pos = null;
                self.index += 1;
            } else {
                defer self.short_pos = sp + 1;
                return .{
                    .short = self.args[self.index][sp],
                };
            }
        }
        if (self.index >= self.args.len) return null;
        const cur_arg = self.args[self.index];
        if (cur_arg[0] == '-') {
            if (cur_arg.len >= 2 and cur_arg[1] != '-') {
                //short arg
                if (cur_arg.len > 2) {
                    self.short_pos = 2;
                }
                return .{
                    .short = cur_arg[1],
                };
            }
        }
        defer self.index += 1;
        return .{ .long = self.args[self.index] };
    }
};

test {
    var arg_iter = ArgsIter{ .args = &.{ "prog", "--hello", "-test", "-----" } };
    while (arg_iter.next()) |val| {
        std.log.err("{f}", .{val});
    }
}

pub fn parse(comptime T: type, alloc: std.mem.Allocator) !T {
    const args = try std.process.argsWithAlloc(alloc);
    defer std.process.argsFree(&args);
}

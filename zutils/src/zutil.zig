const std = @import("std");

pub const Environment = struct {
    stdout: *std.Io.Writer,
    stdin: *std.Io.Reader,
    stderr: *std.Io.Writer,
    args: []const [:0]const u8,
    alloc: std.mem.Allocator,
};

pub const Binary = struct {
    name: []const u8,
    function: fn (env: *Environment) anyerror!void,
};

pub const Bins = [_]Binary{
    .{
        .name = "yes",
        .function = @import("yes.zig").run_func,
    },
    @import("sum.zig").sha1,
    @import("sum.zig").sha224,
    @import("sum.zig").sha256,
    @import("sum.zig").sha384,
    @import("sum.zig").sha512,
    @import("sum.zig").md5,
    @import("sum.zig").b2,
};

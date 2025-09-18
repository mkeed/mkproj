const std = @import("std");

pub const Binary = struct {
    name: []const u8,
    function: fn (args: []const [:0]const u8, alloc: std.mem.Allocator) anyerror!void,
};

pub const Bins = [_]Binary{
    .{
        .name = "yes",
        .function = @import("yes.zig").run_func,
    },
    .{
        .name = "sha1sum",
        .function = @import("sum.zig").sha1,
    },
    .{
        .name = "sha224sum",
        .function = @import("sum.zig").sha224,
    },
    .{
        .name = "sha256sum",
        .function = @import("sum.zig").sha256,
    },
    .{
        .name = "sha384sum",
        .function = @import("sum.zig").sha384,
    },
    .{
        .name = "sha512sum",
        .function = @import("sum.zig").sha512,
    },
};

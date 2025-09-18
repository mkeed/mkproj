const std = @import("std");
const zutil = @import("zutil.zig");
//3af26a5d6986e3d419f5d320a64beb4f8f4278f3  zutil.zig

// pub const ShaSumOpt = struct {
//     mode: enum { binary, text } = .text,
//     binary: bool = false,
//     check: bool = false,
//     tag: bool = false,
//     text: bool = false,
//     zero: bool = false,

//     ignore_missing: bool = false,
//     quiet: bool = false,
//     status: bool = false,
//     strict: bool = false,
//     warn: bool = false,
// };

// const Options = zutil.opts{
//     .name = "shasum",
//     .T = ShaSumOpt,
//     .opts = &.{
//         .{ .short = 'b', .long = "--binary", .field = "mode", .value = .binary },
//         .{ .
//     },
// };

pub fn sha1(args: []const [:0]const u8, alloc: std.mem.Allocator) anyerror!void {
    try run(std.crypto.hash.Sha1, args, alloc);
}

pub fn sha224(args: []const [:0]const u8, alloc: std.mem.Allocator) anyerror!void {
    try run(std.crypto.hash.sha2.Sha224, args, alloc);
}

pub fn sha256(args: []const [:0]const u8, alloc: std.mem.Allocator) anyerror!void {
    try run(std.crypto.hash.sha2.Sha256, args, alloc);
}

pub fn sha384(args: []const [:0]const u8, alloc: std.mem.Allocator) anyerror!void {
    try run(std.crypto.hash.sha2.Sha384, args, alloc);
}

pub fn sha512(args: []const [:0]const u8, alloc: std.mem.Allocator) anyerror!void {
    try run(std.crypto.hash.sha2.Sha512, args, alloc);
}

pub fn md5(args: []const [:0]const u8, alloc: std.mem.Allocator) anyerror!void {
    try run(std.crypto.hash.Md5, args, alloc);
}

pub fn b2(args: []const [:0]const u8, alloc: std.mem.Allocator) anyerror!void {
    try run(std.crypto.hash.blake2.Blake2b512, args, alloc);
}

fn run(comptime T: type, args: []const [:0]const u8, alloc: std.mem.Allocator) anyerror!void {
    _ = alloc;

    var stdout = std.fs.File.stdout();
    var buffer = std.mem.zeroes([512]u8);
    var writer = stdout.writer(buffer[0..]);
    var dir = std.fs.cwd();
    for (args) |name| {
        var file = try dir.openFile(name, .{});
        defer file.close();
        var file_buf: [40960]u8 = undefined;

        var hashed = T.init(.{});
        while (true) {
            const len = try file.read(&file_buf);
            hashed.update(file_buf[0..len]);
            if (len != file_buf.len) break;
        }

        var output = std.mem.zeroes([T.digest_length]u8);
        hashed.final(&output);

        try writer.interface.print("{x} {s}\n", .{ output, name });
        try writer.interface.flush();
    }
}

// /usr/bin/cksum TODO
// /usr/bin/shasum TODO
// /usr/bin/sum TODO

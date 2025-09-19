const std = @import("std");
const Wasm = @import("Wasm.zig").Wasm;

const Reader = struct {
    data: []const u8,
    idx: usize = 0,
    pub fn getSlice(self: *Reader, len: usize) ![]const u8 {
        if (self.idx + len >= self.data.len) return error.TooSmall;
        defer self.idx += len;
        return self.data[self.idx..][0..len];
    }
    pub fn expect(self: *Reader, data: []const u8) !void {
        const val = try self.getSlice(data.len);
        if (std.mem.eql(u8, val, data) == false) return error.Invalid;
    }
};

fn parseFile(alloc: std.mem.Allocator, data: []const u8) !Wasm {
    _ = alloc;
    std.log.err("[{x}]", .{data[0..16]});
    return .{};
}

test {
    const files = [_][]const u8{
        @embedFile("samples/add-not-folded.wasm"),
        @embedFile("samples/add.wasm"),
        @embedFile("samples/endianflip.wasm"),
        @embedFile("samples/envprint.wasm"),
        @embedFile("samples/ifexpr.wasm"),
        @embedFile("samples/isprime.wasm"),
        @embedFile("samples/itoa.wasm"),
        @embedFile("samples/locals.wasm"),
        @embedFile("samples/loops.wasm"),
        @embedFile("samples/memory-basics.wasm"),
        @embedFile("samples/mod1.wasm"),
        @embedFile("samples/mod2.wasm"),
        @embedFile("samples/readfile.wasm"),
        @embedFile("samples/recursion.wasm"),
        @embedFile("samples/select.wasm"),
        @embedFile("samples/stack.wasm"),
        @embedFile("samples/table.wasm"),
        @embedFile("samples/vcount.wasm"),
        @embedFile("samples/vecadd.wasm"),
        @embedFile("samples/write.wasm"),
    };
    for (files) |f| {
        _ = try parseFile(std.testing.allocator, f);
    }
}

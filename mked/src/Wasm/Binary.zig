const std = @import("std");
const Wasm = @import("Wasm.zig").Wasm;

const SectionId = enum(u8) {
    custom = 0,
    type = 1,
    import = 2,
    function = 3,
    table = 4,
    memory = 5,
    global = 6,
    @"export" = 7,
    start = 8,
    element = 9,
    code = 10,
    data = 11,
    data_count = 12,
    tag = 13,
};

fn take_magic_and_version(reader: *std.Io.Reader) !void {
    const magic = try reader.takeArray(4);
    const version = try reader.takeArray(4);
    if (std.mem.eql(u8, magic, "\x00asm") == false) return error.BadMagic;
    if (std.mem.eql(u8, version, "\x01\x00\x00\x00") == false) return error.BadVersion;
}

fn parseFile(alloc: std.mem.Allocator, file_data: []const u8) !Wasm {
    var reader = std.Io.Reader.fixed(file_data);
    try take_magic_and_version(&reader);
    _ = alloc;
    while (true) {
        const section = reader.takeEnum(SectionId, .big) catch break;

        const len = try reader.takeLeb128(u32);
        const data = try reader.take(len);
        std.log.err("[{} => {x}]", .{ section, data });
    }

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

const std = @import("std");

const ArenaAllocator = std.heap.ArenaAllocator;

const Node = struct {};

pub const XmlDoc = struct {
    arena: *ArenaAllocator,
    //data: []const u8,
    nodes: std.ArrayList(Node),
    pub fn init(alloc: std.mem.Allocator) !XmlDoc {
        const arena = try alloc.create(ArenaAllocator);
        errdefer arena.deinit();
        arena.* = ArenaAllocator.init(alloc);
        errdefer arena.deinit();

        return .{
            .arena = arena,
            .nodes = std.ArrayList(Node){},
        };
    }

    pub fn deinit(self: XmlDoc) void {
        const alloc = self.arena.child_allocator;
        self.arena.deinit();
        alloc.destroy(self.arena);
    }
};

const magic_number = "<?xml";
const end_of_decl = "?>";

const Reader = struct {
    data: []const u8,
    idx: usize = 0,

    pub fn take(self: *Reader, len: usize) void {
        self.idx += len;
    }
    pub fn skipWhitespace(self: *Reader) void {
        for (self.data[self.idx..], 0..) |ch, len| {
            if (std.ascii.isWhitespace(ch) == false) {
                self.idx += len;
                return;
            }
        }
    }
    pub fn until(self: *Reader, data: u8) ![]const u8 {
        const start = self.idx;
        for (self.data[self.idx..], 0..) |ch, len| {
            if (data == ch) {
                self.idx += len + 1;

                return self.data[start .. self.idx - 1];
            }
        }
        return error.EndOfStream;
    }
};

pub fn parse(data: []const u8, alloc: std.mem.Allocator) !XmlDoc {
    var doc = try XmlDoc.init(alloc);
    errdefer doc.deinit();
    var reader = Reader{ .data = data };

    if (std.mem.eql(u8, magic_number, data[0..magic_number.len])) {
        const end_of_declaration = std.mem.indexOf(u8, data, end_of_decl) orelse return error.Malformed;
        reader.take(end_of_declaration + end_of_decl.len);
        std.log.err("dec:[{s}]", .{data[0 .. end_of_declaration + end_of_decl.len]});
        reader.skipWhitespace();
    }
    while (true) {
        const xml_data = try reader.until('<');
        std.log.err("[{s}]", .{xml_data});
        const tag = try reader.until('>');
        if (tag[0] == '/') {
            std.log.err("end_tag[{s}]", .{tag});
        } else if (tag[tag.len - 1] == '/') {
            std.log.err("empty_tag[{s}]", .{tag});
        } else {
            std.log.err("tag[{s}]", .{tag});
        }
        reader.skipWhitespace();
    }
    return doc;
}

test {
    const filename = "/usr/share/wayland-protocols/stable/xdg-shell/xdg-shell.xml";
    var file = try std.fs.openFileAbsolute(filename, .{});
    defer file.close();
    var buf: [4096]u8 = undefined;
    var reader = file.reader(&buf);

    var writer = std.Io.Writer.Allocating.init(std.testing.allocator);
    defer writer.deinit();

    _ = try writer.writer.sendFile(&reader, .unlimited);

    const doc = try parse(writer.written(), std.testing.allocator);
    defer doc.deinit();
}

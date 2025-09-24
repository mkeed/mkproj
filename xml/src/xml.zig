const std = @import("std");

const ArenaAllocator = std.heap.ArenaAllocator;

pub const XmlDoc = struct {
    arena: *ArenaAllocator,
    //data: []const u8,
    root: *Node,
    pub fn init(alloc: std.mem.Allocator) !XmlDoc {
        const arena = try alloc.create(ArenaAllocator);
        errdefer arena.deinit();
        arena.* = ArenaAllocator.init(alloc);
        errdefer arena.deinit();

        return .{
            .arena = arena,
            .root = undefined,
        };
    }

    pub fn deinit(self: XmlDoc) void {
        const alloc = self.arena.child_allocator;
        self.arena.deinit();
        alloc.destroy(self.arena);
    }

    pub fn search(self: XmlDoc, items: []const []const u8) void {
        std.log.err("num nodes:[{}]", .{self.root.subNode.len});
        for (self.root.subNode) |n| {
            switch (n) {
                .text => |t| {
                    std.log.err("[{s}]", .{t});
                },
                .node => |s_n| {
                    if (std.mem.eql(u8, items[0], s_n.name)) {}
                    std.log.err("[{s}]", .{s_n.name});
                },
            }
        }
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
    pub fn until(self: *Reader, data: []const u8) ![]const u8 {
        const start = self.idx;
        if (std.mem.indexOfPos(u8, self.data, self.idx, data)) |pos| {
            self.idx = pos + data.len;
            return self.data[start..pos];
        }
        return error.EndOfStream;
    }
    pub fn match(self: *Reader, data: []const u8) bool {
        if (self.idx + data.len < self.data.len) {
            return std.mem.eql(u8, self.data[self.idx..][0..data.len], data);
        }
        return false;
    }
};

const SubNode = union(enum) {
    node: *Node,
    text: []const u8,
};

const Node = struct {
    name: []const u8,
    attrs: []const u8,
    subNode: []const SubNode,
};

const NodeBuilder = struct {
    const ActiveNode = struct {
        name: []const u8,
        attrs: []const u8,
        subItems: std.ArrayList(SubNode),
    };
    alloc: std.mem.Allocator,
    stack: std.ArrayList(ActiveNode),

    depth: usize = 0,

    pub fn add_text(self: *NodeBuilder, data: []const u8) !void {
        if (self.stack.items.len == 0) return error.ExpectedItem;
        if (data.len == 0) return;
        try self.stack.items[self.stack.items.len - 1].subItems.append(self.alloc, .{ .text = data });
        //std.log.err("[{} => `{s}`]", .{ self.depth, data });
    }
    fn parse_tag(data: []const u8) !struct {
        name: []const u8,
        attrs: []const u8,
    } {
        var split = std.mem.splitScalar(u8, data, ' ');
        const name = split.next() orelse return error.TODO;
        const attrs = split.rest();
        return .{
            .name = name,
            .attrs = attrs,
        };
    }
    pub fn push_node(self: *NodeBuilder, tag: []const u8) !void {
        const tag_info = try parse_tag(tag);
        try self.stack.append(self.alloc, .{ .name = tag_info.name, .attrs = tag_info.attrs, .subItems = .{} });
        self.depth += 1;

        //std.log.err("push[{} => {s}]", .{ self.depth, tag });
    }

    pub fn pop_node(self: *NodeBuilder, tag: []const u8) !*Node {
        var builder_node = self.stack.pop() orelse return error.TooManyCloses;
        _ = tag;
        const node = try self.alloc.create(Node);
        node.* = .{
            .name = builder_node.name,
            .attrs = builder_node.attrs,
            .subNode = try builder_node.subItems.toOwnedSlice(self.alloc),
        };
        self.depth -= 1;
        if (self.stack.items.len > 0) {
            try self.stack.items[self.stack.items.len - 1].subItems.append(
                self.alloc,
                .{ .node = node },
            );
        }

        //std.log.err("pop[{}:{s}[{}] => {s}]", .{ self.depth, builder_node.name, node.subNode.len, tag });
        return node;
    }

    pub fn empty_node(self: *NodeBuilder, tag: []const u8) !void {
        //std.log.err("empty[{} => {s}]", .{ self.depth, tag });
        const tag_info = try parse_tag(tag);
        const node = try self.alloc.create(Node);
        node.* = .{
            .name = tag_info.name,
            .attrs = tag_info.attrs,
            .subNode = &.{},
        };
        try self.stack.items[self.stack.items.len - 1].subItems.append(
            self.alloc,
            .{ .node = node },
        );
    }
};

pub fn parse(data: []const u8, alloc: std.mem.Allocator) !XmlDoc {
    var doc = try XmlDoc.init(alloc);
    errdefer doc.deinit();
    var reader = Reader{ .data = data };

    var builder = NodeBuilder{
        .alloc = doc.arena.allocator(),
        .stack = .{},
    };
    try builder.push_node("root");
    while (true) {
        const xml_data = reader.until("<") catch |err| {
            switch (err) {
                error.EndOfStream => break,
                else => return err,
            }
        };
        if (xml_data.len != 0) {
            try builder.add_text(xml_data);
        }
        if (reader.match("!--")) {
            _ = try reader.until("-->");
        } else if (reader.match("![CDATA[")) {
            const cdata = try reader.until("]]>");

            try builder.add_text(cdata);
        } else {
            const tag = try reader.until(">");
            if (tag[0] == '/') {
                _ = try builder.pop_node(tag[1..]);
            } else if (tag[tag.len - 1] == '/') {
                _ = try builder.empty_node(tag[0 .. tag.len - 2]);
            } else if (tag[0] == '?') {
                //std.log.err("Declaration[{s}]", .{tag});
            } else {
                _ = try builder.push_node(tag);
            }
        }
        reader.skipWhitespace();
    }
    doc.root = try builder.pop_node("root");
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
    doc.search(&.{ "protocol", "interface" });
    //std.lo
}

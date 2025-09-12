const std = @import("std");

pub const Operator = enum {
    add,
    sub,
    multiply,
    divide,
};

pub const Syntax = enum {
    OpenParen,
    CloseParen,
    OpenBrace,
    CloseBrace,
    OpenBracket,
    CloseBracket,
};

pub const Token = union(enum) {
    operator: Operator,
    syntax: Syntax,
    number: []const u8,
    pub fn format(self: Token, writer: *std.Io.Writer) !void {
        switch (self) {
            .operator => |o| try writer.print("(Op:{s})", .{@tagName(o)}),
            .syntax => |s| try writer.print("(Syntax:{s})", .{@tagName(s)}),
            .number => |n| try writer.print("(Number:{s})", .{n}),
        }
    }
};
const ParseResult = struct { len: usize, token: Token };
const Parser = union(enum) {
    text: struct { txt: []const u8, token: Token },
    func: *const fn (input: []const u8) ?ParseResult,
};

const parsers = [_]Parser{
    .{ .text = .{ .txt = "+", .token = .{ .operator = .add } } },
    .{ .text = .{ .txt = "-", .token = .{ .operator = .sub } } },
    .{ .text = .{ .txt = "/", .token = .{ .operator = .divide } } },
    .{ .text = .{ .txt = "*", .token = .{ .operator = .multiply } } },

    .{ .text = .{ .txt = "(", .token = .{ .syntax = .OpenParen } } },
    .{ .text = .{ .txt = ")", .token = .{ .syntax = .CloseParen } } },
    .{ .text = .{ .txt = "{", .token = .{ .syntax = .OpenBrace } } },
    .{ .text = .{ .txt = "}", .token = .{ .syntax = .CloseBrace } } },
    .{ .text = .{ .txt = "[", .token = .{ .syntax = .OpenBracket } } },
    .{ .text = .{ .txt = "]", .token = .{ .syntax = .CloseBracket } } },

    .{ .func = parseNumber },
};

const Reader = struct {
    data: []const u8,
    idx: usize = 0,
    pub fn getStr(self: Reader, len: usize) ?[]const u8 {
        if (self.idx + len < self.data.len) {
            return self.data[self.idx..][0..len];
        }
        return null;
    }
    pub fn eql(self: *Reader, str: []const u8) bool {
        if (self.getStr(str.len)) |val| {
            const result = std.mem.eql(u8, val, str);
            if (result) self.idx += str.len;
            return result;
        }
        return false;
    }
    pub fn consume(self: *Reader, len: usize) void {
        self.idx += len;
    }
    pub fn rest(self: Reader) []const u8 {
        return self.data[self.idx..];
    }
    pub fn more(self: Reader) bool {
        return self.idx < self.data.len;
    }
};

pub fn tokenize(input: []const u8, alloc: std.mem.Allocator) ![]Token {
    var list = std.ArrayList(Token){};
    errdefer list.deinit(alloc);
    try list.ensureTotalCapacity(alloc, 100);
    var reader = Reader{ .data = input };

    reader_loop: while (reader.more()) {
        for (parsers) |p| {
            switch (p) {
                .text => |t| {
                    if (reader.eql(t.txt)) {
                        try list.append(alloc, t.token);
                        continue :reader_loop;
                    }
                },
                .func => |f| {
                    if (f(reader.rest())) |t| {
                        reader.consume(t.len);
                        try list.append(alloc, t.token);
                        continue :reader_loop;
                    }
                },
            }
        }
        break;
    }

    return try list.toOwnedSlice(alloc);
}

fn parseNumber(input: []const u8) ?ParseResult {
    for (input, 0..) |char, idx| {
        if (std.mem.indexOfScalar(u8, "0123456789", char)) |_| {} else {
            if (idx == 0) {
                return null;
            } else {
                return .{
                    .len = idx,
                    .token = .{ .number = input[0..idx] },
                };
            }
        }
    }
    if (input.len > 0) {
        return .{
            .len = input.len,
            .token = .{ .number = input },
        };
    }

    return null;
}

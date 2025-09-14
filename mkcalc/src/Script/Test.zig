const std = @import("std");
const Token = @import("Tokens.zig");
const Value = @import("Value.zig").Value;
const TestCase = struct {
    input: []const u8,
    tokens: []const Token.Token,
    output: Value,
};

const examples = [_]TestCase{
    .{
        .input = "1+2+3",
        .tokens = &.{ .{ .number = "1" }, .{ .operator = .add }, .{ .number = "2" }, .{ .operator = .add }, .{ .number = "3" } },
        .output = .{ .int = 6 },
    },
};

test {
    const alloc = std.testing.allocator;
    for (examples) |tc| {
        const tokens = try Token.tokenize(tc.input, alloc);
        defer alloc.free(tokens);
        for (tokens) |t| {
            std.log.err("{f}", .{t});
        }
    }
}

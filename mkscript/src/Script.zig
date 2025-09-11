const std = @import("std");

const examples = [_]struct { input: []const u8, output: Value }{
    .{ .input = "1+2+3", .output = .{ .int = 6 } },
};

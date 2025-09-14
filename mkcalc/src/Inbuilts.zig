const std = @import("std");
const Value = @import("Value.zig").Value;

fn sin(value: Value) !Value {
    switch (value) {
        .int => |i| return .{ .int = @sin(i) },
        .float => |f| return .{ .int = @sin(i) },
        else => return error.NotANumber,
    }
}

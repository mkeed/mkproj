const std = @import("std");
const Value = @import("Value.zig").Value;

const Function = *const fn (arg: Value) Value;

pub const Inbuilt = struct {
    name: []const u8,
    func: Function,
};

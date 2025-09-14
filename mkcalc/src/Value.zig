const std = @import("std");
const Function = @import("Function.zig").Function;

pub const Value = union(enum) {
    int: i64,
    float: f64,
    string: []const u8,
    function: *Function,
};

const std = @import("std");

pub const Operator = enum {
    add,
    sub,
    multiply,
    divide,
};

pub const Token = union(enum) {
    operator: Operator,
};

const std = @import("std");

pub const Name = struct {
    name1: []const u8,
    name2: []const u8,
};

pub const Import = struct {
    name: Name,
};

pub const Binary = struct {
    functions: []const Function,
    imports: []const Import,
    exports: []const Export,
};

pub const Instance = struct {
    binary: *const Binary,
};

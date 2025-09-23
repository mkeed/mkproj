const std = @import("std");

pub const Name = struct {
    name1: []const u8,
    name2: []const u8,
};

pub const Import = struct {
    name: Name,
    import: ExportInfo,
};

pub const ExportInfo = union(enum) {
    func: Func,
    table: Table,
    memory: Memory,
    global: Global,
    tag: Tag,
};

pub const Export = struct {
    name: Name,
    @"export": ExportInfo,
};

pub const Function = struct {
    blocks: []const Block,
};

pub const Binary = struct {
    functions: []const Function,
    imports: []const Import,
    exports: []const Export,
};

pub const Instance = struct {
    binary: *const Binary,
};

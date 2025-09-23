const std = @import("std");

pub const EditorContext = struct {
    root: std.fs.Dir,
    alloc: std.mem.Allocator,
    config: *Config,
};

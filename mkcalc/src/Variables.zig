const std = @import("std");
const Value = @import("Value.zig").Value;

pub const Variable = union(enum) {
    val: Value,
};

pub const Variables = struct {
    map: std.StringArrayHashMap(Variable),
    alloc: std.mem.Allocator,
    pub fn init(alloc: std.mem.Allocator) Variables {
        return .{
            .hashmap = std.StringArrayHashMap(Variable).init(alloc),
            .alloc = alloc,
        };
    }

    pub fn deinit(self: Variables) void {
        for (self.hashmap.keys()) |k| {
            self.alloc.free(k);
        }
        for (self.map.values()) |v| {}
        self.hashmap.deinit();
    }
};

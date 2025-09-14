const std = @import("std");
const mkcalc = @import("mkcalc");
const Term = @import("Term.zig").Term;

pub fn main() !void {
    var gpa = std.heap.DebugAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    var t = Term.init(alloc);
    defer t.deinit();
}

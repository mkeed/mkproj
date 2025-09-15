const std = @import("std");
const mkcalc = @import("mkcalc");
const Term = @import("Term.zig").Term;

pub fn main() !void {
    var gpa = std.heap.DebugAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    var t = try Term.init(alloc);
    defer t.deinit();
    try t.draw();

    std.Thread.sleep(2000 * std.time.ns_per_ms);
}

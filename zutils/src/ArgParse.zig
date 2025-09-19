const std = @import("std");

pub const Program = struct {
    name: []const u8,
    opts: []const Option,
    inbuilts: struct {
        help: bool = true,
        version: bool = true,
    },
    result: type,
};

pub const Option = struct {
    short: ?u8 = null,
    long: ?[]const u8 = null,
    field: []const u8,
};

pub fn parse(comptime opts: Program, args: []const [:0]const u8) !opts.result {
    //
    var result = opts.result{};
    for (args) |a| {
        inline for (opts.opts) |o| {
            if (o.long) |l| {
                if (std.mem.eql(u8, l, a)) {
                    @field(result, o.field) = true;
                }
            }
        }
    }
    return result;
}

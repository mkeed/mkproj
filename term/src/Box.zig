const std = @import("std");
const util = @import("Util.zig");
const Commands = @import("Commands.zig");
//   0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F
// U+250x          ┄  ┅  ┆  ┇  ┈  ┉  ┊  ┋
// U+251x                            ┝  ┞  ┟
// U+252x  ┠  ┡  ┢      ┥  ┦  ┧  ┨  ┩  ┪      ┭  ┮  ┯
// U+253x  ┰  ┱  ┲      ┵  ┶  ┷  ┸  ┹  ┺      ┽  ┾  ┿
// U+254x  ╀  ╁  ╂  ╃  ╄  ╅  ╆  ╇  ╈  ╉  ╊    ╌  ╍  ╎  ╏

// U+257x    ╱  ╲  ╳

pub const Box = struct {
    up: bool = false,
    down: bool = false,
    left: bool = false,
    right: bool = false,
};
const Style = enum(u2) { thin = 0, thick = 1, double = 2, curve = 3 };

pub fn draw(pos: util.Rect, style: Style, writer: *std.Io.Writer) !void {
    const idx = @intFromEnum(style);
    try writer.print(
        Commands.Cursor.MoveTo ++ "{s}",
        .{ pos.pos.y, pos.pos.x, corners[idx][0] },
    );
    try writer.print(
        Commands.Cursor.MoveTo ++ "{s}",
        .{ pos.pos.y, pos.pos.x + pos.size.x, corners[idx][1] },
    );
    try writer.print(
        Commands.Cursor.MoveTo ++ "{s}",
        .{ pos.pos.y + pos.size.y, pos.pos.x, corners[idx][2] },
    );
    try writer.print(
        Commands.Cursor.MoveTo ++ "{s}",
        .{ pos.pos.y + pos.size.y, pos.pos.x + pos.size.x, corners[idx][3] },
    );

    for (1..@intCast(pos.size.x)) |_p| {
        const p: i32 = @intCast(_p);
        try writer.print(
            Commands.Cursor.MoveTo ++ "{s}",
            .{ pos.pos.y, pos.pos.x + p, lines[idx][1] },
        );
    }
    for (1..@intCast(pos.size.x)) |_p| {
        const p: i32 = @intCast(_p);
        try writer.print(
            Commands.Cursor.MoveTo ++ "{s}",
            .{ pos.pos.y + pos.size.y, pos.pos.x + p, lines[idx][1] },
        );
    }

    for (1..@intCast(pos.size.y)) |_p| {
        const p: i32 = @intCast(_p);
        try writer.print(
            Commands.Cursor.MoveTo ++ "{s}",
            .{ pos.pos.y + p, pos.pos.x, lines[idx][0] },
        );
        try writer.print(
            Commands.Cursor.MoveTo ++ "{s}",
            .{ pos.pos.y + p, pos.pos.x + pos.size.x, lines[idx][0] },
        );
    }
}

const corners = [4][4][]const u8{
    .{ "┌", "┐", "└", "┘" },
    .{ "┏", "┓", "┗", "┛" },
    .{ "╔", "╗", "╚", "╝" },
    .{ "╭", "╮", "╰", "╯" },
};

const lines = [4][2][]const u8{
    .{ "│", "─" },
    .{ "┃", "━" },
    .{ "║", "═" },
    .{ "│", "─" },
};

const Ts = [4][4][]const u8{
    .{ "┴", "├", "┬", "┤" },
    .{ "┻", "┣", "┳", "┫" },
    .{ "╩", "╠", "╦", "╣" },
    .{ "┴", "├", "┬", "┤" },
};

const Xs = [4][]const u8{ "┼", "╋", "╬", "┼" };

pub const Loading = [_][]const u8{ "🮠", "🮡", "🮢", "🮣", "🮦", "🮤", "🮧", "🮥", "🮪", "🮫", "🮬", "🮭", "🮮" };

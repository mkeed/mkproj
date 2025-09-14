const std = @import("std");
const Colour = @import("Colour.zig").Colour;
const CSI = "\x1b[";

pub const Font = struct {
    foreground: ?Colour = null,
    background: ?Colour = null,

    bold: bool = false,
    italic: bool = false,
    strike: bool = false,
    underline: ?struct {
        colour: ?Colour = null,
        style: enum(u8) { straight = 1, double = 2, curly = 3, dotted = 4, dashed = 5 },
    } = null,

    pub fn encode(self: Font, writer: *std.Io.Writer) !void {
        if (self.foreground) |c| try writer.print(
            CSI ++ "38;2;{};{};{}m",
            .{ c.r, c.g, c.b },
        );
        if (self.background) |c| try writer.print(
            CSI ++ "48;2;{};{};{}m",
            .{ c.r, c.g, c.b },
        );
        if (self.underline) |u| {
            if (u.colour) |c| try writer.print(
                CSI ++ "58;2;{};{};{}m",
                .{ c.r, c.g, c.b },
            );
            try writer.print(CSI ++ "4:{}m", .{@intFromEnum(u.style)});
        }
        if (self.bold) try writer.print(CSI ++ "1m", .{});
        if (self.italic) try writer.print(CSI ++ "2m", .{});
        if (self.strike) try writer.print(CSI ++ "9m", .{});
    }
    pub const Clear = CSI ++ "0m";
};

pub const AltScreen = struct {
    pub const Enable = CSI ++ "?1049h";
    pub const Disable = CSI ++ "?1049l";
};

pub const Cursor = struct {
    pub const Hide = CSI ++ "?25l";
    pub const Show = CSI ++ "?25h";

    pub const Home = CSI ++ "H";
    pub const MoveTo = CSI ++ "{};{}H";
};

pub const Erase = struct {
    pub const Screen = struct {
        pub const ToEnd = CSI ++ "0J";
        pub const ToBegin = CSI ++ "1J";
        pub const All = CSI ++ "2J";
    };
    pub const Line = struct {
        pub const ToEnd = CSI ++ "0K";
        pub const ToBegin = CSI ++ "1K";
        pub const All = CSI ++ "2K";
    };
};

pub const BracketedPaste = struct {
    pub const Enable = CSI ++ "?2004h";
    pub const Disable = CSI ++ "?2004l";
};

pub const SyncronizedOutput = struct {
    pub const Enable = CSI ++ "?2026h";
    pub const Disable = CSI ++ "?2026l";
};

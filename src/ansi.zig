const std = @import("std");

// Avoid calling `std.io.getStdOut().isTty()` every time
var use_colors: bool = true; // Global setting
pub fn detectTty() void {
    use_colors = std.io.getStdOut().isTty();
}

// Setter function (for tests)
pub fn setUseColors(value: bool) void {
    use_colors = value;
}

// Getter function (if needed)
pub fn getUseColors() bool {
    return use_colors;
}

pub const AnsiStyle = enum {
    // Modifiers
    Bold,
    Dim,
    Italic,
    Underline,
    Inverse,
    Hidden,
    Strikethrough,

    // Text Colors
    Black,
    Red,
    Green,
    Yellow,
    Blue,
    Magenta,
    Cyan,
    White,
    Gray,
    Grey, // Alias

    // Background Colors
    BgBlack,
    BgRed,
    BgGreen,
    BgYellow,
    BgBlue,
    BgMagenta,
    BgCyan,
    BgWhite,

    pub fn code(self: AnsiStyle) []const u8 {
        return switch (self) {
            .Bold => "1",
            .Dim => "2",
            .Italic => "3",
            .Underline => "4",
            .Inverse => "7",
            .Hidden => "8",
            .Strikethrough => "9",
            // Text Colors
            .Black => "30",
            .Red => "31",
            .Green => "32",
            .Yellow => "33",
            .Blue => "34",
            .Magenta => "35",
            .Cyan => "36",
            .White => "37",
            .Gray, .Grey => "90", // Alias for Gray
            // Background Colors
            .BgBlack => "40",
            .BgRed => "41",
            .BgGreen => "42",
            .BgYellow => "43",
            .BgBlue => "44",
            .BgMagenta => "45",
            .BgCyan => "46",
            .BgWhite => "47",
        };
    }
};

pub const Formatter = struct {
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) Formatter {
        return Formatter{ .allocator = allocator };
    }

    pub fn format(self: *Formatter, text: []const u8, styles: []const AnsiStyle) ![]const u8 {
        var buffer = std.ArrayList(u8).init(self.allocator);
        defer buffer.deinit();

        if (use_colors) {
            // Start ANSI sequence
            try buffer.appendSlice("\x1b[");
            // Append style codes
            for (styles, 0..) |style, i| {
                if (i > 0) try buffer.appendSlice(";");
                try buffer.appendSlice(style.code());
            }
            try buffer.appendSlice("m"); // Close ANSI sequence
        }

        try buffer.appendSlice(text);

        if (use_colors) {
            try buffer.appendSlice("\x1b[0m"); // Reset formatting
        }

        return buffer.toOwnedSlice(); // Return formatted string
    }
};

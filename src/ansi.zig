//! A lightweight ANSI text formatting library for styling terminal output in Zig.
const std = @import("std");

// Avoid calling `std.io.getStdOut().isTty()` every time
/// Global setting to enable or disable ANSI color support.
/// This is automatically detected but can be overridden using `setUseColors()`.
var use_colors: bool = true;

/// Detects if the standard output is a TTY (terminal).
///
/// This function updates the `use_colors` global variable based on whether the
/// standard output is connected to a terminal.
///
/// # Example
/// ```zig
/// detectTty(); // Updates `use_colors`
/// ```
pub fn detectTty() void {
    use_colors = std.io.getStdOut().isTty();
}

/// Manually sets whether ANSI colors should be used.
///
/// This is useful for tests or forcing color output in non-TTY environments.
///
/// # Example
/// ```zig
/// setUseColors(false); // Disable colors
/// ```
pub fn setUseColors(value: bool) void {
    use_colors = value;
}

/// Returns the current state of ANSI color usage.
///
/// # Example
/// ```zig
/// if (getUseColors()) {
///     std.debug.print("Colors are enabled\n", .{});
/// }
/// ```
pub fn getUseColors() bool {
    return use_colors;
}

/// Represents ANSI styles for text formatting.
///
/// This enum includes modifiers (e.g., `Bold`, `Italic`), text colors (e.g., `Red`, `Blue`),
/// and background colors (e.g., `BgYellow`, `BgCyan`).
///
/// # Example
/// ```zig
/// const style = AnsiStyle.Bold;
/// const code = style.code(); // "1"
/// ```
pub const AnsiStyle = enum {
    // Modifiers
    /// Makes text bold or bright.
    Bold,
    /// Makes text appear dim or faded.
    Dim,
    /// Applies italic styling (not supported in all terminals).
    Italic,
    /// Underlines the text.
    Underline,
    /// Inverts foreground and background colors.
    Inverse,
    /// Hides the text (useful for security-sensitive displays).
    Hidden,
    /// Strikes through the text.
    Strikethrough,

    // Text Colors
    /// Sets text color to black.
    Black,
    /// Sets text color to red.
    Red,
    /// Sets text color to green.
    Green,
    /// Sets text color to yellow.
    Yellow,
    /// Sets text color to blue.
    Blue,
    /// Sets text color to magenta.
    Magenta,
    /// Sets text color to cyan.
    Cyan,
    /// Sets text color to white.
    White,
    /// Sets text color to gray.
    Gray,
    /// Alias for `Gray`.
    Grey,

    // Background Colors
    /// Sets background color to black.
    BgBlack,
    /// Sets background color to red.
    BgRed,
    /// Sets background color to green.
    BgGreen,
    /// Sets background color to yellow.
    BgYellow,
    /// Sets background color to blue.
    BgBlue,
    /// Sets background color to magenta.
    BgMagenta,
    /// Sets background color to cyan.
    BgCyan,
    /// Sets background color to white.
    BgWhite,

    /// Returns the ANSI escape code for the given style.
    ///
    /// # Example
    /// ```zig
    /// const code = AnsiStyle.Bold.code(); // "1"
    /// ```
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

/// Formatter struct for applying ANSI styles to text.
///
/// This struct provides an API for formatting strings with ANSI styles.
/// It requires an allocator for memory management.
///
/// # Example
/// ```zig
/// const allocator = std.heap.page_allocator;
/// var formatter = Formatter.init(allocator);
/// const formatted = try formatter.format("Hello", &.{AnsiStyle.Bold});
/// std.debug.print("{s}\n", .{formatted});
/// ```
pub const Formatter = struct {
    /// The allocator used for memory management.
    allocator: std.mem.Allocator,

    /// Initializes a new `Formatter` with the given allocator.
    ///
    /// # Example
    /// ```zig
    /// const allocator = std.heap.page_allocator;
    /// var formatter = Formatter.init(allocator);
    /// ```
    pub fn init(allocator: std.mem.Allocator) Formatter {
        return Formatter{ .allocator = allocator };
    }

    /// Formats a given text with ANSI styles.
    ///
    /// This function applies ANSI styles to the text and returns a newly allocated string.
    ///
    /// # Parameters
    /// - `text`: The input text to format.
    /// - `styles`: A slice of `AnsiStyle` enums to apply.
    ///
    /// # Returns
    /// A newly allocated slice containing the formatted text.
    ///
    /// # Example
    /// ```zig
    /// const allocator = std.heap.page_allocator;
    /// var formatter = Formatter.init(allocator);
    /// const formatted = try formatter.format("Warning!", &.{AnsiStyle.Bold, AnsiStyle.Red});
    /// std.debug.print("{s}\n", .{formatted});
    /// ```
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

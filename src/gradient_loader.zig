const std = @import("std");
const stdout = std.io.getStdOut();
const sleep_duration: u64 = std.time.ns_per_ms * 50;

const bar_length: usize = 10;

/// Structure representing an RGB color.
pub const RGB = struct {
    /// Red component (0-255)
    r: u8,
    /// Green component (0-255)
    g: u8,
    /// Blue component (0-255)
    b: u8,
};

var precomputed_gradient: [bar_length][]const u8 = undefined;

/// Precomputes the color gradient backgrounds based on the provided base color.
///
/// This function calculates a smooth gradient transition using a sine wave function
/// and stores the formatted ANSI background sequences for each step.
///
/// - `base_color`: The base RGB color to generate the gradient from.
fn precomputeTruecolorGradient(base_color: RGB) void {
    // Cached float version of `bar_length - 1` for optimized division operations.
    const bar_length_minus_one_f32 = @as(f32, bar_length - 1);

    for (0..bar_length) |j_usize| {
        const j: f32 = @floatFromInt(j_usize);
        // `t` represents the normalized position in the gradient (ranging from 0 to 1).
        const t: f32 = j / bar_length_minus_one_f32;
        // This wave value is a sinusoidal function that modulates the gradient transition, ensuring a smooth blend rather than a linear shift.
        const wave: f32 = 0.5 + 0.5 * @sin(t * std.math.pi);
        // The factor adjusts the intensity of the color variation, limiting extreme brightness or darkness to keep the gradient visually balanced.
        const factor: f32 = 0.7 + wave * 0.3;

        const r_scaled: u8 = @intFromFloat(@as(f32, @floatFromInt(base_color.r)) * factor);
        const g_scaled: u8 = @intFromFloat(@as(f32, @floatFromInt(base_color.g)) * factor);
        const b_scaled: u8 = @intFromFloat(@as(f32, @floatFromInt(base_color.b)) * factor);

        const r: u8 = @truncate(r_scaled);
        const g: u8 = @truncate(g_scaled);
        const b: u8 = @truncate(b_scaled);

        // Format the ANSI background sequence for each position.
        precomputed_gradient[j_usize] = std.fmt.allocPrint(
            std.heap.page_allocator,
            "\x1b[48;2;{};{};{}m ",
            .{ r, g, b },
        ) catch "";
    }
}

/// Starts the gradient loader animation, displaying the gradient alongside a message.
///
/// This function continuously updates the loader with the precomputed gradient, cycling
/// through colors smoothly. It also ensures a consistent frame rate.
///
/// - `message`: The message to be displayed next to the gradient loader.
/// - `base_color`: The base RGB color used to generate the gradient.
pub fn startGradientLoader(message: []const u8, base_color: RGB) !void {
    precomputeTruecolorGradient(base_color);
    var i: usize = 0;
    var last_time: u64 = @intCast(std.time.microTimestamp());
    try stdout.writeAll("\x1b[?25l"); // Hide cursor
    try stdout.writeAll("\x1b[s"); // Save cursor position
    while (true) {
        try stdout.writeAll("\x1b[u"); // Restore cursor position
        for (0..bar_length) |j| {
            try stdout.writeAll(precomputed_gradient[(i + j) % bar_length]);
        }
        try stdout.writeAll("\x1b[0m "); // Reset color
        try stdout.writeAll(message);

        const now: u64 = @intCast(std.time.microTimestamp());
        const elapsed: u64 = now - last_time;
        last_time = now;

        if (elapsed < sleep_duration) {
            std.time.sleep(sleep_duration - elapsed);
        }

        i += 1;
    }
    try stdout.writeAll("\x1b[?25h\n"); // Show cursor and move to next line
}

const std = @import("std");
const anybit = @import("anybit");
const ansi = anybit.ansi;
const gradient_loader = anybit.gradient_loader;

// TODO: Make this a CLI playground
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    defer _ = gpa.deinit();

    var fmt = ansi.Formatter.init(allocator);

    const welcomeMsg = try fmt.format("🚀 Welcome to Anybit CLI!", &.{ .Cyan, .Bold });
    defer allocator.free(welcomeMsg);

    const warningMsg = try fmt.format("⚠️  Warning: Low disk space!", &.{ .Yellow, .Bold, .Underline });
    defer allocator.free(warningMsg);

    const errorMsg = try fmt.format("❌ Error: Connection lost!", &.{ .Red, .Bold, .BgBlack });
    defer allocator.free(errorMsg);

    const successMsg = try fmt.format("✅ Success: Operation completed!", &.{ .Green, .Bold });
    defer allocator.free(successMsg);

    std.debug.print("{s}\n", .{welcomeMsg});
    std.debug.print("{s}\n", .{warningMsg});
    std.debug.print("{s}\n", .{errorMsg});
    std.debug.print("{s}\n", .{successMsg});

    try gradient_loader.startGradientLoader("Loading...", .{ .r = 85, .g = 105, .b = 251 });
}

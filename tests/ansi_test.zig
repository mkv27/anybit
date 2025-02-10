const std = @import("std");
const anybit = @import("anybit");
const ansi = anybit.ansi;
const AnsiStyle = ansi.AnsiStyle;

test "format applies ANSI styles correctly" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var fmt = ansi.Formatter.init(allocator);

    // Backup `use_colors` to restore after the test
    const original_use_colors = ansi.getUseColors();

    // Test 1: Simple Red Text
    ansi.setUseColors(true); // Enable ANSI colors
    const redText = try fmt.format("Hello", &.{AnsiStyle.Red});
    defer allocator.free(redText);
    try std.testing.expectEqualStrings("\x1b[31mHello\x1b[0m", redText);

    // Test 2: Bold + Blue
    ansi.setUseColors(true); // Enable ANSI colors
    const boldBlueText = try fmt.format("Test", &.{ AnsiStyle.Bold, AnsiStyle.Blue });
    defer allocator.free(boldBlueText);
    try std.testing.expectEqualStrings("\x1b[1;34mTest\x1b[0m", boldBlueText);

    // Test 3: No ANSI when disabled
    ansi.setUseColors(false); // Disable ANSI colors
    const plainText = try fmt.format("No Colors", &.{AnsiStyle.Red});
    defer allocator.free(plainText);
    try std.testing.expectEqualStrings("No Colors", plainText);

    // Restore `use_colors` after test
    ansi.setUseColors(original_use_colors);
}

# ANSI

## Example
```zig
const std = @import("std");
const anybit = @import("anybit");
const ansi = anybit.ansi;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    defer _ = gpa.deinit();

    var fmt = ansi.Formatter.init(allocator);

    const greeting = try fmt.format("👋 Hello, Zig!", &.{ .Blue, .Bold, .Underline });
    defer allocator.free(greeting);

    const action = try fmt.format("🚀 Let's build something amazing!", &.{ .Green, .Bold });
    defer allocator.free(action);

    std.debug.print("{s} >> {s}\n", .{ greeting, action });
}
```
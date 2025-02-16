# anybit

**anybit** is a Zig library that provides various utilities for building modern CLI applications, including ANSI text formatting, argument parsing, progress bars, and logging.

This project is primarily a learning journey to improve Zig skills and become a better developer. The goal is to write clear, efficient, and maintainable code without overengineering, making it a useful resource for others who want to learn Zig as well. Contributions are welcome, especially if they help simplify and enhance the library while keeping it approachable for newcomers.

This library is fully inspired by [kleur](https://github.com/lukeed/kleur), a minimal and fast ANSI color formatting library for JavaScript.

## Features
- [x] **Lightweight**: Minimal dependencies, optimized for performance.
- [x] **ANSI Styling**: Easily add colors and styles to terminal output.
- [x] **Loading Bars**: Display smooth loading indicators.
- [ ] **Argument Parsing**: Simple and efficient command-line argument handling.

## Installation

Clone the repository and use `zig build`:

```sh
# Clone the repository
git clone https://github.com/mkv27/anybit.git
cd anybit

# Build the library
zig build
```

## Usage

### Importing the Library

In your Zig project, import `anybit` as a module:

```zig
const anybit = @import("anybit");
const ansi = anybit.ansi;
```

### ANSI Styling Example

```zig
const std = @import("std");
const ansi = @import("anybit").ansi;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const styledText = try ansi.format(allocator, "Hello, Zig!", &.{ ansi.AnsiStyle.Red, ansi.AnsiStyle.Bold });
    defer allocator.free(styledText);

    std.debug.print("{s}\n", .{styledText});
}
```

### Running the Example
```sh
zig build run
```

## Running Tests

To run the unit tests, use:
```sh
zig build test
```

## Project Structure
```
anybit/
│── docs/
│── src/
│   ├── root.zig        # Library entry point
│   ├── ansi.zig        # ANSI styling utilities
│   ├── args.zig        # Argument parsing (future)
│   ├── progress.zig    # Progress bar utilities (future)
│── tests/
│   ├── ansi_test.zig   # Tests for ANSI module
│── build.zig           # Zig build system
│── README.md           # Documentation
```

## Contributing

Contributions are welcome! Feel free to submit issues and pull requests.

## License

This project is licensed under the MIT License.

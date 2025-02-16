const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Add the `anybit` module, it allows you to import anybit as a module
    const anybit_module = b.addModule("anybit", .{
        .root_source_file = b.path("src/root.zig"),
    });

    // Define `anybit` as a static library
    const lib = b.addStaticLibrary(.{
        .name = "anybit",
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(lib);

    // Define executable
    const exe = b.addExecutable(.{
        .name = "anybit",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    exe.root_module.addImport("anybit", anybit_module); // Attach module to executable
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // Set up tests for the library
    const lib_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    lib_unit_tests.root_module.addImport("anybit", anybit_module); // Attach module to tests
    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    // Set up tests for the executable
    const exe_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    exe_unit_tests.root_module.addImport("anybit", anybit_module); // Attach module to tests
    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    // Set up tests for external test files (like `tests/ansi_test.zig`)
    const external_tests = b.addTest(.{
        .root_source_file = b.path("tests/ansi_test.zig"),
        .target = target,
        .optimize = optimize,
    });

    external_tests.root_module.addImport("anybit", anybit_module); // Attach module to external tests
    const run_external_tests = b.addRunArtifact(external_tests);

    // Ensure the `zig build test` command runs all tests
    const test_step = b.step("test", "Run all unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
    test_step.dependOn(&run_exe_unit_tests.step);
    test_step.dependOn(&run_external_tests.step);

    // Create docs
    const install_docs = b.addInstallDirectory(.{
        .source_dir = lib.getEmittedDocs(),
        .install_dir = .prefix,
        .install_subdir = "docs",
    });
    const docs_step = b.step("docs", "Install docs into zig-out/docs");
    docs_step.dependOn(&install_docs.step);
}

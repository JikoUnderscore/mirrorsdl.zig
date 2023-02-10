const std = @import("std");

pub fn build(b: *std.build.Builder) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    b.addModule(.{
        .name = "sdl",
        .source_file = .{ .path = "src/sdlmirror/sdl.zig" },
    });

    const lib = b.addStaticLibrary(.{
        .name = "sdl",
        .root_source_file = .{ .path = "src/sdlmirror/sdl.zig" },
        .target = target,
        .optimize = optimize,
    });

    const sdl2 = "./SDL/SDL2-2.26.2";
    const sdl2_image = "./SDL/SDL2_image-2.6.2";
    const sdl2_ttf = "./SDL/SDL2_ttf-2.20.1";
    const sdl2_gfx = "./SDL/SDL2_gfx-1.0.4";

    lib.addIncludePath(sdl2 ++ "/include");
    lib.addIncludePath(sdl2_image ++ "/include");
    lib.addIncludePath(sdl2_ttf ++ "/include");
    lib.addIncludePath(sdl2_gfx ++ "/include");

    lib.addLibraryPath(sdl2 ++ "/lib/x64");
    lib.addLibraryPath(sdl2_image ++ "/lib/x64");
    lib.addLibraryPath(sdl2_ttf ++ "/lib/x64");
    lib.addLibraryPath(sdl2_gfx ++ "/lib");

    b.installBinFile(sdl2 ++ "/lib/x64/SDL2.dll", "SDL2.dll");
    b.installBinFile(sdl2_image ++ "/lib/x64/SDL2_image.dll", "SDL2_image.dll");
    b.installBinFile(sdl2_ttf ++ "/lib/x64/SDL2_ttf.dll", "SDL2_ttf.dll");
    b.installBinFile(sdl2_gfx ++ "/lib/SDL2_gfx.dll", "SDL2_gfx.dll");

    lib.linkSystemLibrary("SDL2");
    lib.linkSystemLibrary("SDL2_image");
    lib.linkSystemLibrary("SDL2_ttf");
    lib.linkSystemLibrary("SDL2_gfx");
    lib.linkLibC();
    lib.install();

    // [_]struct { []const u8, []const u8 }
    const build_list = [_]struct { []const u8, []const u8 }{
        .{ "examples/animations.zig", "run_animations" },
        .{ "examples/cursor.zig", "run_cursor" },
        .{ "examples/window_properties.zig", "run_window_properties" },
        .{ "examples/ttf_demo.zig", "run_ttf_demo" },
        .{ "examples/events.zig", "run_events" },
        .{ "examples/game_of_life.zig", "run_game_of_life" },
        .{ "examples/gfx_demo.zig", "run_gfx_demo" },
        .{ "examples/keyboard_state.zig", "run_keyboard_state" },
        .{ "examples/image_demo.zig", "run_image_demo" },
        .{ "examples/test_gfx.zig", "run_test_gfx" },
    };

    for (build_list) |*bild| {
        var exe = b.addExecutable(.{
            .name = bild.*[1],
            .root_source_file = .{ .path = bild.*[0] },
            .target = target,
            .optimize = optimize,
        });

        // const sdl2 = "C:/Users/j1ko/SDL2/SDL2-2.26.2";
        // const sdl2_image = "C:/Users/j1ko/SDL2/SDL2_image-2.6.2";
        // const sdl2_ttf = "C:/Users/j1ko/SDL2/SDL2_ttf-2.20.1";
        // const sdl2_gfx = "C:/Users/j1ko/SDL2/SDL2_gfx-1.0.4/x64/Release/SDL2_gfx-1.0.4";

        exe.addIncludePath(sdl2 ++ "/include");
        exe.addIncludePath(sdl2_image ++ "/include");
        exe.addIncludePath(sdl2_ttf ++ "/include");
        exe.addIncludePath(sdl2_gfx ++ "/include");

        exe.addLibraryPath(sdl2 ++ "/lib/x64");
        exe.addLibraryPath(sdl2_image ++ "/lib/x64");
        exe.addLibraryPath(sdl2_ttf ++ "/lib/x64");
        exe.addLibraryPath(sdl2_gfx ++ "/lib");

        b.installBinFile(sdl2 ++ "/lib/x64/SDL2.dll", "SDL2.dll");
        b.installBinFile(sdl2_image ++ "/lib/x64/SDL2_image.dll", "SDL2_image.dll");
        b.installBinFile(sdl2_ttf ++ "/lib/x64/SDL2_ttf.dll", "SDL2_ttf.dll");
        b.installBinFile(sdl2_gfx ++ "/lib/SDL2_gfx.dll", "SDL2_gfx.dll");

        exe.linkSystemLibrary("SDL2");
        exe.linkSystemLibrary("SDL2_image");
        exe.linkSystemLibrary("SDL2_ttf");
        exe.linkSystemLibrary("SDL2_gfx");

        const sdl2_dep = b.createModule(.{ .source_file = .{ .path = "src/sdlmirror/sdl.zig" } });

        exe.addModule("sdl2", sdl2_dep);
        exe.linkLibC();
        exe.install();

        const run = exe.run();
        run.step.dependOn(b.getInstallStep());
        const run_step = b.step(bild.*[1], "Run an example");
        run_step.dependOn(&run.step);
    }
}

// const std = @import("std");
const sys = @import("raw_sdl.zig").sys;
const std = @import("std");

const SDLError = @import("errors.zig").SDLError;

const string = @import("sdl.zig").string;
const cstr = @import("sdl.zig").cstr;
const VideoSubsystem = @import("sdl.zig").VideoSubsystem;
const CanvasBuilder = @import("render.zig").CanvasBuilder;
const PixelFormatEnum = @import("pixels.zig").PixelFormatEnum;

pub const WindowPos = union(enum) {
    Undefined,
    Centered,
    Positioned: i32,
};

pub const WindowBuilder = struct {
    title: cstr,
    width: u32,
    height: u32,
    x: WindowPos,
    y: WindowPos,
    window_flags: u32,
    video_sys: VideoSubsystem,

    pub fn init(v: VideoSubsystem, title: cstr, width: u32, height: u32) WindowBuilder {
        return WindowBuilder{
            .title = title,
            .width = width,
            .height = height,
            .x = WindowPos.Undefined,
            .y = WindowPos.Undefined,
            .window_flags = 0,
            .video_sys = v,
        };
    }

    /// https://wiki.libsdl.org/SDL2/SDL_CreateWindow
    ///
    /// Deinit is handled by `WindowCanvas` (if exists).
    /// If you do not create `WindowCanvas` you have to call `Window.deinit()`.
    pub fn build(self: *WindowBuilder) SDLError!Window {
        const raw_window = sys.SDL_CreateWindow(self.title, to_ll_windowpos(self.x), to_ll_windowpos(self.y), @intCast(c_int, self.width), @intCast(c_int, self.height), self.window_flags) orelse {
            return SDLError.SDL_CreateWindowErr;
        };

        return Window{
            .raw = raw_window,
            .video_sys = self.video_sys,
        };
    }

    pub fn set_window_flags(self: *WindowBuilder, flags: u32) *WindowBuilder {
        self.window_flags = flags;
        return self;
    }

    pub fn position(self: *WindowBuilder, x: i32, y: i32) *WindowBuilder {
        self.x = WindowPos{ .Positioned = x };
        self.y = WindowPos{ .Positioned = y };
        return self;
    }

    pub fn position_centered(self: *WindowBuilder) *WindowBuilder {
        self.x = WindowPos.Centered;
        self.y = WindowPos.Centered;
        return self;
    }

    pub fn fullscreen(self: *WindowBuilder) *WindowBuilder {
        self.window_flags |= sys.SDL_WINDOW_FULLSCREEN;
        return self;
    }

    pub fn fullscreen_desktop(self: *WindowBuilder) *WindowBuilder {
        self.window_flags |= sys.SDL_WINDOW_FULLSCREEN_DESKTOP;
        return self;
    }

    pub fn opengl(self: *WindowBuilder) *WindowBuilder {
        self.window_flags |= sys.SDL_WINDOW_OPENGL;
        return self;
    }

    pub fn vulkan(self: *WindowBuilder) *WindowBuilder {
        self.window_flags |= sys.SDL_WINDOW_VULKAN;
        return self;
    }

    pub fn hidden(self: *WindowBuilder) *WindowBuilder {
        self.window_flags |= sys.SDL_WINDOW_HIDDEN;
        return self;
    }

    pub fn borderless(self: *WindowBuilder) *WindowBuilder {
        self.window_flags |= sys.SDL_WINDOW_BORDERLESS;
        return self;
    }

    pub fn resizable(self: *WindowBuilder) *WindowBuilder {
        self.window_flags |= sys.SDL_WINDOW_RESIZABLE;
        return self;
    }

    pub fn minimized(self: *WindowBuilder) *WindowBuilder {
        self.window_flags |= sys.SDL_WINDOW_MINIMIZED;
        return self;
    }

    pub fn maximized(self: *WindowBuilder) *WindowBuilder {
        self.window_flags |= sys.SDL_WINDOW_MAXIMIZED;
        return self;
    }

    pub fn input_grabbed(self: *WindowBuilder) *WindowBuilder {
        self.window_flags |= sys.SDL_WINDOW_INPUT_GRABBED;
        return self;
    }

    pub fn allow_highdpi(self: *WindowBuilder) *WindowBuilder {
        self.window_flags |= sys.SDL_WINDOW_ALLOW_HIGHDPI;
        return self;
    }
};

fn to_ll_windowpos(pos: WindowPos) c_int {
    return switch (pos) {
        .Undefined => sys.SDL_WINDOWPOS_UNDEFINED_MASK,
        .Centered => sys.SDL_WINDOWPOS_CENTERED_MASK,
        .Positioned => |x| x,
    };
}

/// https://wiki.libsdl.org/SDL2/SDL_Window
pub const Window = struct {
    raw: *sys.SDL_Window,
    video_sys: VideoSubsystem,

    /// https://wiki.libsdl.org/SDL2/SDL_DestroyWindow
    pub fn deinit(self: *const Window) void {
        sys.SDL_DestroyWindow(self.raw);
        self.video_sys.deinit();
    }

    pub fn into_canvas(self: Window) CanvasBuilder {
        return CanvasBuilder.init(self);
    }

    /// https://wiki.libsdl.org/SDL2/SDL_GetWindowPixelFormat
    pub fn window_pixel_format(self: *const Window) PixelFormatEnum {
        return PixelFormatEnum.from(sys.SDL_GetWindowPixelFormat(self.raw));
    }

    pub fn set_title(self: *Window, title: string) void {
        sys.SDL_SetWindowTitle(self.raw, title.ptr);
    }

    pub fn position(self: *const Window) struct{i32, i32} {
        var x: i32 = 0;
        var y: i32 = 0;
        sys.SDL_GetWindowPosition(self.raw, &x, &y);
        return .{x, y};
    }

    pub fn size(self: *const Window) struct{i32, i32} {
        var w: i32 = 0;
        var h: i32 = 0;
        sys.SDL_GetWindowSize(self.raw, &w, &h);
        return .{w, h};
    }
};

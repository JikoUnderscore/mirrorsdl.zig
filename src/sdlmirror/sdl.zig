pub const framerates = @import("gfx/framerates.zig");
pub const primitives = @import("gfx/primitives.zig");
pub const rotozoom = @import("gfx/rotozoom.zig");
pub const keyboard = @import("keyboard/keyboard.zig");
pub const keycode = @import("keyboard/keycode.zig");
pub const scancode = @import("keyboard/scancode.zig");
pub const mouse = @import("mouse/mouse.zig");
pub const cursor = @import("mouse/cursor.zig");
pub const ttf = @import("ttf/context.zig");
pub const font = @import("ttf/font.zig");
pub const controller = @import("controller.zig");
pub const errs = @import("errors.zig");
pub const events = @import("events.zig");
pub const image = @import("image.zig");
pub const joystick = @import("joystick.zig");
pub const pixels = @import("pixels.zig");
pub const raw_sdl_api = @import("raw_sdl.zig");
pub const rect = @import("rect.zig");
pub const render = @import("render.zig");
pub const rwops = @import("rwops.zig");
pub const surface = @import("surface.zig");
pub const videos = @import("videos.zig");



const std = @import("std");
const sys = @import("raw_sdl.zig").sys;





pub const string = []const u8;
pub const cstr = [*:0]const u8;
pub const OwnedStr = std.ArrayList(u8);



const WindowBuilder = videos.WindowBuilder;
const EventPump = events.EventPump;
const SDLError = @import("errors.zig").SDLError;
const KeyboardUtil = keyboard.KeyboardUtil;
const TextInputUtil = keyboard.TextInputUtil;






/// Destructor: `Sdl.deinit()`
/// 
pub fn init() SDLError!Sdl{
    return Sdl.init();
}




pub const Sdl = struct {

    /// https://wiki.libsdl.org/SDL2/SDL_Init
    fn init() SDLError!Sdl{
        if (sys.SDL_Init(0) == 0) {
            return Sdl{ };
        } else {
            return SDLError.SDL_InitErr;
        }
    }

    /// https://wiki.libsdl.org/SDL2/SDL_Quit
    pub fn deinit(_: Sdl) void{
        sys.SDL_Quit();
    }

    /// Destructor: `TimerSubsystem.deinit()`
    pub fn timer(_: Sdl) SDLError!TimerSubsystem {
        return TimerSubsystem.init();
    }

    /// Deinit is handled by `Window` (if exists) then it is moved to `WindowCanvas` (if exists).
    /// If you do not create `Window` or `WindowCanvas` you have to call `VideoSubsystem.deinit()`.
    pub fn video(_: Sdl) SDLError!VideoSubsystem {
        return VideoSubsystem.init();
    }

    /// Destructor: `EventPump.deinit()`
    pub fn event_pump(_: Sdl) SDLError!EventPump{
        return EventPump.init();
    }

    pub fn keyboard(_: Sdl) KeyboardUtil {
        return KeyboardUtil{};
    }

};




pub const VideoSubsystem = struct {

    /// https://wiki.libsdl.org/SDL2/SDL_InitSubSystem
    pub fn init() SDLError!VideoSubsystem{
        const result = sys.SDL_InitSubSystem(sys.SDL_INIT_VIDEO);
        
        if (result == 0) {
            return VideoSubsystem{};
        } else {
        return SDLError.SDL_InitSubSystem_Video_Err;
        }
    }

    /// https://wiki.libsdl.org/SDL2/SDL_QuitSubSystem
    pub fn deinit(_: VideoSubsystem) void{
        sys.SDL_QuitSubSystem(sys.SDL_INIT_VIDEO);
    }

    pub fn window(self: VideoSubsystem, title: cstr, width: u32, height: u32) WindowBuilder{
        return WindowBuilder.init(self, title, width, height); 
    }

    pub fn text_input(_: VideoSubsystem) TextInputUtil {
        return TextInputUtil{};
    }

};


pub const TimerSubsystem = struct {

    /// https://wiki.libsdl.org/SDL2/SDL_InitSubSystem
    /// Destructor: `TimerSubsystem.deinit()`
    pub fn init() SDLError!TimerSubsystem{
        const result = sys.SDL_InitSubSystem(sys.SDL_INIT_TIMER);
        
        if (result == 0) {
            return TimerSubsystem{};
        } else {
            return SDLError.SDL_InitSubSystem_Timer_Err;
        }
    }
    
    /// https://wiki.libsdl.org/SDL2/SDL_QuitSubSystem
    pub fn deinit(_: *const TimerSubsystem) void{
        sys.SDL_QuitSubSystem(sys.SDL_INIT_TIMER);
    }

    /// It's recommended that you use another library for timekeeping, such as `std.time`.
    pub fn ticks(_: *const TimerSubsystem) u32 {
        return sys.SDL_GetTicks();
    }


    /// It's recommended that you use another library for timekeeping, such as `std.time`.
    pub fn ticks64(_: *const TimerSubsystem) u64 {
        return sys.SDL_GetTicks64();
    }

    /// It's recommended that you use `std.time.sleep()` instead.
    pub fn delay(_: * TimerSubsystem, ms: u32) void {
        sys.SDL_Delay(ms);
    }

    pub fn performance_counter(_: *const TimerSubsystem) u64 {
        return sys.SDL_GetPerformanceCounter();
    }

    pub fn performance_frequency(_: *const TimerSubsystem) u64 {
        return sys.SDL_GetPerformanceFrequency();
    }

};



pub const ErrorCode = enum(i32){
    NoMemError = sys.SDL_ENOMEM,
    ReadError = sys.SDL_EFREAD,
    WriteError = sys.SDL_EFWRITE,
    SeekError = sys.SDL_EFSEEK,
    UnsupportedError = sys.SDL_UNSUPPORTED,
};



pub fn get_platform() string {
    return std.mem.span(sys.SDL_GetPlatform());
}

/// https://wiki.libsdl.org/SDL2/SDL_GetError
pub fn get_error() string{
    const err: [*c]const u8 = sys.SDL_GetError();
    const as_slice: [:0]const u8 = std.mem.span(err);
    return as_slice;
}


// pub fn log_last_error() void {
//     //  last error that occurred on the current thread.
//     std.log.debug("{s}\n", .{get_error()});
// }


/// https://wiki.libsdl.org/SDL2/SDL_SetError
pub fn set_error(err: string) void {
    const fmt: [*c]const u8 = "%s";
    _ = sys.SDL_SetError(fmt, err.ptr);
}

pub fn set_error_fromcode(err: ErrorCode) void {
    sys.SDL_Error(@enumToInt(err));
}

/// https://wiki.libsdl.org/SDL2/SDL_ClearError
pub fn clear_error() void {
    sys.SDL_ClearError();
}

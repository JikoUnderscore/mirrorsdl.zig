const std = @import("std");
const sys = @import("raw_sdl.zig").sys;
const image = @import("raw_sdl.zig").image;
const SDLError = @import("errors.zig").SDLError;


/// Destructor: `Sdl2ImageContext.deinit()`
/// 
pub fn init(flags: InitFlag) SDLError!Sdl2ImageContext {
    const init_flags = image.IMG_Init(flags);

    if ((init_flags & flags) != flags) {
        return SDLError.IMG_Init_Err;
    }

    return Sdl2ImageContext{};
}





pub const Sdl2ImageContext = struct {
    pub fn deinit(_: Sdl2ImageContext) void {
        image.IMG_Quit();
    }
};

pub const InitFlag = i32;
pub const InitFlags = struct {
    pub const JPG = image.IMG_INIT_JPG;  
    pub const PNG = image.IMG_INIT_PNG;
    pub const TIF = image.IMG_INIT_TIF;
    pub const WEBP = image.IMG_INIT_WEBP;
};
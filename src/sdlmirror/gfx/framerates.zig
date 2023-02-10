const std = @import("std");
const gfx = @import("./../raw_sdl.zig").gfx;
const Surface = @import("./../surface.zig").Surface;
const SDLError = @import("./../errors.zig").SDLError;



pub const FPSManager = struct {
    raw: *gfx.FPSmanager,

    pub fn ini() FPSManager {
        var raw: gfx.FPSmanager = undefined ;
        gfx.SDL_initFramerate(&raw);

        return FPSManager{
            .raw = raw,
        };
    }


    pub fn set_framerate(self: *FPSManager, rate: u32) SDLError!void {
        const ret = gfx.SDL_setFramerate(self.raw, rate);
        if (ret != 0) {
            return SDLError.SDL_setFramerate_Err;
        }
    }

    pub fn get_framerate(self: *const FPSManager) i32 {
        return gfx.SDL_getFramecount(self.raw);
    }

    pub fn get_frame_count(self: *const FPSManager) i32 {
        return gfx.SDL_getFramecount(self.raw);
    }

    pub fn delay(self: *FPSManager) u32 {
        return gfx.SDL_framerateDelay(self.raw);
    }


};

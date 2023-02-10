const sys = @import("./../raw_sdl.zig").sys;
const Surface = @import("./../surface.zig").Surface;
const SDLError = @import("./../errors.zig").SDLError;

pub const Cursor = struct {
    raw: *sys.SDL_Cursor,


    pub fn deinit(self: *const Cursor) void {
        sys.SDL_FreeCursor(self.raw);
    }

    /// Destructor: `Cursor.deinit()`
    /// 
    pub fn from_surface(surface: *const Surface, hot_x: i32, hot_y: i32) SDLError!Cursor {
        const raw = sys.SDL_CreateColorCursor(surface.raw, hot_x, hot_y);

        if (raw)|r| {
            return Cursor{
                .raw= r,
            };
        } else {
            return SDLError.SDL_CreateColorCursor_Err;
        }
    }

    pub fn set(self: *const Cursor) void {
        sys.SDL_SetCursor(self.raw);
    }
};
const sys = @import("raw_sdl.zig").sys;
const image = @import("raw_sdl.zig").image;
const pixels = @import("pixels.zig");
const RWops = @import("rwops.zig").RWops;
const cstr = @import("sdl.zig").cstr;
const SDLError = @import("errors.zig").SDLError;
const rotozoom = @import("gfx/rotozoom.zig");

/// https://wiki.libsdl.org/SDL2/SDL_Surface
pub const Surface = struct {
    pub usingnamespace rotozoom.IRotozoom;

    raw: *sys.SDL_Surface,

    /// Destructor: `Surface.deinit()`
    /// 
    pub fn init(width: u32, height: u32, format: pixels.PixelFormatEnum) SDLError!Surface {
        const masks = format.into_masks();
        return Surface.from_pixelMasks(width, height, masks);
    }

    /// https://wiki.libsdl.org/SDL2/SDL_FreeSurface
    pub fn deinit(self: *const Surface) void {
        sys.SDL_FreeSurface(self.raw);
    }

    /// Destructor: `Surface.deinit()`
    /// 
    pub fn from_pixelMasks(width: u32, height: u32, masks: pixels.PixelMasks) SDLError!Surface {
        if (width >= (1 << 31) or height >= (1 << 31)) {
            return SDLError.TooBig;
        } else {
            const raw = sys.SDL_CreateRGBSurface(0, @intCast(i32, width), @intCast(i32, height), @intCast(i32, masks.bpp), masks.rmask, masks.bmask, masks.amask);

            if (raw) |r| {
                return Surface.from(r);
            } else {
                return SDLError.SDL_CreateRGBSurface_Err;
            }
        }
    }
    
    /// Destructor: `Surface.deinit()`
    /// 
    pub fn load_bmp_rw(rwops: * RWops) SDLError!Surface {
        const raw = sys.SDL_LoadBMP_RW(rwops.raw, 0);

        if (raw)|r| {
            return Surface.from(r);
        } else {
            return SDLError.SDL_LoadBMP_RW_Err;
        }

    }

    /// Destructor: `Surface.deinit()`
    /// 
    pub fn load_bmp(path: cstr) SDLError!Surface {
        var file = try RWops.from_file(path, "rb");
        return Surface.load_bmp_rw(&file);
    }


    pub fn from(raw: *sys.SDL_Surface) Surface {
        return Surface{
            .raw = raw,
        };
    }

    /// Destructor: `Surface.deinit()`
    /// 
    pub fn from_file(filename: cstr) SDLError!Surface {
        const raw = image.IMG_Load(filename);

        if (raw)|r| {
            return Surface.from(r);
        } else {
            return SDLError.IMG_Load_Err;
        }
    
    }

};

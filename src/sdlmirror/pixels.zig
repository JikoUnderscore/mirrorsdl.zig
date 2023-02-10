const sys = @import("raw_sdl.zig").sys;
const SDLError = @import("errors.zig").SDLError;


/// https://wiki.libsdl.org/SDL2/SDL_PixelFormatEnum
pub const PixelFormatEnum = enum(i32) {
    Unknown = sys.SDL_PIXELFORMAT_UNKNOWN,
    Index1LSB = sys.SDL_PIXELFORMAT_INDEX1LSB,
    Index1MSB = sys.SDL_PIXELFORMAT_INDEX1MSB,
    Index4LSB = sys.SDL_PIXELFORMAT_INDEX4LSB,
    Index4MSB = sys.SDL_PIXELFORMAT_INDEX4MSB,
    Index8 = sys.SDL_PIXELFORMAT_INDEX8,
    RGB332 = sys.SDL_PIXELFORMAT_RGB332,
    RGB444 = sys.SDL_PIXELFORMAT_RGB444,
    RGB555 = sys.SDL_PIXELFORMAT_RGB555,
    BGR555 = sys.SDL_PIXELFORMAT_BGR555,
    ARGB4444 = sys.SDL_PIXELFORMAT_ARGB4444,
    RGBA4444 = sys.SDL_PIXELFORMAT_RGBA4444,
    ABGR4444 = sys.SDL_PIXELFORMAT_ABGR4444,
    BGRA4444 = sys.SDL_PIXELFORMAT_BGRA4444,
    ARGB1555 = sys.SDL_PIXELFORMAT_ARGB1555,
    RGBA5551 = sys.SDL_PIXELFORMAT_RGBA5551,
    ABGR1555 = sys.SDL_PIXELFORMAT_ABGR1555,
    BGRA5551 = sys.SDL_PIXELFORMAT_BGRA5551,
    RGB565 = sys.SDL_PIXELFORMAT_RGB565,
    BGR565 = sys.SDL_PIXELFORMAT_BGR565,
    RGB24 = sys.SDL_PIXELFORMAT_RGB24,
    BGR24 = sys.SDL_PIXELFORMAT_BGR24,
    RGB888 = sys.SDL_PIXELFORMAT_RGB888,
    RGBX8888 = sys.SDL_PIXELFORMAT_RGBX8888,
    BGR888 = sys.SDL_PIXELFORMAT_BGR888,
    BGRX8888 = sys.SDL_PIXELFORMAT_BGRX8888,
    ARGB8888 = sys.SDL_PIXELFORMAT_ARGB8888,
    RGBA8888 = sys.SDL_PIXELFORMAT_RGBA8888,
    ABGR8888 = sys.SDL_PIXELFORMAT_ABGR8888,
    BGRA8888 = sys.SDL_PIXELFORMAT_BGRA8888,
    ARGB2101010 = sys.SDL_PIXELFORMAT_ARGB2101010,
    YV12 = sys.SDL_PIXELFORMAT_YV12,
    IYUV = sys.SDL_PIXELFORMAT_IYUV,
    YUY2 = sys.SDL_PIXELFORMAT_YUY2,
    UYVY = sys.SDL_PIXELFORMAT_UYVY,
    YVYU = sys.SDL_PIXELFORMAT_YVYU,

    pub fn from(n: u32) PixelFormatEnum {
        return switch (n) {
            sys.SDL_PIXELFORMAT_UNKNOWN => .Unknown,
            sys.SDL_PIXELFORMAT_INDEX1LSB => .Index1LSB,
            sys.SDL_PIXELFORMAT_INDEX1MSB => .Index1MSB,
            sys.SDL_PIXELFORMAT_INDEX4LSB => .Index4LSB,
            sys.SDL_PIXELFORMAT_INDEX4MSB => .Index4MSB,
            sys.SDL_PIXELFORMAT_INDEX8 => .Index8,
            sys.SDL_PIXELFORMAT_RGB332 => .RGB332,
            sys.SDL_PIXELFORMAT_RGB444 => .RGB444,
            sys.SDL_PIXELFORMAT_RGB555 => .RGB555,
            sys.SDL_PIXELFORMAT_BGR555 => .BGR555,
            sys.SDL_PIXELFORMAT_ARGB4444 => .ARGB4444,
            sys.SDL_PIXELFORMAT_RGBA4444 => .RGBA4444,
            sys.SDL_PIXELFORMAT_ABGR4444 => .ABGR4444,
            sys.SDL_PIXELFORMAT_BGRA4444 => .BGRA4444,
            sys.SDL_PIXELFORMAT_ARGB1555 => .ARGB1555,
            sys.SDL_PIXELFORMAT_RGBA5551 => .RGBA5551,
            sys.SDL_PIXELFORMAT_ABGR1555 => .ABGR1555,
            sys.SDL_PIXELFORMAT_BGRA5551 => .BGRA5551,
            sys.SDL_PIXELFORMAT_RGB565 => .RGB565,
            sys.SDL_PIXELFORMAT_BGR565 => .BGR565,
            sys.SDL_PIXELFORMAT_RGB24 => .RGB24,
            sys.SDL_PIXELFORMAT_BGR24 => .BGR24,
            sys.SDL_PIXELFORMAT_RGB888 => .RGB888,
            sys.SDL_PIXELFORMAT_RGBX8888 => .RGBX8888,
            sys.SDL_PIXELFORMAT_BGR888 => .BGR888,
            sys.SDL_PIXELFORMAT_BGRX8888 => .BGRX8888,
            sys.SDL_PIXELFORMAT_ARGB8888 => .ARGB8888,
            sys.SDL_PIXELFORMAT_RGBA8888 => .RGBA8888,
            sys.SDL_PIXELFORMAT_ABGR8888 => .ABGR8888,
            sys.SDL_PIXELFORMAT_BGRA8888 => .BGRA8888,
            sys.SDL_PIXELFORMAT_ARGB2101010 => .ARGB2101010,
            sys.SDL_PIXELFORMAT_YV12 => .YV12,
            sys.SDL_PIXELFORMAT_IYUV => .IYUV,
            sys.SDL_PIXELFORMAT_YUY2 => .YUY2,
            sys.SDL_PIXELFORMAT_UYVY => .UYVY,
            sys.SDL_PIXELFORMAT_YVYU => .YVYU,
            else => @panic("Notfound"),
        };
    }

    pub fn into_masks(self: PixelFormatEnum) SDLError!PixelMasks {
        const format: u32 = @enumToInt(self);
        var bpp = 0;
        var rmask = 0;
        var gmask = 0;
        var bmask = 0;
        var amask = 0;

        const result = sys.SDL_PixelFormatEnumToMasks(
                format,
                &bpp,
                &rmask,
                &gmask,
                &bmask,
                &amask);

        if (result == sys.SDL_FALSE) {
            return SDLError.SDL_PixelFormatEnumToMasks_Err;
        } else {
            PixelMasks{
                .bpp= bpp,
                .rmask= rmask,
                .gmask= gmask,
                .bmask= bmask,
                .amask= amask,
            };
        }
    }

};


pub const Color = packed struct {
    r: u8,
    g: u8,
    b: u8,
    a: u8,

    pub fn from_raw(raw: sys.SDL_Color) Color {
        return Color{
            .r=raw.r,
            .g=raw.g,
            .b=raw.b,
            .a=raw.a,       
        };
    }

    pub fn into_raw(self: Color) sys.SDL_Color {
        return sys.SDL_Color{
            .r=self.r,
            .g=self.g,
            .b=self.b,
            .a=self.a,       
        };
    }

    pub fn from_tuple3(color: struct{u8,u8,u8}) Color {
        return Color{
            .r=color[0],
            .g=color[1],
            .b=color[2],
            .a=0xff,   
        };
    }

    pub fn from_tuple(color: struct{u8,u8,u8,u8}) Color {
        return Color{
            .r=color[0],
            .g=color[1],
            .b=color[2],
            .a=color[3],
        };
    }

    pub inline fn RGBA(r: u8,g: u8,b: u8,a: u8) Color {
        return Color{
            .r=r,
            .g=g,
            .b=b,
            .a=a,       
        };
    }

    pub inline fn RGB(r: u8,g: u8,b: u8) Color {
        return Color{
            .r=r,
            .g=g,
            .b=b,
            .a=0xff,       
        };
    }

};

pub const PixelMasks = struct  {
    bpp: u8,
    rmask: u32,
    gmask: u32,
    bmask: u32,
    amask: u32,
};
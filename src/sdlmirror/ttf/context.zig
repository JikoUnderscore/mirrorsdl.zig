pub usingnamespace @import("font.zig");

const ttf = @import("./../raw_sdl.zig").ttf;
const SDLError = @import("./../errors.zig").SDLError;
const string = @import("./../sdl.zig").string;
const RWops = @import("./../rwops.zig").RWops;
const font = @import("font.zig");

/// Destructor: `Sdl2TtfContext.deinit()`
/// 
pub fn init() SDLError!Sdl2TtfContext {
    if (ttf.TTF_WasInit() == 1) {
        return SDLError.AlreadyInitializedErr;
    } else if (ttf.TTF_Init() == 0) {
        return Sdl2TtfContext{};
    } else {
        return SDLError.InitializationErr;
    }
}

pub fn has_been_initialized() bool {
    return ttf.TTF_WasInit() == 1;
}

pub fn get_linked_version() struct{u8,u8,u8} {
    const raw = ttf.TTF_Linked_Version();
    return .{raw.major, raw.minor, raw.patch};
}

pub fn get_linked_version_raw() ttf.SDL_version{
    return ttf.TTF_Linked_Version();
}


pub const Sdl2TtfContext = struct {

    pub fn deinit(_: Sdl2TtfContext) void {
        ttf.TTF_Quit();
    }
    
    /// Destructor: `Font.deinit()`
    /// 
    pub fn load_font(_: Sdl2TtfContext, path: string, point_size: u16) SDLError!font.Font {
        return font.internal_load_font(path, point_size);
    }

    /// Destructor: `Font.deinit()`
    /// 
    pub fn load_font_at_index(_: Sdl2TtfContext, path: string, index: u32, point_size: u16) SDLError!font.Font {
        return font.internal_load_font_at_index(path, index, point_size);
    }

    /// Destructor: `Font.deinit()`
    /// 
    pub fn load_font_from_rwops(_: Sdl2TtfContext, rwops: RWops, index: u32, point_size: u16) SDLError!font.Font {
        const raw = ttf.TTF_OpenFontIndexRW(rwops.raw, 0, point_size, index);
        if (raw)|r| {
            return font.internal_load_font_from(r, rwops);
        } else {
            return SDLError.TTF_OpenFontIndexRW_Err;
        }
    }

    
};
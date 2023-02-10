const sys = @import("raw_sdl.zig").sys;
const cstr = @import("sdl.zig").cstr;
const SDLError = @import("errors.zig").SDLError;

pub const RWops = struct {
    raw: *sys.SDL_RWops,




    pub fn from(raw: *sys.SDL_RWops) RWops {
        return RWops{
            .raw= raw,
        };
    }

    pub fn from_file(path: cstr, mode: cstr) SDLError!RWops {
        const raw = sys.SDL_RWFromFile(path, mode);

        if (raw)|r| {
            return RWops{.raw=r};
        } else {
            return SDLError.SDL_RWFromFile_Err;
        }
    }

    pub fn from_bytes(buf: []const u8) SDLError!RWops {
        const raw = sys.SDL_RWFromConstMem(buf.len, buf.len);


        if (raw)|r| {
            return RWops{
                .raw=r,
            };
        } else {
            return SDLError.SDL_RWFromConstMem_Err;
        }
    }


    pub fn from_read() void {
        @panic("todo");
    }

    pub fn from_bytes_mut(buf: []u8) SDLError!RWops {
        const raw = sys.SDL_RWFromMem(buf.len, buf.len);

        if (raw) |r|{
            return RWops{
                .raw=r,
            };
        } else {
            return SDLError.SDL_RWFromMem_Err;
        }
    }

    pub fn len(self: *const RWops) ?usize {
        const result = self.raw.size.?;

        if (result == -1) {
            return null;
        } else {
            return @intCast(usize, result);
        }
    }

    pub fn is_empty(self: *const RWops) bool {
        if (self.len())|s| {
            return s == 0;
        } else {
            return true;
        }
    }
};
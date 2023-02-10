const std = @import("std");

const ttf = @import("./../raw_sdl.zig").ttf;
const sys = @import("./../raw_sdl.zig").sys;
const SDLError = @import("./../errors.zig").SDLError;
const string = @import("./../sdl.zig").string;
const Surface = @import("./../surface.zig").Surface;
const RWops = @import("./../rwops.zig").RWops;
const Color = @import("./../pixels.zig").Color;

const OwnedStr =  @import("./../sdl.zig").OwnedStr;


pub const FontStyles = i32; // usecase for @distinct(i32)
pub const  FontStyle = struct {
    pub const NORMAL: FontStyles        = ttf.TTF_STYLE_NORMAL;
    pub const BOLD: FontStyles          = ttf.TTF_STYLE_BOLD;
    pub const ITALIC: FontStyles        = ttf.TTF_STYLE_ITALIC;
    pub const UNDERLINE: FontStyles     = ttf.TTF_STYLE_UNDERLINE;
    pub const STRIKETHROUGH: FontStyles = ttf.TTF_STYLE_STRIKETHROUGH;
};




pub const Hinting = enum(i32){
    Normal = ttf.TTF_HINTING_NORMAL,
    Light = ttf.TTF_HINTING_LIGHT,
    Mono = ttf.TTF_HINTING_MONO,
    None = ttf.TTF_HINTING_NONE,
};

pub const GlyphMetrics = struct {
    minx: i32,
    maxx: i32,
    miny: i32,
    maxy: i32,
    advance: i32,
};




pub const RenderableText = union(enum) {
    Utf8: string,
    Latin1: string,
    Char: string,

    pub fn convert(self: *const RenderableText) string {
        return switch (self.*) {
            .Utf8 => |s| s,
            .Latin1 => |s| s,
            .Char => |s| s,
        };
    }
};

fn convert_to_surface(raw: ?*sys.SDL_Surface) SDLError!Surface {
    if (raw)|r| {
        return Surface.from(r);
    } else {
        return SDLError.TTF_Font_Surface_Err;
    }
}

pub const PartialRendering = struct {
    text: RenderableText,
    font: *const Font,

    /// Destructor: `Surface.deinit()`
    /// 
    pub fn solid(self: PartialRendering, color: struct{u8,u8,u8,u8}) SDLError!Surface {
        const source = self.text.convert();
        const colour = sys.SDL_Color{
                .r=color[0],
                .g=color[1],
                .b=color[2],
                .a=color[3],
            };
        const raw = switch (self.text) {
            .Utf8 => ttf.TTF_RenderUTF8_Solid(self.font.raw, source.ptr, colour),
            .Latin1 => ttf.TTF_RenderText_Solid(self.font.raw, source.ptr, colour),
            .Char => ttf.TTF_RenderUTF8_Solid(self.font.raw, source.ptr, colour),
        };

        return convert_to_surface(raw);
    }

    /// Destructor: `Surface.deinit()`
    /// 
    pub fn solid_raw(self: PartialRendering, colour: sys.SDL_Color) SDLError!Surface {
        const source =  self.text.convert();
        const raw = switch (self.text) {
            .Utf8 => ttf.TTF_RenderUTF8_Solid(self.font.raw, source.ptr, colour),
            .Latin1 => ttf.TTF_RenderText_Solid(self.font.raw, source.ptr, colour),
            .Char => ttf.TTF_RenderUTF8_Solid(self.font.raw, source.ptr, colour),
        };

        return convert_to_surface(raw);
    }

    /// Destructor: `Surface.deinit()`
    /// 
    pub fn solid_color(self: PartialRendering, color: Color) SDLError!Surface {
        const source =  self.text.convert();
        const colour = color.into_raw();
        const raw = switch (self.text) {
            .Utf8 => ttf.TTF_RenderUTF8_Solid(self.font.raw, source.ptr, colour),
            .Latin1 => ttf.TTF_RenderText_Solid(self.font.raw, source.ptr, colour),
            .Char => ttf.TTF_RenderUTF8_Solid(self.font.raw, source.ptr, colour),
        };

        return convert_to_surface(raw);
    }
    
    /// Destructor: `Surface.deinit()`
    /// 
    pub fn shaded(self: PartialRendering, color: struct{u8,u8,u8,u8}, background: struct{u8,u8,u8,u8}) SDLError!Surface {
        const source =  self.text.convert();
        const colour = sys.SDL_Color{
                .r=color[0],
                .g=color[1],
                .b=color[2],
                .a=color[3],
            };
        const bg = sys.SDL_Color{
                .r=background[0],
                .g=background[1],
                .b=background[2],
                .a=background[3],
            };

        const raw = switch (self.text) {
            .Utf8 => ttf.TTF_RenderUTF8_Shaded(self.font.raw, source.ptr, colour,bg),
            .Latin1 => ttf.TTF_RenderText_Shaded(self.font.raw, source.ptr, colour, bg),
            .Char => ttf.TTF_RenderUTF8_Shaded(self.font.raw, source.ptr, colour, bg),
        };

        return convert_to_surface(raw);
    }

    /// Destructor: `Surface.deinit()`
    /// 
    pub fn shaded_raw(self: PartialRendering, color: sys.SDL_Color, background: sys.SDL_Color) SDLError!Surface {
        const source =  self.text.convert();

        const raw = switch (self.text) {
            .Utf8 => ttf.TTF_RenderUTF8_Shaded(self.font.raw, source.ptr, color,background),
            .Latin1 => ttf.TTF_RenderText_Shaded(self.font.raw, source.ptr, color, background),
            .Char => ttf.TTF_RenderUTF8_Shaded(self.font.raw, source.ptr, color, background),
        };

        return convert_to_surface(raw);
    }

    /// Destructor: `Surface.deinit()`
    /// 
    pub fn shaded_color(self: PartialRendering, color: Color, background: Color) SDLError!Surface {
        const source =  self.text.convert();
        const colour = color.into_raw();
        const bg = background.into_raw();

        const raw = switch (self.text) {
            .Utf8 => ttf.TTF_RenderUTF8_Shaded(self.font.raw, source.ptr, colour,bg),
            .Latin1 => ttf.TTF_RenderText_Shaded(self.font.raw, source.ptr, colour, bg),
            .Char => ttf.TTF_RenderUTF8_Shaded(self.font.raw, source.ptr, colour, bg),
        };

        return convert_to_surface(raw);
    }

    /// Destructor: `Surface.deinit()`
    /// 
    pub fn blended(self: PartialRendering, color: struct{u8,u8,u8,u8}) SDLError!Surface {
        const source =  self.text.convert();
        const colour = sys.SDL_Color{
                .r=color[0],
                .g=color[1],
                .b=color[2],
                .a=color[3],
            };
        const raw = switch (self.text) {
            .Utf8 => ttf.TTF_RenderUTF8_Blended(self.font.raw, source.ptr, colour),
            .Latin1 => ttf.TTF_RenderText_Blended(self.font.raw, source.ptr, colour),
            .Char => ttf.TTF_RenderUTF8_Blended(self.font.raw, source.ptr, colour),
        };

        return convert_to_surface(raw);
    }

    /// Destructor: `Surface.deinit()`
    /// 
    pub fn blended_raw(self: PartialRendering, colour: sys.SDL_Color) SDLError!Surface {
        const source =  self.text.convert();
        const raw = switch (self.text) {
            .Utf8 => ttf.TTF_RenderUTF8_Blended(self.font.raw, source.ptr, colour),
            .Latin1 => ttf.TTF_RenderText_Blended(self.font.raw, source.ptr, colour),
            .Char => ttf.TTF_RenderUTF8_Blended(self.font.raw, source.ptr, colour),
        };

        return convert_to_surface(raw);
    }

    /// Destructor: `Surface.deinit()`
    /// 
    pub fn blended_color(self: PartialRendering, color: Color) SDLError!Surface {
        const source =  self.text.convert();
        const colour = color.into_raw();
        const raw = switch (self.text) {
            .Utf8 => ttf.TTF_RenderUTF8_Blended(self.font.raw, source.ptr, colour),
            .Latin1 => ttf.TTF_RenderText_Blended(self.font.raw, source.ptr, colour),
            .Char => ttf.TTF_RenderUTF8_Blended(self.font.raw, source.ptr, colour),
        };

        return convert_to_surface(raw);
    }

    
    /// Destructor: `Surface.deinit()`
    /// 
    pub fn blended_wrapped(self: PartialRendering, color: struct{u8,u8,u8,u8}, wrap_max_width: u32) SDLError!Surface {
        const source =  self.text.convert();
        const colour = sys.SDL_Color{
                .r=color[0],
                .g=color[1],
                .b=color[2],
                .a=color[3],
            };
        const raw = switch (self.text) {
            .Utf8 => ttf.TTF_RenderUTF8_Blended_Wrapped(self.font.raw, source.ptr, colour, wrap_max_width),
            .Latin1 => ttf.TTF_RenderText_Blended_Wrapped(self.font.raw, source.ptr, colour, wrap_max_width),
            .Char => ttf.TTF_RenderUTF8_Blended_Wrapped(self.font.raw, source.ptr, colour, wrap_max_width),
        };

        return convert_to_surface(raw);
    }
    
    /// Destructor: `Surface.deinit()`
    /// 
    pub fn blended_raw_wrapped(self: PartialRendering, colour: sys.SDL_Color, wrap_max_width: u32) SDLError!Surface {
        const source =  self.text.convert();
        const raw = switch (self.text) {
            .Utf8 => ttf.TTF_RenderUTF8_Blended_Wrapped(self.font.raw, source.ptr, colour, wrap_max_width),
            .Latin1 => ttf.TTF_RenderText_Blended_Wrapped(self.font.raw, source.ptr, colour, wrap_max_width),
            .Char => ttf.TTF_RenderUTF8_Blended_Wrapped(self.font.raw, source.ptr, colour, wrap_max_width),
        };

        return convert_to_surface(raw);
    }

    /// Destructor: `Surface.deinit()`
    /// 
    pub fn blended_color_wrapped(self: PartialRendering, color: Color, wrap_max_width: u32) SDLError!Surface {
        const source =  self.text.convert();
        const colour = color.into_raw();
        const raw = switch (self.text) {
            .Utf8 => ttf.TTF_RenderUTF8_Blended_Wrapped(self.font.raw, source.ptr, colour, wrap_max_width),
            .Latin1 => ttf.TTF_RenderText_Blended_Wrapped(self.font.raw, source.ptr, colour, wrap_max_width),
            .Char => ttf.TTF_RenderUTF8_Blended_Wrapped(self.font.raw, source.ptr, colour, wrap_max_width),
        };

        return convert_to_surface(raw);
    }

    
};

const chr = []const u8;

pub const Font = struct {
    raw: *ttf.TTF_Font,
    rwops: ?RWops,


    pub fn deinit(self: *const Font) void {
        if (ttf.TTF_WasInit() == 1) {
            ttf.TTF_CloseFont(self.raw);
        }
    }


    pub fn render(self: *const Font, text: string) PartialRendering {
        return PartialRendering{
            .text= RenderableText{.Utf8=text},
            .font= self,
        };
    }

    pub fn render_latin1(self: *const Font, text: string) PartialRendering {
        return PartialRendering{
            .text= RenderableText{.Latin1=text},
            .font= self,
        };
    }

    pub fn render_char(self: *const Font, text: chr) PartialRendering {
        return PartialRendering{
            .text= RenderableText{.Char=text},
            .font= self,
        };
    }

    pub fn size_of(self: *const Font, text: string) SDLError!struct{u32, u32} {
        var w: i32 = 0;
        var h: i32 = 0;
        const ret = ttf.TTF_SizeUTF8(self.raw, text.ptr, &w, &h);

        if (ret == 0) {
            return .{@intCast(u32, w), @intCast(u32, h)};
        } else {
            return SDLError.TTF_SizeUTF8_Err;
        }
    }

    pub fn size_of_latin1(self: *const Font, text: string) SDLError!struct{u32, u32} {
        var w: i32 = 0;
        var h: i32 = 0;
        const ret = ttf.TTF_SizeText(self.raw, text.ptr, &w, &h);

        if (ret == 0) {
            return .{@intCast(u32, w), @intCast(u32, h)};
        } else {
            return SDLError.TTF_SizeText_Err;
        }
    }

    pub fn size_of_char(self: *const Font, ch: chr) struct{u32, u32} {
        _ = self;
        _ = ch;
        @panic("todo");
    }

    pub fn get_style(self: *const Font) FontStyles {
        const raw = ttf.TTF_GetFontStyle(self.raw);

        return raw;
    }

    pub fn set_style(self: *const Font, styles: FontStyles) void {
        ttf.TTF_SetFontStyle(self.raw, styles);
    }

    pub fn get_outline_width(self: *const Font) u16 {
        ttf.TTF_GetFontOutline(self.raw);
    }

    pub fn set_outline_width(self: *Font, width: u16) void {
        ttf.TTF_SetFontOutline(self.raw, @intCast(i32, width));
    }

    pub fn get_hinting(self: *const Font) Hinting {
        return switch (ttf.TTF_GetFontHinting(self.raw)) {
            ttf.TTF_HINTING_NORMAL => Hinting.Normal,
            ttf.TTF_HINTING_LIGHT => Hinting.Light,
            ttf.TTF_HINTING_MONO => Hinting.Mono,
            ttf.TTF_HINTING_NONE  => Hinting.None,
            else  => Hinting.None,
        };
    }

    pub fn set_hinting(self: *Font, hinting: Hinting) void {
        ttf.TTF_SetFontHinting(self.raw, @enumToInt(hinting));
    }

   pub fn get_kerning(self: *const Font) bool {
        return ttf.TTF_GetFontKerning(self.raw) != 0;
    }

    pub fn set_kerning(self: *const Font, kerning: bool) void {
        ttf.TTF_SetFontKerning(self.raw, @boolToInt(kerning));
    }
    
    pub fn height(self: *const Font)  i32 {
        return ttf.TTF_FontHeight(self.raw);
    }

    pub fn ascent(self: *const Font) i32 {
        return ttf.TTF_FontAscent(self.raw);
    }

    pub fn descent(self: *const Font) i32 {
        return ttf.TTF_FontDescent(self.raw);
    }

    pub fn recommended_line_spacing(self: *const Font) i32 {
        return ttf.TTF_FontLineSkip(self.raw);
    }

    pub fn face_count(self: *const Font)  u16 {
        return @intCast(u16, ttf.TTF_FontFaces(self.raw));
    }

    pub fn face_is_fixed_width(self: *const Font) bool {
        return ttf.TTF_FontFaceIsFixedWidth(self.raw) != 0;
    }

    pub fn face_family_name(self: *const Font, allocator: std.mem.Allocator) ?OwnedStr {
        const cname = ttf.TTF_FontFaceFamilyName(self.raw);
        if (cname)|cn| {
            const as_slice: [:0]const u8 = std.mem.span(cn);
            return OwnedStr.fromOwnedSlice(allocator, as_slice);
        } else {
            return null;
        }
    }

    pub fn face_family_name_s(self: *const Font) ?string {
        const cname = ttf.TTF_FontFaceFamilyName(self.raw);
        if (cname)|cn| {
            const as_slice: [:0]const u8 = std.mem.span(cn);
            return as_slice;
        } else {
            return null;
        }
    }

    pub fn face_style_name(self: *const Font, allocator: std.mem.Allocator) ?OwnedStr  {
        const cname = ttf.TTF_FontFaceStyleName(self.raw);
        if (cname) |cn| {
            const as_slice: [:0]const u8 = std.mem.span(cn);
            return OwnedStr.fromOwnedSlice(allocator, as_slice);
        } else {
            return null;
        }
    }

    pub fn face_style_name_s(self: *const Font) ?OwnedStr  {
        const cname = ttf.TTF_FontFaceStyleName(self.raw);
        if (cname) |cn| {
            const as_slice: [:0]const u8 = std.mem.span(cn);
            return as_slice;
        } else {
            return null;
        }
    }

    pub fn find_glyph(self: *const Font, ch: u16) ?u16 {
        const ret = ttf.TTF_GlyphIsProvided(self.raw, ch);
        if (ret == 0) {
            return null;
        } else {
            return ret;
        }
    }

    pub fn find_glyph_metrics(self: *const Font, ch: u16) ?GlyphMetrics {
        const minx = 0;
        const maxx = 0;
        const miny = 0;
        const maxy = 0;
        const advance = 0;
        const ret = ttf.TTF_GlyphMetrics(
                self.raw,
                ch,
                &minx,
                &maxx,
                &miny,
                &maxy,
                &advance,
            );
        if (ret == 0) {
            return GlyphMetrics{
                .minx=minx,
                .maxx=maxx,
                .miny=miny,
                .maxy=maxy,
                .advance=advance,
            };
        } else {
            return null;
        }
    }


};




pub fn internal_load_font(path: string, ptsize: u16) SDLError!Font {
    const raw = ttf.TTF_OpenFont(path.ptr, @intCast(i32, ptsize));

    if (raw)|r| {
        return Font{
            .raw= r,
            .rwops= null,
        };
    } else {
        return SDLError.TTF_OpenFont_Err;
    }
}


pub fn internal_load_font_from(raw: *ttf.TTF_Font, rwops: ?RWops) Font {
    return Font{
        .raw=raw,
        .rwops=rwops,
    };
}


pub fn internal_load_font_at_index(path: string, index: u32, ptsize: u16) SDLError!Font {
    const raw = ttf.TTF_OpenFontIndex(path.ptr, @intCast(i32, ptsize), @intCast(c_long, index));
    
    if (raw)|r| {
        return Font{
            .raw = r,
            .rwops = null,
        };
    } else {
        return SDLError.TTF_OpenFontIndex_Err;
    }
}
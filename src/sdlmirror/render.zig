const sys = @import("raw_sdl.zig").sys;
const image = @import("raw_sdl.zig").image;

const std = @import("std");

const SDLError = @import("errors.zig").SDLError;

const get_error = @import("sdl.zig").get_error;
const string = @import("sdl.zig").string;
const cstr = @import("sdl.zig").cstr;
const OwnedStr = @import("sdl.zig").OwnedStr;

const Window = @import("videos.zig").Window;
const PixelFormatEnum = @import("pixels.zig").PixelFormatEnum;
const Rect = @import("rect.zig").Rect;
const Point = @import("rect.zig").Point;
const Surface = @import("surface.zig").Surface;
const Color = @import("pixels.zig").Color;
const IGFXRenderer = @import("gfx/primitives.zig").IGFXRenderer;

pub const CanvasBuilder = struct {
    window: Window,
    index: ?u32,
    renderer_flags: u32,

    pub fn init(window: Window) CanvasBuilder {
        return CanvasBuilder{ .window = window, .index = null, .renderer_flags = 0 };
    }

    /// Destructor: `WindowCanvas.deinit()`
    /// `WindowCanvas.deinit()` internaly in calls `RendererContext.deinit()`, `Window.deinit()` and `VideoSubsystem.deinit()`
    /// 
    /// https://wiki.libsdl.org/SDL2/SDL_CreateRenderer
    pub fn build(self: CanvasBuilder) SDLError!WindowCanvas {
        const index: c_int = if (self.index) |i| try validate_int(i)  else  -1 ;

        const raw = sys.SDL_CreateRenderer(self.window.raw, index, self.renderer_flags) orelse {
            return SDLError.SDL_CreateRendererErr;
        };

        const default_pixel_format = self.window.window_pixel_format();

        return WindowCanvas{
            .window = self.window,
            .render = RendererContext{ .raw = raw },
            .default_pixel_format_ = default_pixel_format,
        };
    }


    pub fn set_index(self: CanvasBuilder, index: u32) CanvasBuilder {
        var s = self;
        s.index = index;
        return s;
    }


    pub fn accelerated(self: CanvasBuilder) CanvasBuilder {
        var s = self;
        s.renderer_flags |= sys.SDL_RENDERER_ACCELERATED;
        return s;
    }

    pub fn software(self: CanvasBuilder) CanvasBuilder {
        var s = self;
        s.renderer_flags |= sys.SDL_RENDERER_SOFTWARE;
        return s;
    }

    pub fn present_vsync(self: CanvasBuilder) CanvasBuilder {
        var s = self;
        s.renderer_flags |= sys.SDL_RENDERER_PRESENTVSYNC;
        return s;
    }

    pub fn target_texture(self: CanvasBuilder) CanvasBuilder {
        var s = self;
        s.renderer_flags |= sys.SDL_RENDERER_TARGETTEXTURE;
        return s;
    }
};

/// https://wiki.libsdl.org/SDL2/SDL_Renderer
pub const RendererContext = struct {
    raw: *sys.SDL_Renderer,

    /// https://wiki.libsdl.org/SDL2/SDL_DestroyRenderer
    pub fn deinit(self: *RendererContext) void {
        sys.SDL_DestroyRenderer(self.raw);
    }

    pub fn from_raw(raw: *sys.SDL_Renderer) RendererContext {
        return RendererContext{
            .raw = raw,
        };
    }

    fn set_raw_target(self: *const RendererContext, raw_texture: ?*sys.SDL_Texture) SDLError!void {
        if (sys.SDL_SetRenderTarget(self.raw, raw_texture) != 0) {
            return SDLError.SDL_SetRenderTarget_Err;
        }
    }

    fn get_raw_target(self: *const RendererContext) ?*sys.SDL_Texture {
        return sys.SDL_GetRenderTarget(self.raw);
    }
};

pub const RenderFlags = enum(u32) {
    SOFTWARE = sys.SDL_RENDERER_SOFTWARE,
    ACCELERATED = sys.SDL_RENDERER_ACCELERATED,
    PRESENTVSYNC = sys.SDL_RENDERER_PRESENTVSYNC,
    TARGETTEXTURE = sys.SDL_RENDERER_TARGETTEXTURE,
};

pub const RendererInfo = struct {
    name: string,
    flags: u32,
    texture_formats: std.BoundedArray(PixelFormatEnum, 16),
    max_texture_width: u32,
    max_texture_height: u32,

    pub fn from_raw(info: *const sys.SDL_RendererInfo) RendererInfo {
        var tf = std.BoundedArray(PixelFormatEnum, 16).init(0) catch unreachable;

        for (info.texture_formats[0..info.num_texture_formats]) |n| {
            tf.append(PixelFormatEnum.from(n)) catch unreachable;
        }

        return RendererInfo{
            .name=std.mem.span(info.name),
            .flags= info.flags,
            .texture_formats=tf,
            .max_texture_width= @intCast(u32, info.max_texture_width),
            .max_texture_height= @intCast(u32, info.max_texture_height),
        };
    }

    pub fn get_active_flags(self: *const RendererInfo) struct{?RenderFlags,?RenderFlags,?RenderFlags,?RenderFlags} {
        var out: struct{?RenderFlags,?RenderFlags,?RenderFlags,?RenderFlags}  = .{null,null,null,null};

        if ((self.flags & sys.SDL_RENDERER_SOFTWARE) == sys.SDL_RENDERER_SOFTWARE) {
            out[3] = RenderFlags.SOFTWARE;
        }

        if ((self.flags & sys.SDL_RENDERER_ACCELERATED) == sys.SDL_RENDERER_ACCELERATED) {
            out[2] = RenderFlags.ACCELERATED;
        }

        if ((self.flags & sys.SDL_RENDERER_PRESENTVSYNC) == sys.SDL_RENDERER_PRESENTVSYNC) {
            out[1] = RenderFlags.PRESENTVSYNC;
        }

        if ((self.flags & sys.SDL_RENDERER_TARGETTEXTURE) == sys.SDL_RENDERER_TARGETTEXTURE) {
            out[0] = RenderFlags.TARGETTEXTURE;
        }

        return out;
    }

};


pub const WindowCanvas = struct {
    pub usingnamespace IRenderer;
    pub usingnamespace IRenderTarget;
    pub usingnamespace IGFXRenderer;

    window: Window,
    render: RendererContext,
    default_pixel_format_: PixelFormatEnum,


    pub fn deinit(self: *WindowCanvas) void {
        self.render.deinit();
        self.window.deinit();
    }

    pub fn default_pixel_format(self: *const WindowCanvas) PixelFormatEnum {
        return self.window.window_pixel_format();
    }

    pub fn texture_creator(self: *const WindowCanvas) TextureCreator {
        return TextureCreator{
            .default_pixel_format_= self.default_pixel_format(),
            .raw_renderer= self.render.raw,
        };
    }

    pub fn info(self: *const WindowCanvas) RendererInfo {
        var raw: sys.SDL_RendererInfo  = undefined;
        const res = sys.SDL_GetRendererInfo(self.render.raw, &raw);

        if (res == 0) {
            return RendererInfo.from_raw(&raw);
        } else {
            @panic(get_error());
        }
    }
};


pub const TextureCreator = struct {
    default_pixel_format_: PixelFormatEnum,
    raw_renderer: *sys.SDL_Renderer,

    /// Destructor: `Texture.deinit()`
    /// 
    pub fn load_texture(self: *const TextureCreator, filename: string) SDLError!Texture {
        const raw = image.IMG_LoadTexture(self.raw_renderer, filename.ptr);

        if (raw) |r| {
            return self.raw_create_texture(r);
        } else {
            return SDLError.IMG_LoadTexture_Err;
        }
    }

    /// Destructor: `Texture.deinit()`
    /// 
    pub fn raw_create_texture(_: *const TextureCreator, raw: *sys.SDL_Texture) Texture{
        return Texture{
            .raw= raw,
        };
    }

    /// Destructor: `Texture.deinit()`
    /// 
    pub fn create_texture(self: *const TextureCreator, format: ?PixelFormatEnum, access: TextureAccess, width: u32, height: u32) SDLError!Texture {
        const formatt = if (format)|f| f else self.default_pixel_format_;
        const result = try ll_create_texture(self.raw_renderer, formatt, access, width, height);

        if (result)|r| {
            return self.raw_create_texture(r);
        }    else {
            return SDLError.SDL_CreateTexture_Err;
        }
    }

    /// Destructor: `Texture.deinit()`
    /// 
    pub fn create_texture_static(self: *const TextureCreator, format: ?PixelFormatEnum,width: u32, height: u32) SDLError!Texture {
        return self.create_texture(format, TextureAccess.Static, width, height);
    }

    /// Destructor: `Texture.deinit()`
    /// 
    pub fn create_texture_streaming(self: *const TextureCreator, format: ?PixelFormatEnum,width: u32, height: u32) SDLError!Texture {
        return self.create_texture(format, TextureAccess.Streaming, width, height);
    }

    /// Destructor: `Texture.deinit()`
    /// 
    pub fn create_texture_target(self: *const TextureCreator, format: ?PixelFormatEnum,width: u32, height: u32) SDLError!Texture {
        return self.create_texture(format, TextureAccess.Target, width, height);
    }

    /// Destructor: `Texture.deinit()`
    /// 
    pub fn create_texture_from_surface(self: *const TextureCreator, surface: *const Surface) SDLError!Texture {
        const result = sys.SDL_CreateTextureFromSurface(self.raw_renderer, surface.raw);

        if (result)|r| {
            return self.raw_create_texture(r);
        } else {
            return SDLError.SDL_CreateTextureFromSurface_Err;
        }
        
    }

};


pub const BlendMode = enum(u32) {
    /// no blending (replace destination with source).
    None = sys.SDL_BLENDMODE_NONE,
    /// Alpha blending
    ///
    /// dstRGB = (srcRGB * srcA) + (dstRGB * (1-srcA))
    ///
    /// dstA = srcA + (dstA * (1-srcA))
    Blend = sys.SDL_BLENDMODE_BLEND,
    /// Additive blending
    ///
    /// dstRGB = (srcRGB * srcA) + dstRGB
    ///
    /// dstA = dstA (keep original alpha)
    Add = sys.SDL_BLENDMODE_ADD,
    /// Color modulate
    ///
    /// dstRGB = srcRGB * dstRGB
    Mod = sys.SDL_BLENDMODE_MOD,
    /// Color multiply
    Mul = sys.SDL_BLENDMODE_MUL,
    /// Invalid blending mode (indicates error)
    Invalid = sys.SDL_BLENDMODE_INVALID,


    pub fn from(n: i32) BlendMode {
        return switch (n) {
            sys.SDL_BLENDMODE_NONE => .None,
            sys.SDL_BLENDMODE_BLEND => .Blend,
            sys.SDL_BLENDMODE_ADD => .Add,
            sys.SDL_BLENDMODE_MOD => .Mod,
            sys.SDL_BLENDMODE_MUL => .Mul,
            sys.SDL_BLENDMODE_INVALID => .Invalid,
        };
    }
};


fn validate_int(value: u32) SDLError!c_int {
    if (value >= 1 << 31) {
        return SDLError.IntegerOverflows;
    } else {
        return @intCast(c_int, value);
    }
}


fn ll_create_texture(context: *sys.SDL_Renderer, pixel_format: PixelFormatEnum, access: TextureAccess, width: u32, height: u32) SDLError!?*sys.SDL_Texture {
    const w = try validate_int(width);
    const h = try validate_int(height);

    switch (pixel_format) {
        PixelFormatEnum.YV12, PixelFormatEnum.IYUV => {
            if (@rem(w , 2 ) != 0 or @rem(h , 2) != 0) {
                return SDLError.WidthMustBeMultipleOfTwoForFormat;
            }
        },
        else => {}
    }

    return sys.SDL_CreateTexture(context, @intCast(u32, @enumToInt(pixel_format)), @enumToInt(access), w,h );
}

const IRenderTarget  =struct {
    const Self = WindowCanvas;

    pub fn tender_target_supported(self: *const Self) bool {
        return sys.SDL_RenderTargetSupported(self.render.raw) == sys.SDL_TRUE;
    }


    pub fn with_texture_canvas(self: *Self,texture: *Texture, f: *const fn(wc: *WindowCanvas) void) SDLError!void {
        if (self.tender_target_supported()) {
            const target = self.render.get_raw_target();
            try self.render.set_raw_target(texture.raw);
            f(self);
            try self.render.set_raw_target(target);
        } else {
            return SDLError.SDL_RenderTargetSupported_Err;
        }
    }

    pub fn with_multiple_texture_canvas(self: *Self,comptime TSTRUCT: type , comptime T: type , textures: []TSTRUCT, f: *const fn(wc: *WindowCanvas, user_context: T) void) SDLError!void {
        if (self.tender_target_supported()) {
            const target = self.render.get_raw_target();
            for (textures) |*t| {
                try self.render.set_raw_target(t.*[0].raw);
                f(self, t.*[1]);
            }
            try self.render.set_raw_target(target);
        } else {
            return SDLError.SDL_RenderTargetSupported_Err;
        }
    }
};


const IRenderer = struct {
    const Self = WindowCanvas;

    pub fn set_draw_color_tuple(self: *Self, color: struct{u8,u8,u8,u8}) void {
        const ret = sys.SDL_SetRenderDrawColor(self.render.raw,color[0], color[1], color[2], color[3]);

        if (ret != 0) {
            @panic(get_error());
        }
    }

    pub fn set_draw_color(self: *Self, color: Color) void {
        const ret = sys.SDL_SetRenderDrawColor(self.render.raw,color.r, color.g, color.b, color.a);

        if (ret != 0) {
            @panic(get_error());
        }
    }

    pub fn draw_color(self: *const Self) struct{r:u8,g:u8,b:u8,a:u8} {
        var r = undefined;
        var g = undefined;
        var b = undefined;
        var a = undefined;

        const ret = sys.SDL_GetRenderDrawColor(self.remder.raw, &r, &g, &b, &a);

        if (ret != 0) {
            @panic(get_error());
        } else {
            return .{
                .r=r,
                .g=g,
                .b=b,
                .a=a,
            };
        }
    }

    pub fn set_blend_mode(self: *Self, blend: BlendMode) !void{
        const ret = sys.SDL_SetRenderDrawBlendMode(self.render.raw, @enumToInt(blend));

        if(ret != 0){
            return SDLError.SDL_SetRenderDrawBlendMode_Err;
        }
    }

    pub fn blend_mode(self: *const Self)BlendMode{
        var blend = undefined;
        const ret = sys.SDL_GetRenderDrawBlendMode(self.render.raw, &blend);

        if (ret != 0 ) {
            @panic(get_error());
        } else {
            return BlendMode.from(blend);
        }
    }

    pub fn clear(self: *Self) void {
        const ret = sys.SDL_RenderClear(self.render.raw);
        if (ret != 0) {
            @panic(get_error());
        }
    }

    pub fn clear_unchecked(self: *Self) void {
        _ = sys.SDL_RenderClear(self.render.raw);
    }

    pub fn present(self: *Self) void {
        sys.SDL_RenderPresent(self.render.raw);
    }

    pub fn output_size(self: *const Self) SDLError!struct{u32, u32} {
        var width = 0;
        var height = 0;

        const ret = sys.SDL_GetRendererOutputSize(self.render.raw, &width, &height);
        if (ret == 0) {
            return .{@intCast(u32, width), @intCast(u32, height)};
        } else {
            return SDLError.SDL_GetRendererOutputSizeErr;
        }
    }

    pub fn set_logical_size(self: *Self, width: u32, height: u32) SDLError!void {
        const w = try validate_int(width);
        const h = try validate_int(height);

        const ret = sys.SDL_RenderSetLogicalSize(self.render.raw, w, h);
        if (ret != 0) {
            return SDLError.SDL_RenderSetLogicalSizeErr;
        }
    }

    pub fn logical_size(self: *const Self) struct{u32, u32} {
        var width = 0;
        var height = 0;

        sys.SDL_RenderGetLogicalSize(self.remder.raw, &width, &height);
        
        return .{@intCast(u32, width),@intCast(u32, height)};
    }

    pub fn set_viewport(self: *Self, rect: ?Rect) void {
        const ret = sys.SDL_RenderSetViewport(self.render.raw, if (rect)|r| &r.raw else null );

        if (ret != 0) {
            @panic("Could not set viewport");
        }
    }

    pub fn viewport(self: *const Self) Rect {
        var rect = undefined;
        sys.SDL_RenderGetViewport(self.render.raw, &rect);
        return Rect.from(rect.*);
    }

    pub fn set_clip_rect(self: *Self, rect: ?Rect) void {
        const ptr = if (rect)|r| &r.raw else null;
        const ret = sys.SDL_RenderSetClipRect(self.render.raw, ptr);

        if (ret != 0) {
            @panic(get_error());
        }
    }

    pub fn clip_rect(self: *const Self) ?Rect {
        var raw = undefined;
        sys.SDL_RenderGetClipRect(self.render.raw, &raw);

        if (raw.w == 0 or raw.h == 0) {
            return null;
        } else {
            return Rect.from(raw);
        }
    }

    pub fn set_integer_scale(self: *Self, scale_: bool) SDLError!void {
        const ret = sys.SDL_RenderSetIntegerScale(self.render.raw, 
            if (scale_) sys.SDL_TRUE else sys.SDL_FALSE);
        if (ret != 0) {
            return SDLError.SDL_RenderSetIntegerScale_Err;
        }
    }

    pub fn integer_scale(self: *const Self) bool {
        return sys.SDL_RenderGetIntegerScale(self.render.raw) == sys.SDL_TRUE;
    }

    pub fn set_scale(self: *Self, scale_x: f32, scale_y: f32) SDLError!void {
        const ret = sys.SDL_RenderSetScale(self.render.raw, scale_x, scale_y);

        if (ret != 0) {
            return SDLError.SDL_RenderSetScale_Err;
        }
    }

    pub fn scale(self: *const Self) struct{f32, f32} {
        var scale_x = 0;
        var scale_y = 0;

        sys.SDL_RenderGetScale(self.render.raw, &scale_x, &scale_y);

        return . {scale_x, scale_y};
    }

    pub fn draw_point(self: *Self, point: Point) SDLError!void {
        const ret = sys.SDL_RenderDrawPoint(self.render.raw, point.x(), point.y());

        if (ret != 0) {
            return SDLError.SDL_RenderDrawPoint_Err;
        }
    }

    pub fn draw_point_unchecked(self: *Self, point: Point) void {
        _ = sys.SDL_RenderDrawPoint(self.render.raw, point.x(), point.y());
    }

    pub fn draw_tuple(self: *Self, point: struct {i32, i32}) SDLError!void {
        const ret = sys.SDL_RenderDrawPoint(self.render.raw, point[0], point[1]);

        if (ret != 0) {
            return SDLError.SDL_RenderDrawPoint_Err;
        }
    }

    pub fn draw_tuple_unchecked(self: *Self, point: struct {i32, i32}) void {
        _ = sys.SDL_RenderDrawPoint(self.render.raw, point[0], point[1]);
    }

    pub fn draw_points(self: *Self, points :[]const Point) SDLError!void {
        const ret = sys.SDL_RenderDrawPoints(self.render.raw, points.len, points.len);

        if (ret != 0) {
            return SDLError.SDL_RenderDrawPoints_Err;
        }
    }

    pub fn draw_points_unchecked(self: *Self, points :[]const Point) void {
        _ = sys.SDL_RenderDrawPoints(self.render.raw, points.len, points.len);
    }

    pub fn draw_line(self: *Self, start: Point, end: Point) SDLError!void {
        const ret = sys.SDL_RenderDrawLine(self.render.raw, start.x(), start.y(), end.x(), end.y());

        if (ret != 0) {
            return SDLError.SDL_RenderDrawLine_Err;
        }
    }

    pub fn draw_line_unchecked(self: *Self, start: Point, end: Point) void {
        _ = sys.SDL_RenderDrawLine(self.render.raw, start.x(), start.y(), end.x(), end.y());
    }

    pub fn draw_line_tuple_unchecked(self: *Self, start: struct {i32, i32}, end: struct {i32, i32}) void {
        _ = sys.SDL_RenderDrawLine(self.render.raw, start[0], start[1], end[0], end[1]);
    }

    pub fn draw_lines(self: *Self, points: []const Point) SDLError!void {
        const ret = sys.SDL_RenderDrawLines(self.render.raw, points.ptr, points.len);

        if (ret != 0) {
            return SDLError.SDL_RenderDrawLines_Err;
        }
    }

    pub fn draw_lines_unchecked(self: *Self, points: []const Point) void {
        _ = sys.SDL_RenderDrawLines(self.render.raw, points.ptr, points.len);
    }

    pub fn draw_rect(self: *Self, rect: Rect) SDLError!void {
        const ret = sys.SDL_RenderDrawRect(self.render.raw, &rect.raw);
        
        if (ret != 0) {
            return SDLError.SDL_RenderDrawRect_Err;
        }
    }

    pub fn draw_rect_unchecked(self: *Self, rect: Rect) void {
        _ = sys.SDL_RenderDrawRect(self.render.raw, &rect.raw);
    }

    pub fn draw_rects(self: *Self, rects: []const Rect) SDLError!void {
        const ret = sys.SDL_RenderDrawRects(self.render.raw, rects.ptr, rects.len);

        if (ret != 0) {
            return SDLError.SDL_RenderDrawRects_Err;
        }
    }

    pub fn draw_rects_unchecked(self: *Self, rects: []const Rect) void {
        _ = sys.SDL_RenderDrawRects(self.render.raw, rects.ptr, rects.len);
    }

    pub fn fill_rect(self: *Self, rect: ?Rect) SDLError!void {
        const ret = sys.SDL_RenderFillRect(self.render.raw, if (rect) |r| &r.raw else null);

        if (ret != 0) {
            return SDLError.SDL_RenderFillRect_Err;
        }
    }

    pub fn fill_rect_unchecked(self: *Self, rect: ?Rect) void {
     _ = sys.SDL_RenderFillRect(self.render.raw, if (rect) |r| &r.raw else null);
    }

    pub fn fill_rects(self: *Self, rects: []const Rect) SDLError!void {
        const ret = sys.SDL_RenderFillRects(self.render.raw, rects.ptr, rects.len);

        if (ret != 0) {
            return SDLError.SDL_RenderFillRects_Err;
        }
    }

    pub fn fill_rectst_unchecked(self: *Self, rects: []const Rect) void {
        _ = sys.SDL_RenderFillRects(self.render.raw, rects.ptr, rects.len);
    }

    pub fn copy(self: * Self, texture: *const Texture, src: ?Rect, dst: ?Rect) SDLError!void {
        const ret = sys.SDL_RenderCopy(
            self.render.raw,
            texture.raw,
            if (src) |r| &r.raw else null,
            if (dst) |r| &r.raw else null,
        );

        if (ret != 0) {
            return SDLError.SDL_RenderCopy_Err;
        }

    }

    pub fn copy_unchecked(self: * Self, texture: *const Texture, src: ?Rect, dst: ?Rect) void {
        _ = sys.SDL_RenderCopy(
            self.render.raw,
            texture.raw,
            if (src) |r| &r.raw else null,
            if (dst) |r| &r.raw else null,
        );
    }

    pub fn copy_ex(self: * Self, texture: *const Texture, src: ?Rect, dst: ?Rect, angle: f64, center: ?Point, flip_horizontal: bool, flip_vertical: bool) SDLError!void {
        const flip = fl: {
            if (flip_horizontal) {
                if (flip_vertical) {
                    break: fl sys.SDL_FLIP_HORIZONTAL | sys.SDL_FLIP_VERTICAL;

                } else {
                    break: fl sys.SDL_FLIP_HORIZONTAL;
                }
            } else {
                if (flip_vertical) {
                    break: fl sys.SDL_FLIP_VERTICAL;
                } else {
                    break: fl sys.SDL_FLIP_NONE;
                }
            }
            // switch (.{flip_horizontal, flip_vertical})
                // .{false, false} => sys.SDL_FLIP_NONE,
                // .{true, false} => sys.SDL_FLIP_HORIZONTAL,
                // .{false, true} => sys.SDL_FLIP_VERTICAL,
                // .{true, true} => sys.SDL_FLIP_HORIZONTAL | sys.SDL_FLIP_VERTICAL,
        };

        const ret = sys.SDL_RenderCopyEx(
            self.render.raw,
            texture.raw,
            if (src) |r| &r.raw else null,
            if (dst) |r| &r.raw else null,
            angle,
            if (center) |c| &c.raw else null,
            @intCast(u32, flip),
        );

        if (ret != 0) {
            return SDLError.SDL_RenderCopyEx_Err;
        }
    }

    pub fn copy_ex_unchecked(self: * Self, texture: *const Texture, src: ?Rect, dst: ?Rect, angle: f64, center: ?Point, flip_horizontal: bool, flip_vertical: bool) void {
        const flip = fl: {
            if (flip_horizontal) {
                if (flip_vertical) {
                    break: fl sys.SDL_FLIP_HORIZONTAL | sys.SDL_FLIP_VERTICAL;

                } else {
                    break: fl sys.SDL_FLIP_HORIZONTAL;
                }
            } else {
                if (flip_vertical) {
                    break: fl sys.SDL_FLIP_VERTICAL;
                } else {
                    break: fl sys.SDL_FLIP_NONE;
                }
            }
        };

        _ = sys.SDL_RenderCopyEx(
            self.render.raw,
            texture.raw,
            if (src) |r| &r.raw else null,
            if (dst) |r| &r.raw else null,
            angle,
            if (center) |c| &c.raw else null,
            @intCast(u32, flip),
        );
    }

    /// WARNING: This is a very slow operation, and should not be used frequently.
    pub fn read_pixels(self: *Self, rect: ?Rect, format: PixelFormatEnum) SDLError!OwnedStr {
        _ = self;
        _ = rect;
        _ = format;
        @panic("todo");
    }

    pub fn render_flush(self: *const Self) void {
        const ret = sys.SDL_RenderFlush(self.render.raw);

        if (ret != 0) {
            @panic(get_error());
        }
    }

    pub fn render_flush_unchecked(self: *const Self) void{
        _ = sys.SDL_RenderFlush(self.render.raw);
    }

};


pub const TextureAccess = enum(i32)  {
    Static = sys.SDL_TEXTUREACCESS_STATIC,
    Streaming = sys.SDL_TEXTUREACCESS_STREAMING,
    Target = sys.SDL_TEXTUREACCESS_TARGET,


    pub fn try_from(n: i32) ?TextureAccess {
        return switch (n) {
            sys.SDL_TEXTUREACCESS_STATIC => .Static,
            sys.SDL_TEXTUREACCESS_STREAMING => .Streaming,
            sys.SDL_TEXTUREACCESS_TARGET => .Target,
            else => null,
        };
    }

    pub fn from(n: i32) TextureAccess {
        return switch (n) {
            sys.SDL_TEXTUREACCESS_STATIC => .Static,
            sys.SDL_TEXTUREACCESS_STREAMING => .Streaming,
            sys.SDL_TEXTUREACCESS_TARGET => .Target,
            else => unreachable,
        };
    }
};



pub const  TextureQuery = struct {
    format: PixelFormatEnum,
    access: TextureAccess,
    width: u32,
    height: u32,
};

pub const Texture = struct {
    raw: *sys.SDL_Texture,


    pub fn query(self: *const Texture) TextureQuery {
        var format: u32 = 0;
        var access: i32 = 0;
        var width: i32 = 0;
        var height: i32 = 0;
        const ret = sys.SDL_QueryTexture(self.raw, &format, &access, &width, &height);

        if (ret != 0 ) {
            @panic(get_error());
        } else {
            return TextureQuery{
                .format=PixelFormatEnum.from(format),
                .access=TextureAccess.from(access),
                .width= @intCast(u32, width),
                .height=@intCast(u32, height),      
            };
        }
    }


    pub fn deinit(self: *const Texture) void {
        sys.SDL_DestroyTexture(self.raw);
    }
};
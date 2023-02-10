const std = @import("std");
const gfx = @import("./../raw_sdl.zig").gfx;
const render = @import("./../render.zig");
const string = @import("./../sdl.zig").string;
const pixels = @import("./../pixels.zig");
const SDLError = @import("./../errors.zig").SDLError;
const ziggfx = @import("./../gfx.zig/gfx_primitives.zig");

pub const IGFXRenderer = struct {
    const GFX_Self = render.WindowCanvas;

    pub fn pixel_color(self: *const GFX_Self, x: i16, y: i16, color: pixels.Color) SDLError!void {
        const ret = gfx.pixelRGBA(self.render.raw, x, y, color.r, color.g, color.b, color.a);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn pixel_tuple(self: *const GFX_Self, x: i16, y: i16, color: packed struct { u8, u8, u8, u8 }) SDLError!void {
        const ret = gfx.pixelRGBA(self.render.raw, x, y, color[0], color[1], color[2], color[3]);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn pixel_u32(self: *const GFX_Self, x: i16, y: i16, color: u32) SDLError!void {
        const ret = gfx.pixelColor(self.render.raw, x, y, color);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn pixel_color_unchecked(self: *const GFX_Self, x: i16, y: i16, color: pixels.Color) void {
        _ = gfx.pixelRGBA(self.render.raw, x, y, color.r, color.g, color.b, color.a);
    }
    pub fn pixel_tuple_unchecked(self: *const GFX_Self, x: i16, y: i16, color: packed struct { u8, u8, u8, u8 }) void {
        _ = gfx.pixelRGBA(self.render.raw, x, y, color[0], color[1], color[2], color[3]);
    }
    pub fn pixel_u32_unchecked(self: *const GFX_Self, x: i16, y: i16, color: u32) void {
        _ = gfx.pixelColor(self.render.raw, x, y, color);
    }



    pub fn hline_color(self: *const GFX_Self, x1: i16, x2: i16, y: i16, color: pixels.Color) SDLError!void {
        const ret = gfx.hlineRGBA(self.render.raw, x1, x2, y, color.r, color.g, color.b, color.a);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn hline_tuple(self: *const GFX_Self, x1: i16, x2: i16, y: i16, color: packed struct { u8, u8, u8, u8 }) SDLError!void {
        const ret = gfx.hlineRGBA(self.render.raw, x1, x2, y, color[0], color[1], color[2], color[3]);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn hline_u32(self: *const GFX_Self, x1: i16, x2: i16, y: i16, color: u32) SDLError!void {
        const ret = gfx.hlineColor(self.render.raw, x1, x2, y, color);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn hline_color_unchecked(self: *const GFX_Self, x1: i16, x2: i16, y: i16, color: pixels.Color) void {
        _ = gfx.hlineRGBA(self.render.raw, x1, x2, y, color.r, color.g, color.b, color.a);
    }
    pub fn hline_tuple_unchecked(self: *const GFX_Self, x1: i16, x2: i16, y: i16, color: packed struct { u8, u8, u8, u8 }) void {
        _ = gfx.hlineRGBA(self.render.raw, x1, x2, y, color[0], color[1], color[2], color[3]);
    }
    pub fn hline_u32_unchecked(self: *const GFX_Self, x1: i16, x2: i16, y: i16, color: u32) void {
        _ = gfx.hlineColor(self.render.raw, x1, x2, y, color);
    }


    pub fn vline_color(self: *const GFX_Self, x: i16, y1: i16, y2: i16, color: pixels.Color) SDLError!void {
        const ret = gfx.vlineRGBA(self.render.raw, x, y1, y2, color.r, color.g, color.b, color.a);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn vline_tuple(self: *const GFX_Self, x: i16, y1: i16, y2: i16, color: packed struct { u8, u8, u8, u8 }) SDLError!void {
        const ret = gfx.vlineRGBA(self.render.raw, x, y1, y2, color[0], color[1], color[2], color[3]);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn vline_u32(self: *const GFX_Self, x: i16, y1: i16, y2: i16, color: u32) SDLError!void {
        const ret = gfx.vlineColor(self.render.raw, x, y1, y2, color);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn vline_color_unchecked(self: *const GFX_Self, x: i16, y1: i16, y2: i16, color: pixels.Color) void {
        _ = gfx.vlineRGBA(self.render.raw, x, y1, y2, color.r, color.g, color.b, color.a);
    }
    pub fn vline_tuple_unchecked(self: *const GFX_Self, x: i16, y1: i16, y2: i16, color: packed struct { u8, u8, u8, u8 }) void {
        _ = gfx.vlineRGBA(self.render.raw, x, y1, y2, color[0], color[1], color[2], color[3]);
    }
    pub fn vline_u32_unchecked(self: *const GFX_Self, x: i16, y1: i16, y2: i16, color: u32) void {
        _ = gfx.vlineColor(self.render.raw, x, y1, y2, color);
    }


    pub fn rectangle_color(self: *const GFX_Self, x1: i16, y1: i16, x2: i16, y2: i16, color: pixels.Color) SDLError!void {
        const ret = gfx.rectangleRGBA(self.render.raw, x1, y1, x2, y2, color.r, color.g, color.b, color.a);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn rectangle_tuple(self: *const GFX_Self, x1: i16, y1: i16, x2: i16, y2: i16, color: packed struct { u8, u8, u8, u8 }) SDLError!void {
        const ret = gfx.rectangleRGBA(self.render.raw, x1, y1, x2, y2, color[0], color[1], color[2], color[3]);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn rectangle_u32(self: *const GFX_Self, x1: i16, y1: i16, x2: i16, y2: i16, color: u32) SDLError!void {
        const ret = gfx.rectangleColor(self.render.raw, x1, y1, x2, y2, color);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn rectangle_color_unchecked(self: *const GFX_Self, x1: i16, y1: i16, x2: i16, y2: i16, color: pixels.Color) void {
        _ = gfx.rectangleRGBA(self.render.raw, x1, y1, x2, y2, color.r, color.g, color.b, color.a);
    }
    pub fn rectangle_tuple_unchecked(self: *const GFX_Self, x1: i16, y1: i16, x2: i16, y2: i16, color: packed struct { u8, u8, u8, u8 }) void {
        _ = gfx.rectangleRGBA(self.render.raw, x1, y1, x2, y2, color[0], color[1], color[2], color[3]);
    }
    pub fn rectangle_u32_unchecked(self: *const GFX_Self, x1: i16, y1: i16, x2: i16, y2: i16, color: u32) void {
        _ = gfx.rectangleColor(self.render.raw, x1, y1, x2, y2, color);
    }


    pub fn rounded_rectangle_color(self: *const GFX_Self, x1: i16, y1: i16, x2: i16, y2: i16, rad: i16, color: pixels.Color) SDLError!void {
        const ret = gfx.roundedRectangleRGBA(self.render.raw, x1, y1, x2, y2, rad, color.r, color.g, color.b, color.a);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn rounded_rectangle_tuple(self: *const GFX_Self, x1: i16, y1: i16, x2: i16, y2: i16, rad: i16, color: packed struct { u8, u8, u8, u8 }) SDLError!void {
        const ret = gfx.roundedRectangleRGBA(self.render.raw, x1, y1, x2, y2, rad, color[0], color[1], color[2], color[3]);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn rounded_rectangle_u32(self: *const GFX_Self, x1: i16, y1: i16, x2: i16, y2: i16, rad: i16, color: u32) SDLError!void {
        const ret = gfx.roundedRectangleColor(self.render.raw, x1, y1, x2, y2, rad, color);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn rounded_rectangle_color_unchecked(self: *const GFX_Self, x1: i16, y1: i16, x2: i16, y2: i16, rad: i16, color: pixels.Color) void {
        _ = gfx.roundedRectangleRGBA(self.render.raw, x1, y1, x2, y2, rad, color.r, color.g, color.b, color.a);
    }
    pub fn rounded_rectangle_tuple_unchecked(self: *const GFX_Self, x1: i16, y1: i16, x2: i16, y2: i16, rad: i16, color: packed struct { u8, u8, u8, u8 }) void {
        _ = gfx.roundedRectangleRGBA(self.render.raw, x1, y1, x2, y2, rad, color[0], color[1], color[2], color[3]);
    }
    pub fn rounded_rectangle_u32_unchecked(self: *const GFX_Self, x1: i16, y1: i16, x2: i16, y2: i16, rad: i16, color: u32) void {
        _ = gfx.roundedRectangleColor(self.render.raw, x1, y1, x2, y2, rad, color);
    }


    pub fn box_color(self: *const GFX_Self, x1: i16, y1: i16, x2: i16, y2: i16, color: pixels.Color) SDLError!void {
        const ret = gfx.boxRGBA(self.render.raw, x1, y1, x2, y2, color.r, color.g, color.b, color.a);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn box_tuple(self: *const GFX_Self, x1: i16, y1: i16, x2: i16, y2: i16, color: packed struct { u8, u8, u8, u8 }) SDLError!void {
        const ret = gfx.boxRGBA(self.render.raw, x1, y1, x2, y2, color[0], color[1], color[2], color[3]);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn box_u32(self: *const GFX_Self, x1: i16, y1: i16, x2: i16, y2: i16, color: u32) SDLError!void {
        const ret = gfx.boxColor(self.render.raw, x1, y1, x2, y2, color);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn box_color_unchecked(self: *const GFX_Self, x1: i16, y1: i16, x2: i16, y2: i16, color: pixels.Color) void {
        _ = gfx.boxRGBA(self.render.raw, x1, y1, x2, y2, color.r, color.g, color.b, color.a);
    }
    pub fn box_tuple_unchecked(self: *const GFX_Self, x1: i16, y1: i16, x2: i16, y2: i16, color: packed struct { u8, u8, u8, u8 }) void {
        _ = gfx.boxRGBA(self.render.raw, x1, y1, x2, y2, color[0], color[1], color[2], color[3]);
    }
    pub fn box_u32_unchecked(self: *const GFX_Self, x1: i16, y1: i16, x2: i16, y2: i16, color: u32) void {
        _ = gfx.boxColor(self.render.raw, x1, y1, x2, y2, color);
    }


    pub fn rounded_box_color(self: *const GFX_Self, x1: i16, y1: i16, x2: i16, y2: i16, rad: i16, color: pixels.Color) SDLError!void {
        const ret = gfx.roundedBoxRGBA(self.render.raw, x1, y1, x2, y2, rad, color.r, color.g, color.b, color.a);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn rounded_box_tuple(self: *const GFX_Self, x1: i16, y1: i16, x2: i16, y2: i16, rad: i16, color: packed struct { u8, u8, u8, u8 }) SDLError!void {
        const ret = gfx.roundedBoxRGBA(self.render.raw, x1, y1, x2, y2, rad, color[0], color[1], color[2], color[3]);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn rounded_box_u32(self: *const GFX_Self, x1: i16, y1: i16, x2: i16, y2: i16, rad: i16, color: u32) SDLError!void {
        const ret = gfx.roundedBoxColor(self.render.raw, x1, y1, x2, y2, rad, color);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn rounded_box_color_unchecked(self: *const GFX_Self, x1: i16, y1: i16, x2: i16, y2: i16, rad: i16, color: pixels.Color) void {
        _ = gfx.roundedBoxRGBA(self.render.raw, x1, y1, x2, y2, rad, color.r, color.g, color.b, color.a);
    }
    pub fn rounded_box_tuple_unchecked(self: *const GFX_Self, x1: i16, y1: i16, x2: i16, y2: i16, rad: i16, color: packed struct { u8, u8, u8, u8 }) void {
        _ = gfx.roundedBoxRGBA(self.render.raw, x1, y1, x2, y2, rad, color[0], color[1], color[2], color[3]);
    }
    pub fn rounded_box_u32_unchecked(self: *const GFX_Self, x1: i16, y1: i16, x2: i16, y2: i16, rad: i16, color: u32) void {
        _ = gfx.roundedBoxColor(self.render.raw, x1, y1, x2, y2, rad, color);
    }


    pub fn line_color(self: *const GFX_Self, x1: i16, y1: i16, x2: i16, y2: i16, color: pixels.Color) SDLError!void {
        const ret = gfx.lineRGBA(self.render.raw, x1, y1, x2, y2, color.r, color.g, color.b, color.a);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn line_tuple(self: *const GFX_Self, x1: i16, y1: i16, x2: i16, y2: i16, color: packed struct { u8, u8, u8, u8 }) SDLError!void {
        const ret = gfx.lineRGBA(self.render.raw, x1, y1, x2, y2, color[0], color[1], color[2], color[3]);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn line_u32(self: *const GFX_Self, x1: i16, y1: i16, x2: i16, y2: i16, color: u32) SDLError!void {
        const ret = gfx.lineColor(self.render.raw, x1, y1, x2, y2, color);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn line_color_unchecked(self: *const GFX_Self, x1: i16, y1: i16, x2: i16, y2: i16, color: pixels.Color) void {
        _ = gfx.lineRGBA(self.render.raw, x1, y1, x2, y2, color.r, color.g, color.b, color.a);
    }
    pub fn line_tuple_unchecked(self: *const GFX_Self, x1: i16, y1: i16, x2: i16, y2: i16, color: packed struct { u8, u8, u8, u8 }) void {
        _ = gfx.lineRGBA(self.render.raw, x1, y1, x2, y2, color[0], color[1], color[2], color[3]);
    }
    pub fn line_u32_unchecked(self: *const GFX_Self, x1: i16, y1: i16, x2: i16, y2: i16, color: u32) void {
        _ = gfx.lineColor(self.render.raw, x1, y1, x2, y2, color);
    }


    pub fn aa_line_color(self: *const GFX_Self, x1: i16, y1: i16, x2: i16, y2: i16, color: pixels.Color) SDLError!void {
        const ret = gfx.aalineRGBA(self.render.raw, x1, y1, x2, y2, color.r, color.g, color.b, color.a);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn aa_line_tuple(self: *const GFX_Self, x1: i16, y1: i16, x2: i16, y2: i16, color: packed struct { u8, u8, u8, u8 }) SDLError!void {
        const ret = gfx.aalineRGBA(self.render.raw, x1, y1, x2, y2, color[0], color[1], color[2], color[3]);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn aa_line_u32(self: *const GFX_Self, x1: i16, y1: i16, x2: i16, y2: i16, color: u32) SDLError!void {
        const ret = gfx.aalineColor(self.render.raw, x1, y1, x2, y2, color);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn aa_line_color_unchecked(self: *const GFX_Self, x1: i16, y1: i16, x2: i16, y2: i16, color: pixels.Color) void {
        _ = gfx.aalineRGBA(self.render.raw, x1, y1, x2, y2, color.r, color.g, color.b, color.a);
    }
    pub fn aa_line_tuple_unchecked(self: *const GFX_Self, x1: i16, y1: i16, x2: i16, y2: i16, color: packed struct { u8, u8, u8, u8 }) void {
        _ = gfx.aalineRGBA(self.render.raw, x1, y1, x2, y2, color[0], color[1], color[2], color[3]);
    }
    pub fn aa_line_u32_unchecked(self: *const GFX_Self, x1: i16, y1: i16, x2: i16, y2: i16, color: u32) void {
        _ = gfx.aalineColor(self.render.raw, x1, y1, x2, y2, color);
    }


    pub fn thick_line_color(self: *const GFX_Self, x1: i16, y1: i16, x2: i16, y2: i16, width: u8, color: pixels.Color) SDLError!void {
        const ret = gfx.thickLineRGBA(self.render.raw, x1, y1, x2, y2, width, color.r, color.g, color.b, color.a);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn thick_line_tuple(self: *const GFX_Self, x1: i16, y1: i16, x2: i16, y2: i16, width: u8, color: packed struct { u8, u8, u8, u8 }) SDLError!void {
        const ret = gfx.thickLineRGBA(self.render.raw, x1, y1, x2, y2, width, color[0], color[1], color[2], color[3]);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn thick_line_u32(self: *const GFX_Self, x1: i16, y1: i16, x2: i16, y2: i16, width: u8, color: u32) SDLError!void {
        const ret = gfx.thickLineColor(self.render.raw, x1, y1, x2, y2, width, color);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn thick_line_color_unchecked(self: *const GFX_Self, x1: i16, y1: i16, x2: i16, y2: i16, width: u8, color: pixels.Color) void {
        _ = gfx.thickLineRGBA(self.render.raw, x1, y1, x2, y2, width, color.r, color.g, color.b, color.a);
    }
    pub fn thick_line_tuple_unchecked(self: *const GFX_Self, x1: i16, y1: i16, x2: i16, y2: i16, width: u8, color: packed struct { u8, u8, u8, u8 }) void {
        _ = gfx.thickLineRGBA(self.render.raw, x1, y1, x2, y2, width, color[0], color[1], color[2], color[3]);
    }
    pub fn thick_line_u32_unchecked(self: *const GFX_Self, x1: i16, y1: i16, x2: i16, y2: i16, width: u8, color: u32) void {
        _ = gfx.thickLineColor(self.render.raw, x1, y1, x2, y2, width, color);
    }


    pub fn circle_color(self: *const GFX_Self, x: i16, y: i16, rad: i16, color: pixels.Color) SDLError!void {
        const ret = gfx.circleRGBA(self.render.raw, x, y, rad, color.r, color.g, color.b, color.a);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn circle_tuple(self: *const GFX_Self, x: i16, y: i16, rad: i16, color: packed struct { u8, u8, u8, u8 }) SDLError!void {
        const ret = gfx.circleRGBA(self.render.raw, x, y, rad, color[0], color[1], color[2], color[3]);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn circle_u32(self: *const GFX_Self, x: i16, y: i16, rad: i16, color: u32) SDLError!void {
        const ret = gfx.circleColor(self.render.raw, x, y, rad, color);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn circle_color_unchecked(self: *const GFX_Self, x: i16, y: i16, rad: i16, color: pixels.Color) void {
        _ = gfx.circleRGBA(self.render.raw, x, y, rad, color.r, color.g, color.b, color.a);
    }
    pub fn circle_tuple_unchecked(self: *const GFX_Self, x: i16, y: i16, rad: i16, color: packed struct { u8, u8, u8, u8 }) void {
        _ = gfx.circleRGBA(self.render.raw, x, y, rad, color[0], color[1], color[2], color[3]);
    }
    pub fn circle_u32_unchecked(self: *const GFX_Self, x: i16, y: i16, rad: i16, color: u32) void {
        _ = gfx.circleColor(self.render.raw, x, y, rad, color);
    }


    pub fn aa_circle_color(self: *const GFX_Self, x: i16, y: i16, rad: i16, color: pixels.Color) SDLError!void {
        const ret = gfx.aacircleRGBA(self.render.raw, x, y, rad, color.r, color.g, color.b, color.a);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn aa_circle_tuple(self: *const GFX_Self, x: i16, y: i16, rad: i16, color: packed struct { u8, u8, u8, u8 }) SDLError!void {
        const ret = gfx.aacircleRGBA(self.render.raw, x, y, rad, color[0], color[1], color[2], color[3]);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn aa_circle_u32(self: *const GFX_Self, x: i16, y: i16, rad: i16, color: u32) SDLError!void {
        const ret = gfx.aacircleColor(self.render.raw, x, y, rad, color);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn aa_circle_color_unchecked(self: *const GFX_Self, x: i16, y: i16, rad: i16, color: pixels.Color) void {
        _ = gfx.aacircleRGBA(self.render.raw, x, y, rad, color.r, color.g, color.b, color.a);
    }
    pub fn aa_circle_tuple_unchecked(self: *const GFX_Self, x: i16, y: i16, rad: i16, color: packed struct { u8, u8, u8, u8 }) void {
        _ = gfx.aacircleRGBA(self.render.raw, x, y, rad, color[0], color[1], color[2], color[3]);
    }
    pub fn aa_circle_u32_unchecked(self: *const GFX_Self, x: i16, y: i16, rad: i16, color: u32) void {
        _ = gfx.aacircleColor(self.render.raw, x, y, rad, color);
    }



    pub fn filled_circle_color(self: *const GFX_Self, x: i16, y: i16, rad: i16, color: pixels.Color) SDLError!void {
        const ret = gfx.filledCircleRGBA(self.render.raw, x, y, rad, color.r, color.g, color.b, color.a);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn filled_circle_tuple(self: *const GFX_Self, x: i16, y: i16, rad: i16, color: packed struct { u8, u8, u8, u8 }) SDLError!void {
        const ret = gfx.filledCircleRGBA(self.render.raw, x, y, rad, color[0], color[1], color[2], color[3]);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn filled_circle_u32(self: *const GFX_Self, x: i16, y: i16, rad: i16, color: u32) SDLError!void {
        const ret = gfx.filledCircleColor(self.render.raw, x, y, rad, color);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn filled_circle_color_unchecked(self: *const GFX_Self, x: i16, y: i16, rad: i16, color: pixels.Color) void {
        _ = gfx.filledCircleRGBA(self.render.raw, x, y, rad, color.r, color.g, color.b, color.a);
    }
    pub fn filled_circle_tuple_unchecked(self: *const GFX_Self, x: i16, y: i16, rad: i16, color: packed struct { u8, u8, u8, u8 }) void {
        _ = gfx.filledCircleRGBA(self.render.raw, x, y, rad, color[0], color[1], color[2], color[3]);
    }
    pub fn filled_circle_u32_unchecked(self: *const GFX_Self, x: i16, y: i16, rad: i16, color: u32) void {
        _ = gfx.filledCircleColor(self.render.raw, x, y, rad, color);
    }


    pub fn arc_color(self: *const GFX_Self, x: i16, y: i16, rad: i16, start: i16, end: i16, color: pixels.Color) SDLError!void {
        const ret = gfx.arcRGBA(self.render.raw, x, y, rad, start, end, color.r, color.g, color.b, color.a);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn arc_tuple(self: *const GFX_Self, x: i16, y: i16, rad: i16, start: i16, end: i16, color: packed struct { u8, u8, u8, u8 }) SDLError!void {
        const ret = gfx.arcRGBA(self.render.raw, x, y, rad, start, end, color[0], color[1], color[2], color[3]);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn arc_u32(self: *const GFX_Self, x: i16, y: i16, rad: i16, start: i16, end: i16, color: u32) SDLError!void {
        const ret = gfx.arcColor(self.render.raw, x, y, rad, start, end, color);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn arc_color_unchecked(self: *const GFX_Self, x: i16, y: i16, rad: i16, start: i16, end: i16, color: pixels.Color) void {
        _ = gfx.arcRGBA(self.render.raw, x, y, rad, start, end, color.r, color.g, color.b, color.a);
    }
    pub fn arc_tuple_unchecked(self: *const GFX_Self, x: i16, y: i16, rad: i16, start: i16, end: i16, color: packed struct { u8, u8, u8, u8 }) void {
        _ = gfx.arcRGBA(self.render.raw, x, y, rad, start, end, color[0], color[1], color[2], color[3]);
    }
    pub fn arc_u32_unchecked(self: *const GFX_Self, x: i16, y: i16, rad: i16, start: i16, end: i16, color: u32) void {
        _ = gfx.arcColor(self.render.raw, x, y, rad, start, end, color);
    }


    pub fn ellipse_color(self: *const GFX_Self, x: i16, y: i16, rx: i16, ry: i16, color: pixels.Color) SDLError!void {
        const ret = gfx.ellipseRGBA(self.render.raw, x, y, rx, ry, color.r, color.g, color.b, color.a);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn ellipse_tuple(self: *const GFX_Self, x: i16, y: i16, rx: i16, ry: i16, color: packed struct { u8, u8, u8, u8 }) SDLError!void {
        const ret = gfx.ellipseRGBA(self.render.raw, x, y, rx, ry, color[0], color[1], color[2], color[3]);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn ellipse_u32(self: *const GFX_Self, x: i16, y: i16, rx: i16, ry: i16, color: u32) SDLError!void {
        const ret = gfx.ellipseColor(self.render.raw, x, y, rx, ry, color);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn ellipse_color_unchecked(self: *const GFX_Self, x: i16, y: i16, rx: i16, ry: i16, color: pixels.Color) void {
        _ = gfx.ellipseRGBA(self.render.raw, x, y, rx, ry, color.r, color.g, color.b, color.a);
    }
    pub fn ellipse_tuple_unchecked(self: *const GFX_Self, x: i16, y: i16, rx: i16, ry: i16, color: packed struct { u8, u8, u8, u8 }) void {
        _ = gfx.ellipseRGBA(self.render.raw, x, y, rx, ry, color[0], color[1], color[2], color[3]);
    }
    pub fn ellipse_u32_unchecked(self: *const GFX_Self, x: i16, y: i16, rx: i16, ry: i16, color: u32) void {
        _ = gfx.ellipseColor(self.render.raw, x, y, rx, ry, color);
    }



    pub fn aa_ellipse_color(self: *const GFX_Self, x: i16, y: i16, rx: i16, ry: i16, color: pixels.Color) SDLError!void {
        const ret = gfx.aaellipseRGBA(self.render.raw, x, y, rx, ry, color.r, color.g, color.b, color.a);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn aa_ellipse_tuple(self: *const GFX_Self, x: i16, y: i16, rx: i16, ry: i16, color: packed struct { u8, u8, u8, u8 }) SDLError!void {
        const ret = gfx.aaellipseRGBA(self.render.raw, x, y, rx, ry, color[0], color[1], color[2], color[3]);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn aa_ellipse_u32(self: *const GFX_Self, x: i16, y: i16, rx: i16, ry: i16, color: u32) SDLError!void {
        const ret = gfx.aaellipseColor(self.render.raw, x, y, rx, ry, color);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn aa_ellipse_color_unchecked(self: *const GFX_Self, x: i16, y: i16, rx: i16, ry: i16, color: pixels.Color) void {
        _ = gfx.aaellipseRGBA(self.render.raw, x, y, rx, ry, color.r, color.g, color.b, color.a);
    }
    pub fn aa_ellipse_tuple_unchecked(self: *const GFX_Self, x: i16, y: i16, rx: i16, ry: i16, color: packed struct { u8, u8, u8, u8 }) void {
        _ = gfx.aaellipseRGBA(self.render.raw, x, y, rx, ry, color[0], color[1], color[2], color[3]);
    }
    pub fn aa_ellipse_u32_unchecked(self: *const GFX_Self, x: i16, y: i16, rx: i16, ry: i16, color: u32) void {
        _ = gfx.aaellipseColor(self.render.raw, x, y, rx, ry, color);
    }


    pub fn filled_ellipse_color(self: *const GFX_Self, x: i16, y: i16, rx: i16, ry: i16, color: pixels.Color) SDLError!void {
        const ret = gfx.filledEllipseRGBA(self.render.raw, x, y, rx, ry, color.r, color.g, color.b, color.a);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn filled_ellipse_tuple(self: *const GFX_Self, x: i16, y: i16, rx: i16, ry: i16, color: packed struct { u8, u8, u8, u8 }) SDLError!void {
        const ret = gfx.filledEllipseRGBA(self.render.raw, x, y, rx, ry, color[0], color[1], color[2], color[3]);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn filled_ellipse_u32(self: *const GFX_Self, x: i16, y: i16, rx: i16, ry: i16, color: u32) SDLError!void {
        const ret = gfx.filledEllipseColor(self.render.raw, x, y, rx, ry, color);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn filled_ellipse_color_unchecked(self: *const GFX_Self, x: i16, y: i16, rx: i16, ry: i16, color: pixels.Color) void {
        _ = gfx.filledEllipseRGBA(self.render.raw, x, y, rx, ry, color.r, color.g, color.b, color.a);
    }
    pub fn filled_ellipse_tuple_unchecked(self: *const GFX_Self, x: i16, y: i16, rx: i16, ry: i16, color: packed struct { u8, u8, u8, u8 }) void {
        _ = gfx.filledEllipseRGBA(self.render.raw, x, y, rx, ry, color[0], color[1], color[2], color[3]);
    }
    pub fn filled_ellipse_u32_unchecked(self: *const GFX_Self, x: i16, y: i16, rx: i16, ry: i16, color: u32) void {
        _ = gfx.filledEllipseColor(self.render.raw, x, y, rx, ry, color);
    }


    pub fn pie_color(self: *const GFX_Self, x: i16, y: i16, rad: i16, start: i16, end: i16, color: pixels.Color) SDLError!void {
        const ret = gfx.pieRGBA(self.render.raw, x, y, rad, start, end, color.r, color.g, color.b, color.a);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn pie_tuple(self: *const GFX_Self, x: i16, y: i16, rad: i16, start: i16, end: i16, color: packed struct { u8, u8, u8, u8 }) SDLError!void {
        const ret = gfx.pieRGBA(self.render.raw, x, y, rad, start, end, color[0], color[1], color[2], color[3]);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn pie_u32(self: *const GFX_Self, x: i16, y: i16, rad: i16, start: i16, end: i16, color: u32) SDLError!void {
        const ret = gfx.pieColor(self.render.raw, x, y, rad, start, end, color);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn pie_color_unchecked(self: *const GFX_Self, x: i16, y: i16, rad: i16, start: i16, end: i16, color: pixels.Color) void {
        _ = gfx.pieRGBA(self.render.raw, x, y, rad, start, end, color.r, color.g, color.b, color.a);
    }
    pub fn pie_tuple_unchecked(self: *const GFX_Self, x: i16, y: i16, rad: i16, start: i16, end: i16, color: packed struct { u8, u8, u8, u8 }) void {
        _ = gfx.pieRGBA(self.render.raw, x, y, rad, start, end, color[0], color[1], color[2], color[3]);
    }
    pub fn pie_u32_unchecked(self: *const GFX_Self, x: i16, y: i16, rad: i16, start: i16, end: i16, color: u32) void {
        _ = gfx.pieColor(self.render.raw, x, y, rad, start, end, color);
    }


    pub fn filled_pie_color(self: *const GFX_Self, x: i16, y: i16, rad: i16, start: i16, end: i16, color: pixels.Color) SDLError!void {
        const ret = gfx.filledPieRGBA(self.render.raw, x, y, rad, start, end, color.r, color.g, color.b, color.a);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn filled_pie_tuple(self: *const GFX_Self, x: i16, y: i16, rad: i16, start: i16, end: i16, color: packed struct { u8, u8, u8, u8 }) SDLError!void {
        const ret = gfx.filledPieRGBA(self.render.raw, x, y, rad, start, end, color[0], color[1], color[2], color[3]);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn filled_pie_u32(self: *const GFX_Self, x: i16, y: i16, rad: i16, start: i16, end: i16, color: u32) SDLError!void {
        const ret = gfx.filledPieColor(self.render.raw, x, y, rad, start, end, color);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn filled_pie_color_unchecked(self: *const GFX_Self, x: i16, y: i16, rad: i16, start: i16, end: i16, color: pixels.Color) void {
        _ = gfx.filledPieRGBA(self.render.raw, x, y, rad, start, end, color.r, color.g, color.b, color.a);
    }
    pub fn filled_pie_tuple_unchecked(self: *const GFX_Self, x: i16, y: i16, rad: i16, start: i16, end: i16, color: packed struct { u8, u8, u8, u8 }) void {
        _ = gfx.filledPieRGBA(self.render.raw, x, y, rad, start, end, color[0], color[1], color[2], color[3]);
    }
    pub fn filled_pie_u32_unchecked(self: *const GFX_Self, x: i16, y: i16, rad: i16, start: i16, end: i16, color: u32) void {
        _ = gfx.filledPieColor(self.render.raw, x, y, rad, start, end, color);
    }



    pub fn trigon_color(self: *const GFX_Self, x1: i16, y1: i16, x2: i16, y2: i16, x3: i16, y3: i16, color: pixels.Color) SDLError!void {
        const ret = gfx.trigonRGBA(self.render.raw, x1, y1, x2, y2, x3, y3, color.r, color.g, color.b, color.a);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn trigon_tuple(self: *const GFX_Self, x1: i16, y1: i16, x2: i16, y2: i16, x3: i16, y3: i16, color: packed struct { u8, u8, u8, u8 }) SDLError!void {
        const ret = gfx.trigonRGBA(self.render.raw, x1, y1, x2, y2, x3, y3, color[0], color[1], color[2], color[3]);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn trigon_u32(self: *const GFX_Self, x1: i16, y1: i16, x2: i16, y2: i16, x3: i16, y3: i16, color: u32) SDLError!void {
        const ret = gfx.trigonColor(self.render.raw, x1, y1, x2, y2, x3, y3, color);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn trigon_color_unchecked(self: *const GFX_Self, x1: i16, y1: i16, x2: i16, y2: i16, x3: i16, y3: i16, color: pixels.Color) void {
        _ = gfx.trigonRGBA(self.render.raw, x1, y1, x2, y2, x3, y3, color.r, color.g, color.b, color.a);
    }
    pub fn trigon_tuple_unchecked(self: *const GFX_Self, x1: i16, y1: i16, x2: i16, y2: i16, x3: i16, y3: i16, color: packed struct { u8, u8, u8, u8 }) void {
        _ = gfx.trigonRGBA(self.render.raw, x1, y1, x2, y2, x3, y3, color[0], color[1], color[2], color[3]);
    }
    pub fn trigon_u32_unchecked(self: *const GFX_Self, x1: i16, y1: i16, x2: i16, y2: i16, x3: i16, y3: i16, color: u32) void {
        _ = gfx.trigonColor(self.render.raw, x1, y1, x2, y2, x3, y3, color);
    }



    pub fn aa_trigon_color(self: *const GFX_Self, x1: i16, y1: i16, x2: i16, y2: i16, x3: i16, y3: i16, color: pixels.Color) SDLError!void {
        const ret = gfx.aatrigonRGBA(self.render.raw, x1, y1, x2, y2, x3, y3, color.r, color.g, color.b, color.a);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn aa_trigon_tuple(self: *const GFX_Self, x1: i16, y1: i16, x2: i16, y2: i16, x3: i16, y3: i16, color: packed struct { u8, u8, u8, u8 }) SDLError!void {
        const ret = gfx.aatrigonRGBA(self.render.raw, x1, y1, x2, y2, x3, y3, color[0], color[1], color[2], color[3]);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn aa_trigon_u32(self: *const GFX_Self, x1: i16, y1: i16, x2: i16, y2: i16, x3: i16, y3: i16, color: u32) SDLError!void {
        const ret = gfx.aatrigonColor(self.render.raw, x1, y1, x2, y2, x3, y3, color);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn aa_trigon_color_unchecked(self: *const GFX_Self, x1: i16, y1: i16, x2: i16, y2: i16, x3: i16, y3: i16, color: pixels.Color) void {
        _ = gfx.aatrigonRGBA(self.render.raw, x1, y1, x2, y2, x3, y3, color.r, color.g, color.b, color.a);
    }
    pub fn aa_trigon_tuple_unchecked(self: *const GFX_Self, x1: i16, y1: i16, x2: i16, y2: i16, x3: i16, y3: i16, color: packed struct { u8, u8, u8, u8 }) void {
        _ = gfx.aatrigonRGBA(self.render.raw, x1, y1, x2, y2, x3, y3, color[0], color[1], color[2], color[3]);
    }
    pub fn aa_trigon_u32_unchecked(self: *const GFX_Self, x1: i16, y1: i16, x2: i16, y2: i16, x3: i16, y3: i16, color: u32) void {
        _ = gfx.aatrigonColor(self.render.raw, x1, y1, x2, y2, x3, y3, color);
    }


    pub fn filled_trigon_color(self: *const GFX_Self, x1: i16, y1: i16, x2: i16, y2: i16, x3: i16, y3: i16, color: pixels.Color) SDLError!void {
        const ret = gfx.filledTrigonRGBA(self.render.raw, x1, y1, x2, y2, x3, y3, color.r, color.g, color.b, color.a);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn filled_trigon_tuple(self: *const GFX_Self, x1: i16, y1: i16, x2: i16, y2: i16, x3: i16, y3: i16, color: packed struct { u8, u8, u8, u8 }) SDLError!void {
        const ret = gfx.filledTrigonRGBA(self.render.raw, x1, y1, x2, y2, x3, y3, color[0], color[1], color[2], color[3]);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn filled_trigon_u32(self: *const GFX_Self, x1: i16, y1: i16, x2: i16, y2: i16, x3: i16, y3: i16, color: u32) SDLError!void {
        const ret = gfx.filledTrigonColor(self.render.raw, x1, y1, x2, y2, x3, y3, color);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn filled_trigon_color_unchecked(self: *const GFX_Self, x1: i16, y1: i16, x2: i16, y2: i16, x3: i16, y3: i16, color: pixels.Color) void {
        _ = gfx.filledTrigonRGBA(self.render.raw, x1, y1, x2, y2, x3, y3, color.r, color.g, color.b, color.a);
    }
    pub fn filled_trigon_tuple_unchecked(self: *const GFX_Self, x1: i16, y1: i16, x2: i16, y2: i16, x3: i16, y3: i16, color: packed struct { u8, u8, u8, u8 }) void {
        _ = gfx.filledTrigonRGBA(self.render.raw, x1, y1, x2, y2, x3, y3, color[0], color[1], color[2], color[3]);
    }
    pub fn filled_trigon_u32_unchecked(self: *const GFX_Self, x1: i16, y1: i16, x2: i16, y2: i16, x3: i16, y3: i16, color: u32) void {
        _ = gfx.filledTrigonColor(self.render.raw, x1, y1, x2, y2, x3, y3, color);
    }



    pub fn polygon_color(self: *const GFX_Self, vx: []const i16, vy: []const i16, color: pixels.Color) SDLError!void {
        std.debug.assert(vx.len == vy.len);
        const ret = gfx.polygonRGBA(self.render.raw, vx.ptr, vy.ptr, vx.len, color.r, color.g, color.b, color.a);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn polygon_tuple(self: *const GFX_Self, vx: []const i16, vy: []const i16, color: packed struct { u8, u8, u8, u8 }) SDLError!void {
        std.debug.assert(vx.len == vy.len);
        const ret = gfx.polygonRGBA(self.render.raw, vx.ptr, vy.ptr, vx.len, color[0], color[1], color[2], color[3]);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn polygon_u32(self: *const GFX_Self, vx: []const i16, vy: []const i16, color: u32) SDLError!void {
        std.debug.assert(vx.len == vy.len);
        const ret = gfx.polygonColor(self.render.raw, vx.ptr, vy.ptr, vx.len, color);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn polygon_color_unchecked(self: *const GFX_Self,vx: []const i16, vy: []const i16, color: pixels.Color) void {
        std.debug.assert(vx.len == vy.len);
        _ = gfx.polygonRGBA(self.render.raw, vx, vy, vx.len, color.r, color.g, color.b, color.a);
    }
    pub fn polygon_tuple_unchecked(self: *const GFX_Self,vx: []const i16, vy: []const i16, color: packed struct { u8, u8, u8, u8 }) void {
        std.debug.assert(vx.len == vy.len);
        _ = gfx.polygonRGBA(self.render.raw, vx, vy, vx.len, color[0], color[1], color[2], color[3]);
    }
    pub fn polygon_u32_unchecked(self: *const GFX_Self,vx: []const i16, vy: []const i16, color: u32) void {
        std.debug.assert(vx.len == vy.len);
        _ = gfx.polygonColor(self.render.raw, vx, vy, vx.len, color);
    }



    pub fn aa_polygon_color(self: *const GFX_Self, vx: []const i16, vy: []const i16, color: pixels.Color) SDLError!void {
        std.debug.assert(vx.len == vy.len);
        const ret = gfx.aapolygonRGBA(self.render.raw, vx.ptr, vy.ptr, vx.len, color.r, color.g, color.b, color.a);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn aa_polygon_tuple(self: *const GFX_Self, vx: []const i16, vy: []const i16, color: packed struct { u8, u8, u8, u8 }) SDLError!void {
        std.debug.assert(vx.len == vy.len);
        const ret = gfx.aapolygonRGBA(self.render.raw, vx.ptr, vy.ptr, vx.len, color[0], color[1], color[2], color[3]);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn aa_polygon_u32(self: *const GFX_Self, vx: []const i16, vy: []const i16, color: u32) SDLError!void {
        std.debug.assert(vx.len == vy.len);
        const ret = gfx.aapolygonColor(self.render.raw, vx.ptr, vy.ptr, vx.len, color);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn aa_polygon_color_unchecked(self: *const GFX_Self,vx: []const i16, vy: []const i16, color: pixels.Color) void {
        std.debug.assert(vx.len == vy.len);
        _ = gfx.aapolygonRGBA(self.render.raw, vx, vy, vx.len, color.r, color.g, color.b, color.a);
    }
    pub fn aa_polygon_tuple_unchecked(self: *const GFX_Self,vx: []const i16, vy: []const i16, color: packed struct { u8, u8, u8, u8 }) void {
        std.debug.assert(vx.len == vy.len);
        _ = gfx.aapolygonRGBA(self.render.raw, vx, vy, vx.len, color[0], color[1], color[2], color[3]);
    }
    pub fn aa_polygon_u32_unchecked(self: *const GFX_Self,vx: []const i16, vy: []const i16, color: u32) void {
        std.debug.assert(vx.len == vy.len);
        _ = gfx.aapolygonColor(self.render.raw, vx, vy, vx.len, color);
    }



    pub fn filled_polygon_color(self: *const GFX_Self, vx: []const i16, vy: []const i16, color: pixels.Color) SDLError!void {
        std.debug.assert(vx.len == vy.len);
        const ret = gfx.filledPolygonRGBA(self.render.raw, vx.ptr, vy.ptr, vx.len, color.r, color.g, color.b, color.a);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn filled_polygon_tuple(self: *const GFX_Self, vx: []const i16, vy: []const i16, color: packed struct { u8, u8, u8, u8 }) SDLError!void {
        std.debug.assert(vx.len == vy.len);
        const ret = gfx.filledPolygonRGBA(self.render.raw, vx.ptr, vy.ptr, vx.len, color[0], color[1], color[2], color[3]);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn filled_polygon_u32(self: *const GFX_Self, vx: []const i16, vy: []const i16, color: u32) SDLError!void {
        std.debug.assert(vx.len == vy.len);
        const ret = gfx.filledPolygonColor(self.render.raw, vx.ptr, vy.ptr, vx.len, color);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn filled_polygon_color_unchecked(self: *const GFX_Self,vx: []const i16, vy: []const i16, color: pixels.Color) void {
        std.debug.assert(vx.len == vy.len);
        _ = gfx.filledPolygonRGBA(self.render.raw, vx.ptr, vy.ptr, vx.len, color.r, color.g, color.b, color.a);
    }
    pub fn filled_polygon_tuple_unchecked(self: *const GFX_Self,vx: []const i16, vy: []const i16, color: packed struct { u8, u8, u8, u8 }) void {
        std.debug.assert(vx.len == vy.len);
        _ = gfx.filledPolygonRGBA(self.render.raw, vx.ptr, vy.ptr, vx.len, color[0], color[1], color[2], color[3]);
    }
    pub fn filled_polygon_u32_unchecked(self: *const GFX_Self,vx: []const i16, vy: []const i16, color: u32) void {
        std.debug.assert(vx.len == vy.len);
        _ = gfx.filledPolygonColor(self.render.raw, vx.ptr, vy.ptr, vx.len, color);
    }


    fn textured_polygon(self: *const GFX_Self) !void {
        _ = self;
        @panic("todo");
        // gfx.texturedPolygon(renderer: ?*SDL_Renderer, vx: [*c]const Sint16, vy: [*c]const Sint16, n: c_int, texture: [*c]SDL_Surface, texture_dx: c_int, texture_dy: c_int)
    }



    pub fn bezier_polygon_color(self: *const GFX_Self, vx: []const i16, vy: []const i16, s:i32, color: pixels.Color) SDLError!void {
        std.debug.assert(vx.len == vy.len);
        const ret = gfx.bezierRGBA(self.render.raw, vx.ptr, vy.ptr, vx.len, s, color.r, color.g, color.b, color.a);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn bezier_polygon_tuple(self: *const GFX_Self, vx: []const i16, vy: []const i16, s:i32, color: packed struct { u8, u8, u8, u8 }) SDLError!void {
        std.debug.assert(vx.len == vy.len);
        const ret = gfx.bezierRGBA(self.render.raw, vx.ptr, vy.ptr, vx.len, s, color[0], color[1], color[2], color[3]);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn bezier_polygon_u32(self: *const GFX_Self, vx: []const i16, vy: []const i16, s:i32, color: u32) SDLError!void {
        std.debug.assert(vx.len == vy.len);
        const ret = gfx.bezierColor(self.render.raw, vx.ptr, vy.ptr, vx.len, s, color);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn bezier_polygon_color_unchecked(self: *const GFX_Self, vx: []const i16, vy: []const i16, s:i32, color: pixels.Color) void {
        std.debug.assert(vx.len == vy.len);
        _ = gfx.bezierRGBA(self.render.raw, vx.ptr, vy.ptr, vx.len, s, color.r, color.g, color.b, color.a);
    }
    pub fn bezier_polygon_tuple_unchecked(self: *const GFX_Self, vx: []const i16, vy: []const i16, s:i32, color: packed struct { u8, u8, u8, u8 }) void {
        std.debug.assert(vx.len == vy.len);
        _ = gfx.bezierRGBA(self.render.raw, vx.ptr, vy.ptr, vx.len, s, color[0], color[1], color[2], color[3]);
    }
    pub fn bezier_polygon_u32_unchecked(self: *const GFX_Self, vx: []const i16, vy: []const i16, s:i32, color: u32) void {
        std.debug.assert(vx.len == vy.len);
        _ = gfx.bezierColor(self.render.raw, vx.ptr, vy.ptr, vx.len, s, color);
    }



    pub fn character_polygon_color(self: *const GFX_Self, x: i16, y: i16, c: u8, color: pixels.Color) SDLError!void {
        const ret = gfx.characterRGBA(self.render.raw, x, y, c, color.r, color.g, color.b, color.a);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn character_polygon_tuple(self: *const GFX_Self, x: i16, y: i16, c: u8, color: packed struct { u8, u8, u8, u8 }) SDLError!void {
        const ret = gfx.characterRGBA(self.render.raw, x, y, c, color[0], color[1], color[2], color[3]);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn character_polygon_u32(self: *const GFX_Self, x: i16, y: i16, c: u8, color: u32) SDLError!void {
        const ret = gfx.characterColor(self.render.raw, x, y, c, color);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn character_polygon_color_unchecked(self: *const GFX_Self, x: i16, y: i16, c: u8, color: pixels.Color) void {
        _ = gfx.characterRGBA(self.render.raw, x, y, c, color.r, color.g, color.b, color.a);
    }
    pub fn character_polygon_tuple_unchecked(self: *const GFX_Self, x: i16, y: i16, c: u8, color: packed struct { u8, u8, u8, u8 }) void {
        _ = gfx.characterRGBA(self.render.raw, x, y, c, color[0], color[1], color[2], color[3]);
    }
    pub fn character_polygon_u32_unchecked(self: *const GFX_Self, x: i16, y: i16, c: u8, color: u32) void {
        _ = gfx.characterColor(self.render.raw, x, y, c, color);
    }


    pub fn string_polygon_color(self: *const GFX_Self, x: i16, y: i16, s: string, color: pixels.Color) SDLError!void {
        const ret = gfx.stringRGBA(self.render.raw, x, y, s.ptr, color.r, color.g, color.b, color.a);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn string_polygon_tuple(self: *const GFX_Self, x: i16, y: i16, s: string, color: packed struct { u8, u8, u8, u8 }) SDLError!void {
        const ret = gfx.stringRGBA(self.render.raw, x, y, s.ptr, color[0], color[1], color[2], color[3]);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn string_polygon_u32(self: *const GFX_Self, x: i16, y: i16, s: string, color: u32) SDLError!void {
        const ret = gfx.stringColor(self.render.raw, x, y, s.ptr, color);
        if (ret != 0) {
            return SDLError.GFX_Err;
        }
    }
    pub fn string_polygon_color_unchecked(self: *const GFX_Self, x: i16, y: i16, s: string, color: pixels.Color) void {
        _ = gfx.stringRGBA(self.render.raw, x, y, s.ptr, color.r, color.g, color.b, color.a);
    }
    pub fn string_polygon_tuple_unchecked(self: *const GFX_Self, x: i16, y: i16, s: string, color: packed struct { u8, u8, u8, u8 }) void {
        _ = gfx.stringRGBA(self.render.raw, x, y, s.ptr, color[0], color[1], color[2], color[3]);
    }
    pub fn string_polygon_u32_unchecked(self: *const GFX_Self, x: i16, y: i16, s: string, color: u32) void {
        _ = gfx.stringColor(self.render.raw, x, y, s.ptr, color);
    }
};


pub fn set_font(fontdata: ?[]const u8, cw: u32, ch: u32) void{
    gfx.gfxPrimitivesSetFont(if (fontdata)|fd| fd.ptr else null, cw, ch);
}

pub fn set_font_rotation(rotaion: u32) void {
    gfx.gfxPrimitivesSetFontRotation(rotaion);
}
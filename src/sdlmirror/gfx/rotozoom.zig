const std = @import("std");
const gfx = @import("./../raw_sdl.zig").gfx;
const Surface = @import("./../surface.zig").Surface;
const SDLError = @import("./../errors.zig").SDLError;


pub const IRotozoom = struct {
    const Self = Surface;


    /// Destructor: `Surface.deinit()`
    /// 
    pub fn rotozoom(self: *const Self, angle: f64, zoom_: f64,  smooth: bool) SDLError!Surface {
        const raw = gfx.rotozoomSurface(self.raw, angle, zoom_, smooth);

        if (raw)|r| {
            return Surface.from(r);
        } else {
            return SDLError.GFX_Err;
        }
    }

    /// Destructor: `Surface.deinit()`
    /// 
    pub fn rotozoom_xy(self: *const Self, angle: f64, zoomx: f64, zoomy: f64,  smooth: bool) SDLError!Surface {
        const raw = gfx.rotozoomSurfaceXY(self.raw, angle, zoomx, zoomy, smooth);

        if (raw)|r| {
            return Surface.from(r);
        } else {
            return SDLError.GFX_Err;
        }
    }

    /// Destructor: `Surface.deinit()`
    /// 
    pub fn zoom(self: *const Self, zoomx: f64, zoomy: f64,  smooth: bool) SDLError!Surface {
        const raw = gfx.zoomSurface(self.raw, zoomx, zoomy, smooth);

        if (raw)|r| {
            return Surface.from(r);
        } else {
            return SDLError.GFX_Err;
        }
    }


    /// Destructor: `Surface.deinit()`
    /// 
    pub fn shrink(self: *const Self, factorx: i32, factory: i32) SDLError!Surface {
        const raw = gfx.shrinkSurface(self.raw, factorx, factory);

        if (raw)|r| {
            return Surface.from(r);
        } else {
            return SDLError.GFX_Err;
        }
    }


    /// Destructor: `Surface.deinit()`
    /// 
    pub fn rotate_90deg(self: *const Self, turns: i32) SDLError!Surface {
        const raw = gfx.rotateSurface90Degrees(self.raw, turns);

        if (raw)|r| {
            return Surface.from(r);
        } else {
            return SDLError.GFX_Err;
        }
    }
};


pub fn get_zoom_size(width: i32, height: i32, zoomx: f64, zoomy: f64) struct {i32, i32} {
    var w = 0;
    var h = 0;

    gfx.zoomSurfaceSize(width, height, zoomx, zoomy, &w, &h );

    return .{w, h};
}


pub fn get_rotozoom_size(width: i32, height: i32, angle: f64, zoom: f64) struct {i32, i32} {
    var w = 0;
    var h = 0;

    gfx.rotozoomSurfaceSize(width, height, angle, zoom, &w, &h );

    return .{w, h};
}


pub fn get_zoom_xy_size(width: i32, height: i32, angle: f64, zoomx: f64, zoomy: f64) struct {i32, i32} {
    var w = 0;
    var h = 0;

    gfx.rotozoomSurfaceSizeXY(width, height, angle, zoomx, zoomy, &w, &h );

    return .{w, h};
}
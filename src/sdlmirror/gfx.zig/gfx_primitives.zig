const sys = @import("./../raw_sdl.zig").sys;
const std = @import("std");


pub fn pixelColor(renderer: *sys.SDL_Renderer, x: i16, y: i16, color: u32) i32 {
    const c = @bitCast([4]u8, color);
    return pixelRGBA(renderer, x, y, c[0], c[1], c[2], c[3]);
}
pub fn pixelRGBA(renderer: *sys.SDL_Renderer, x: i16, y: i16, r: u8, g: u8, b: u8, a: u8) i32 {
    var result: i32 = 0;
    result |= sys.SDL_SetRenderDrawBlendMode(renderer, if (a == 255) sys.SDL_BLENDMODE_NONE else sys.SDL_BLENDMODE_BLEND);
    result |= sys.SDL_SetRenderDrawColor(renderer, r,g,b,a);
    result |= sys.SDL_RenderDrawPoint(renderer, x, y);
    return result;
}



pub fn hlineColor(renderer: *sys. SDL_Renderer,  x1: i16,  x2: i16,  y: i16, color: u32) i32 {
    const c = @bitCast([4]u8, color);
    return hlineRGBA(renderer, x1, x2, y, c[0], c[1], c[2], c[3]);
}
pub fn hlineRGBA(renderer: *sys.SDL_Renderer,  x1: i16,  x2: i16,  y: i16,  r: u8,  g: u8,  b: u8,  a: u8) i32 {
	var result: i32 = 0;
	result |= sys.SDL_SetRenderDrawBlendMode(renderer, if (a == 255)  sys.SDL_BLENDMODE_NONE else sys.SDL_BLENDMODE_BLEND);
	result |= sys.SDL_SetRenderDrawColor(renderer, r, g, b, a);
	result |= sys.SDL_RenderDrawLine(renderer, x1, y, x2, y);
	return result;
}



pub fn vlineColor(renderer: *sys.SDL_Renderer,  x: i16,  y1: i16,  y2: i16, color: u32) i32 {
    const c = @bitCast([4]u8, color);
    return vlineRGBA(renderer, x, y1, y2, c[0], c[1], c[2], c[3]);
}
pub fn vlineRGBA(renderer: *sys.SDL_Renderer,  x: i16,  y1: i16,  y2: i16,  r: u8,  g: u8,  b: u8,  a: u8) i32 {
	var result: i32 = 0;
	result |= sys.SDL_SetRenderDrawBlendMode(renderer, if (a == 255)  sys.SDL_BLENDMODE_NONE else sys.SDL_BLENDMODE_BLEND);
	result |= sys.SDL_SetRenderDrawColor(renderer, r, g, b, a);
	result |= sys.SDL_RenderDrawLine(renderer, x, y1, x, y2);
	return result;
}



pub fn rectangleColor(renderer: *sys.SDL_Renderer,  x1: i16,  y1: i16,  x2: i16,  y2: i16, color: u32) i32 {
    const c = @bitCast([4]u8, color);
	return rectangleRGBA(renderer, x1, y1, x2, y2, c[0], c[1], c[2], c[3]);
}
pub fn rectangleRGBA(renderer: *sys.SDL_Renderer,  x1_: i16,  y1_: i16,  x2_: i16,  y2_: i16,  r: u8,  g: u8,  b: u8,  a: u8) i32 {
    var x1 = x1_ ;
    var x2 = x2_ ;
    var y1 = y1_ ;
    var y2 = y2_ ;
	//Test for special cases of straight lines or single point 
	if (x1 == x2) {
		if (y1 == y2) {
			return (pixelRGBA(renderer, x1, y1, r, g, b, a));
		} else {
			return (vlineRGBA(renderer, x1, y1, y2, r, g, b, a));
		}
	} else {
		if (y1 == y2) {
			return (hlineRGBA(renderer, x1, x2, y1, r, g, b, a));
		}
	}

	//Swap x1, x2 if required 
	var tmp: i16 = undefined;

	if (x1 > x2) {
		tmp = x1;
		x1 = x2;
		x2 = tmp;
	}

	//Swap y1, y2 if required 
	if (y1 > y2) {
		tmp = y1;
		y1 = y2;
		y2 = tmp;
	}

	//Create destination rect
	const rect = sys.SDL_Rect{
        .x = x1,
        .y = y1,
        .w = x2 - x1,
        .h = y2 - y1,
    };
    
	//Draw
	var result: i32 = 0;
	result |= sys.SDL_SetRenderDrawBlendMode(renderer, if (a == 255)  sys.SDL_BLENDMODE_NONE else sys.SDL_BLENDMODE_BLEND);
	result |= sys.SDL_SetRenderDrawColor(renderer, r, g, b, a);	
	result |= sys.SDL_RenderDrawRect(renderer, &rect);
	return result;
}


pub fn roundedRectangleColor(renderer: *sys.SDL_Renderer,  x1: i16,  y1: i16,  x2: i16,  y2: i16,  rad: i16, color: u32) i32 {
    const c = @bitCast([4]u8, color);
	return roundedRectangleRGBA(renderer, x1, y1, x2, y2, rad, c[0], c[1], c[2], c[3]);
}
pub fn roundedRectangleRGBA(renderer: *sys.SDL_Renderer,  x1_: i16,  y1_: i16,  x2_: i16,  y2_: i16,  rad_: i16,  r: u8,  g: u8,  b: u8,  a: u8) i32 {
    var x1 = x1_ ;
    var x2 = x2_ ;
    var y1 = y1_ ;
    var y2 = y2_ ;
    var rad = rad_ ;
	//Check renderer
	// if (renderer == null)
	// {
		// return -1;
	// }

	//Check radius vor valid range
	if (rad < 0) {
		return -1;
	}

	//Special case - no rounding
	if (rad <= 1) {
		return rectangleRGBA(renderer, x1, y1, x2, y2, r, g, b, a);
	}

	//Test for special cases of straight lines or single point 
	if (x1 == x2) {
		if (y1 == y2) {
			return (pixelRGBA(renderer, x1, y1, r, g, b, a));
		} else {
			return (vlineRGBA(renderer, x1, y1, y2, r, g, b, a));
		}
	} else {
		if (y1 == y2) {
			return (hlineRGBA(renderer, x1, x2, y1, r, g, b, a));
		}
	}

	//Swap x1, x2 if required 
	var tmp: i16 = undefined;
	if (x1 > x2) {
		tmp = x1;
		x1 = x2;
		x2 = tmp;
	}

	//Swap y1, y2 if required 
	if (y1 > y2) {
		tmp = y1;
		y1 = y2;
		y2 = tmp;
	}

	//Calculate width&height 
	const w: i16 = x2 - x1;
	const h: i16 = y2 - y1;

	//Maybe adjust radius
	if ((rad * 2) > w)  
	{
		rad = @divTrunc(w , 2);
	}
	if ((rad * 2) > h)
	{
		rad = @divTrunc(h , 2);
	}

	//Draw corners
	const xx1: i16 = x1 + rad;
	const xx2: i16 = x2 - rad;
	const yy1: i16 = y1 + rad;
	const yy2: i16 = y2 - rad;

	var result: i32 = 0;
	result |= arcRGBA(renderer, xx1, yy1, rad, 180, 270, r, g, b, a);
	result |= arcRGBA(renderer, xx2, yy1, rad, 270, 360, r, g, b, a);
	result |= arcRGBA(renderer, xx1, yy2, rad,  90, 180, r, g, b, a);
	result |= arcRGBA(renderer, xx2, yy2, rad,   0,  90, r, g, b, a);

	//Draw lines
	if (xx1 <= xx2) {
		result |= hlineRGBA(renderer, xx1, xx2, y1, r, g, b, a);
		result |= hlineRGBA(renderer, xx1, xx2, y2, r, g, b, a);
	}
	if (yy1 <= yy2) {
		result |= vlineRGBA(renderer, x1, yy1, yy2, r, g, b, a);
		result |= vlineRGBA(renderer, x2, yy1, yy2, r, g, b, a);
	}

	return result;
}


pub fn boxColor(renderer: *sys.SDL_Renderer,  x1: i16,  y1: i16,  x2: i16,  y2: i16,  color: u32) i32 {
    const c = @bitCast([4]u8, color);
    return boxRGBA(renderer, x1, y1, x2, y2, c[0], c[1], c[2], c[3]);
}
pub fn boxRGBA(renderer: *sys.SDL_Renderer,  x1_: i16,  y1_: i16,  x2_: i16,  y2_: i16,  r:u8,  g:u8,  b:u8,  a:u8) i32 {
    var x1 = x1_;
    var x2 = x2_;
    var y1 = y1_;
    var y2 = y2_;

	//Test for special cases of straight lines or single point 
	if (x1 == x2) {
		if (y1 == y2) {
			return (pixelRGBA(renderer, x1, y1, r, g, b, a));
		} else {
			return (vlineRGBA(renderer, x1, y1, y2, r, g, b, a));
		}
	} else {
		if (y1 == y2) {
			return (hlineRGBA(renderer, x1, x2, y1, r, g, b, a));
		}
	}

	//Swap x1, x2 if required 
	var tmp: i16 = undefined;
	if (x1 > x2) {
		tmp = x1;
		x1 = x2;
		x2 = tmp;
	}

	//Swap y1, y2 if required 
	if (y1 > y2) {
		tmp = y1;
		y1 = y2;
		y2 = tmp;
	}

	//Create destination rect
	var rect =  sys.SDL_Rect{
        .x = x1,
        .y = y1,
        .w = x2 - x1 + 1,
        .h = y2 - y1 + 1,
    };
	
	
	
	
	
	//Draw
	var result: i32  = 0;
	result |= sys.SDL_SetRenderDrawBlendMode(renderer, if (a == 255)  sys.SDL_BLENDMODE_NONE else sys.SDL_BLENDMODE_BLEND);
	result |= sys.SDL_SetRenderDrawColor(renderer, r, g, b, a);	
	result |= sys.SDL_RenderFillRect(renderer, &rect);
	return result;
}



pub fn roundedBoxColor(renderer: *sys.SDL_Renderer,  x1: i16,  y1: i16,  x2: i16,  y2: i16,  rad: i16, color: u32) i32 {
    const c = @bitCast([4]u8, color);
	return roundedBoxRGBA(renderer, x1, y1, x2, y2, rad, c[0], c[1], c[2], c[3]);
}
pub fn roundedBoxRGBA(renderer: *sys.SDL_Renderer,  x1_: i16,  y1_: i16,  x2_: i16,  y2_: i16,  rad_: i16,  r: u8,  g: u8,  b: u8,  a: u8) i32 {
    var x1 = x1_ ;
    var x2 = x2_ ;
    var y1 = y1_ ;
    var y2 = y2_ ;
    var rad = rad_ ;
    
	// Check destination renderer 
	// if (renderer == NULL)
	// {
		// return -1;
	// }

	// Check radius vor valid range
	if (rad < 0) {
		return -1;
	}

	//Special case - no rounding
	if (rad <= 1) {
		return boxRGBA(renderer, x1, y1, x2, y2, r, g, b, a);
	}

	//Test for special cases of straight lines or single point 
	if (x1 == x2) {
		if (y1 == y2) {
			return (pixelRGBA(renderer, x1, y1, r, g, b, a));
		} else {
			return (vlineRGBA(renderer, x1, y1, y2, r, g, b, a));
		}
	} else {
		if (y1 == y2) {
			return (hlineRGBA(renderer, x1, x2, y1, r, g, b, a));
		}
	}

	// Swap x1, x2 if required 
    var tmp: i16 = undefined;

	if (x1 > x2) {
		tmp = x1;
		x1 = x2;
		x2 = tmp;
	}

	// Swap y1, y2 if required 
	if (y1 > y2) {
		tmp = y1;
		y1 = y2;
		y2 = tmp;
	}

	// Calculate width&height 
    const w: i16 = x2 - x1 + 1; 
    const h: i16 = y2 - y1 + 1; 


	//Maybe adjust radius
    var r2: i16 = rad + rad; 

	if (r2 > w) {
		rad = w / 2;
		r2 = rad + rad;
	}
	if (r2 > h) {
		rad = h / 2;
	}

	// Setup filled circle drawing for corners
	const x: i16 = x1 + rad;
    const y: i16 = y1 + rad;
    const dx: i16 = x2 - x1 - rad - rad; 
    const dy: i16 = y2 - y1 - rad - rad;
	

	//Set color
    var result: i32 = 0;
	result |= sys.SDL_SetRenderDrawBlendMode(renderer, if (a == 255) sys.SDL_BLENDMODE_NONE else sys.SDL_BLENDMODE_BLEND);
	result |= sys.SDL_SetRenderDrawColor(renderer, r, g, b, a);

	//Draw corners
    var cx: i16 = 0;
	var cy: i16 = rad;
	var ocx: i16 = 0xffff;
	var ocy: i16 = 0xffff;
	var df: i16 = 1 - rad;
	var d_e: i16 = 3;
	var d_se: i16 = -2 * rad + 5;
    var xpcx: i16 = undefined; 
    var xmcx: i16 = undefined; 
    var xpcy: i16 = undefined; 
    var xmcy: i16 = undefined;
    var ypcy: i16 = undefined; 
    var ymcy: i16 = undefined; 
    var ypcx: i16 = undefined; 
    var ymcx: i16 = undefined;

	while(true) {
		xpcx = x + cx;
		xmcx = x - cx;
		xpcy = x + cy;
		xmcy = x - cy;
		if (ocy != cy) {
			if (cy > 0) {
				ypcy = y + cy;
				ymcy = y - cy;
				result |= hline(renderer, xmcx, xpcx + dx, ypcy + dy);
				result |= hline(renderer, xmcx, xpcx + dx, ymcy);
			} else {
				result |= hline(renderer, xmcx, xpcx + dx, y);
			}
			ocy = cy;
		}
		if (ocx != cx) {
			if (cx != cy) {
				if (cx > 0) {
					ypcx = y + cx;
					ymcx = y - cx;
					result |= hline(renderer, xmcy, xpcy + dx, ymcx);
					result |= hline(renderer, xmcy, xpcy + dx, ypcx + dy);
				} else {
					result |= hline(renderer, xmcy, xpcy + dx, y);
				}
			}
			ocx = cx;
		}

		//Update 
		if (df < 0) {
			df += d_e;
			d_e += 2;
			d_se += 2;
		} else {
			df += d_se;
			d_e += 2;
			d_se += 4;
			cy -= 1;
		}
		cx += 1;
        if (!(cx <= cy)) {
            break;
        }
	}

	// Inside
	if (dx > 0 and dy > 0) {
		result |= boxRGBA(renderer, x1, y1 + rad + 1, x2, y2 - rad, r, g, b, a);
	}

	return (result);
}



pub fn lineColor(renderer: *sys.SDL_Renderer, x1: i16, y1: i16, x2: i16, y2: i16, color: u32) i32 {
    const c = @bitCast([4]u8, color);
    return lineRGBA(renderer, x1, y1, x2, y2, c[0], c[1], c[2], c[3]);
}
fn lineRGBA(renderer: *sys.SDL_Renderer, x1: i16, y1: i16, x2: i16, y2: i16, r: u8, g: u8, b: u8, a: u8) i32 {
    var result: i32 = 0;
    result |= sys.SDL_SetRenderDrawBlendMode(renderer, if (a == 255) sys.SDL_BLENDMODE_NONE else sys.SDL_BLENDMODE_BLEND);
    result |= sys.SDL_SetRenderDrawColor(renderer, r,g,b,a);
    result |= sys.SDL_RenderDrawLine(renderer, x1, y1, x2, y2);
    return result;
}



pub fn aalineColor(renderer: *sys.SDL_Renderer,  x1: i16,  y1: i16,  x2: i16,  y2: i16, color: u32) i32 {
    const c = @bitCast([4]u8, color);
	return _aalineRGBA(renderer, x1, y1, x2, y2, c[0], c[1], c[2], c[3], 1);
}
pub fn aalineRGBA(renderer: *sys.SDL_Renderer,  x1: i16,  y1: i16,  x2: i16,  y2: i16,  r: u8,  g: u8,  b: u8,  a: u8) i32 {
	return _aalineRGBA(renderer, x1, y1, x2, y2, r, g, b, a, 1);
}
const AAbits = 8;
const AAlevels = 256;
pub fn _aalineRGBA(renderer: *sys.SDL_Renderer,  x1: i16,  y1: i16,  x2: i16,  y2: i16,  r: u8,  g: u8,  b: u8,  a: u8,  draw_endpoint: i32) i32 {
    var xx0: i32 = undefined; 
    var yy0: i32 = undefined; 
    var xx1: i32 = undefined; 
    var yy1: i32 = undefined;
	
    var result: i32 = undefined;
    var intshift: u32 = undefined; 
    var erracc: u32 = undefined; 
    var erradj: u32 = undefined;
	
    var erracctmp: u32 = undefined; 
    var wgt: u32 = undefined; 
    var wgtcompmask: u32 = undefined;
	
    var dx: i32 = undefined; 
    var dy: i32 = undefined; 
    var tmp: i32 = undefined; 
    var xdir: i32 = undefined; 
    var y0p1: i32 = undefined; 
    var x0pxdir: i32 = undefined;

	// Keep on working with 32bit numbers 
	xx0 = x1;
	yy0 = y1;
	xx1 = x2;
	yy1 = y2;

	// Reorder points to make dy positive 
	if (yy0 > yy1) {
		tmp = yy0;
		yy0 = yy1;
		yy1 = tmp;
		tmp = xx0;
		xx0 = xx1;
		xx1 = tmp;
	}

	// Calculate distance 
	dx = xx1 - xx0;
	dy = yy1 - yy0;

	// Adjust for negative dx and set xdir 
	if (dx >= 0) {
		xdir = 1;
	} else {
		xdir = -1;
		dx = (-dx);
	}
	
	// Check for special cases 
	if (dx == 0) {
		//
		// Vertical line 
		//
		if (draw_endpoint) {
			return (vlineRGBA(renderer, x1, y1, y2, r, g, b, a));
		} else {
			if (dy > 0) {
				return (vlineRGBA(renderer, x1, yy0, yy0+dy, r, g, b, a));
			} else {
				return (pixelRGBA(renderer, x1, y1, r, g, b, a));
			}
		}
	} else if (dy == 0) {
		//
		// Horizontal line 
		//
		if (draw_endpoint) {
			return (hlineRGBA(renderer, x1, x2, y1, r, g, b, a));
		} else {
			if (dx > 0) {
				return (hlineRGBA(renderer, xx0, xx0+(xdir*dx), y1, r, g, b, a));
			} else {
				return (pixelRGBA(renderer, x1, y1, r, g, b, a));
			}
		}
	} else if ((dx == dy) and (draw_endpoint)) {
		//
		// Diagonal line (with endpoint)
		//
		return (lineRGBA(renderer, x1, y1, x2, y2,  r, g, b, a));
	}


	// Line is not horizontal, vertical or diagonal (with endpoint)
	result = 0;

	// Zero accumulator 
	erracc = 0;

	// # of bits by which to shift erracc to get intensity level 
	intshift = 32 - AAbits;

	// Mask used to flip all bits in an intensity weighting 
	wgtcompmask = AAlevels - 1;

	// Draw the initial pixel in the foreground color 
	result |= pixelRGBA(renderer, x1, y1, r, g, b, a);

	// x-major or y-major? 
	if (dy > dx) {

		//
		// y-major.  Calculate 16-bit fixed point fractional part of a pixel that
		// X advances every time Y advances 1 pixel, truncating the result so that
		// we won't overrun the endpoint along the X axis 
		//
		//
		// Not-so-portable version: erradj = ((Uint64)dx << 32) / (Uint64)dy; 
		//
		erradj = ((dx << 16) / dy) << 16;

		//
		// draw all pixels other than the first and last 
		//
		x0pxdir = xx0 + xdir;
        dy -= 1;
        while (dy != 0): (dy -= 1) { // while (--dy)
			erracctmp = erracc;
			erracc += erradj;
			if (erracc <= erracctmp) {
				//
				// rollover in error accumulator, x coord advances 
				//
				xx0 = x0pxdir;
				x0pxdir += xdir;
			}
			yy0 += 1;		// y-major so always advance Y 

			//
			// the AAbits most significant bits of erracc give us the intensity
			// weighting for this pixel, and the complement of the weighting for
			// the paired pixel. 
			//
			wgt = (erracc >> intshift) & 255;
			result |= pixelRGBAWeight (renderer, xx0, yy0, r, g, b, a, 255 - wgt);
			result |= pixelRGBAWeight (renderer, x0pxdir, yy0, r, g, b, a, wgt);
		}

	} else {

		//
		// x-major line.  Calculate 16-bit fixed-point fractional part of a pixel
		// that Y advances each time X advances 1 pixel, truncating the result so
		// that we won't overrun the endpoint along the X axis. 
		//
		//
		// Not-so-portable version: erradj = ((Uint64)dy << 32) / (Uint64)dx; 
		//
		erradj = ((dy << 16) / dx) << 16;

		//
		// draw all pixels other than the first and last 
		//
		y0p1 = yy0 + 1;
		while (--dx) {

			erracctmp = erracc;
			erracc += erradj;
			if (erracc <= erracctmp) {
				//
				// Accumulator turned over, advance y 
				//
				yy0 = y0p1;
				y0p1 += 1;
			}
			xx0 += xdir;	// x-major so always advance X
			//
			// the AAbits most significant bits of erracc give us the intensity
			// weighting for this pixel, and the complement of the weighting for
			// the paired pixel. 
			//
			wgt = (erracc >> intshift) & 255;
			result |= pixelRGBAWeight (renderer, xx0, yy0, r, g, b, a, 255 - wgt);
			result |= pixelRGBAWeight (renderer, xx0, y0p1, r, g, b, a, wgt);
		}
	}

	// Do we have to draw the endpoint 
	if (draw_endpoint) {
		//
		// Draw final pixel, always exactly intersected by the line and doesn't
		// need to be weighted. 
		//
		result |= pixelRGBA (renderer, x2, y2, r, g, b, a);
	}

	return (result);
}



pub fn thickLineColor(renderer: *sys.SDL_Renderer,  x1: i16,  y1: i16,  x2: i16,  y2: i16, width: u8,  color: u8) i32 {	
    const c = @bitCast([4]u8, color);
	return thickLineRGBA(renderer, x1, y1, x2, y2, width, c[0], c[1], c[2], c[3]);
}
pub fn thickLineRGBA(renderer: *sys.SDL_Renderer,  x1: i16,  y1: i16,  x2: i16,  y2: i16,  width: u8,  r: u8,  g: u8,  b: u8,  a: u8) i32 {
    var wh: i32 = undefined;
	
    var dx: f64 = undefined; 
    var dy: f64 = undefined; 
    var dx1: f64 = undefined; 
    var dy1: f64 = undefined; 
    var dx2: f64 = undefined; 
    var dy2: f64 = undefined;
	
    var l: f64 = undefined;
    var wl2: f64 = undefined;
    var nx: f64 = undefined;
    var ny: f64 = undefined;
    var ang: f64 = undefined;
    var adj: f64 = undefined;
	
    var px: [4]i16 = undefined;
    var py: [4]i16 = undefined;
	// if (renderer == NULL) {
		// return -1;
	// }

	if (width < 1) {
		return -1;
	}

	// Special case: thick "point"
	if ((x1 == x2) and (y1 == y2)) {
		wh = width / 2;
		return boxRGBA(renderer, x1 - wh, y1 - wh, x2 + width, y2 + width, r, g, b, a);		
	}

	// Special case: width == 1
	if (width == 1) {
		return lineRGBA(renderer, x1, y1, x2, y2, r, g, b, a);		
	}

	// Calculate offsets for sides
	dx = @intToFloat(f64, (x2 - x1));
	dy = @intToFloat(f64, (y2 - y1));
	l =  std.math.sqrt(dx*dx + dy*dy);
	ang = std.math.atan2(dx, dy);
	adj = 0.1 + 0.9 * std.math.fabs(std.math.cos(2.0 * ang));
	wl2 = (@intToFloat(f64, width) - adj)/(2.0 * l);
	nx = dx * wl2;
	ny = dy * wl2;

	// Build polygon
	dx1 = @intToFloat(f64, x1);
	dy1 = @intToFloat(f64, y1);
	dx2 = @intToFloat(f64, x2);
	dy2 = @intToFloat(f64, y2);
	px[0] = @floatToInt(i16, (dx1 + ny));
	px[1] = @floatToInt(i16, (dx1 - ny));
	px[2] = @floatToInt(i16, (dx2 - ny));
	px[3] = @floatToInt(i16, (dx2 + ny));
	py[0] = @floatToInt(i16, (dy1 - nx));
	py[1] = @floatToInt(i16, (dy1 + nx));
	py[2] = @floatToInt(i16, (dy2 + nx));
	py[3] = @floatToInt(i16, (dy2 - nx));

	// Draw polygon
	return filledPolygonRGBA(renderer, &px, &py, 4, r, g, b, a);
}




























pub fn filledPolygonRGBA(renderer: *sys.SDL_Renderer, vx: []const i16, vy: []const i16, n: i32,  r: u8,  g: u8,  b: u8,  a: u8) i32 {
	return filledPolygonRGBAMT(renderer, vx, vy, n, r, g, b, a, null, null);
}
var gfxPrimitivesPolyIntsGlobal: ?[]i32 = null;
var gfxPrimitivesPolyAllocatedGlobal: i32 = 0;
pub fn filledPolygonRGBAMT(renderer: *sys.SDL_Renderer,vx: []const i16, vy: []const i16,n: i32,  r: u8,  g: u8,  b: u8,  a: u8, polyInts_: ?*[] i32, polyAllocated_: ?*i32) i32 {
    var polyInts: ?*[] i32 = polyInts_;
    var polyAllocated: ?*i32 = polyAllocated_;

	var result: i32 = undefined;
	var i: i32 = undefined;
	
    var y: i32 = undefined;
    var xa: i32 = undefined;
    var xb: i32 = undefined;
	
    
    var miny: i32 = undefined;
    var maxy: i32 = undefined;
	
    var x1: i32 = undefined;
    var y1: i32 = undefined;
	
    var x2: i32 = undefined;
    var y2: i32 = undefined;
	
    var ind1: i32 = undefined;
    var ind2: i32 = undefined;
	
    var ints: i32 = undefined;
	
    
    var gfxPrimitivesPolyInts: ?[]i32  = null;
	
    var gfxPrimitivesPolyIntsNew: ?[]i32  = null;
	var gfxPrimitivesPolyAllocated: i32 = 0;

	// Vertex array NULL check 
	// if (vx == NULL) {
	// 	return (-1);
	// }
	// if (vy == NULL) {
	// 	return (-1);
	// }

	// Sanity check number of edges
	if (n < 3) {
		return -1;
	}

	//Map polygon cache  
	if ((polyInts == null) or (polyAllocated == null)) {
		// Use global cache
		gfxPrimitivesPolyInts = gfxPrimitivesPolyIntsGlobal;
		gfxPrimitivesPolyAllocated = gfxPrimitivesPolyAllocatedGlobal;
	} else {
		// Use local cache
		gfxPrimitivesPolyInts = polyInts.?.*;
		gfxPrimitivesPolyAllocated = polyAllocated.?.*;
	}


	// Allocate temp array, only grow array 
	if (gfxPrimitivesPolyAllocated == 0) {
		gfxPrimitivesPolyInts = sys.SDL_malloc(@sizeOf(i32) * n); //(int *) malloc(sizeof(int) * n);
		gfxPrimitivesPolyAllocated = n;
	} else {
		if (gfxPrimitivesPolyAllocated < n) {
			gfxPrimitivesPolyIntsNew = sys.SDL_realloc(gfxPrimitivesPolyInts.?.ptr, @sizeOf(i32) * n);//(int *) realloc(gfxPrimitivesPolyInts, sizeof(int) * n);
			if (gfxPrimitivesPolyIntsNew == null) {
				if (gfxPrimitivesPolyInts == null) {
					sys.SDL_free(gfxPrimitivesPolyInts.?.ptr);//free(gfxPrimitivesPolyInts);
					gfxPrimitivesPolyInts = null;
				}
				gfxPrimitivesPolyAllocated = 0;
			} else {
				gfxPrimitivesPolyInts = gfxPrimitivesPolyIntsNew;
				gfxPrimitivesPolyAllocated = n;
			}
		}
	}

	// Check temp array
	if (gfxPrimitivesPolyInts == null) {        
		gfxPrimitivesPolyAllocated = 0;
	}

	// Update cache variables
	if ((polyInts == null) or (polyAllocated == null)) { 
		gfxPrimitivesPolyIntsGlobal =  gfxPrimitivesPolyInts;
		gfxPrimitivesPolyAllocatedGlobal = gfxPrimitivesPolyAllocated;
	} else {
		polyInts.?.* = gfxPrimitivesPolyInts;
		polyAllocated.?.* = gfxPrimitivesPolyAllocated;
	}

	// Check temp array again
	if (gfxPrimitivesPolyInts == null) {        
		return(-1);
	}

	// Determine Y maxima 
	miny = vy[0];
	maxy = vy[0];
    i = 1;
	while (i < n): (i += 1) {
		if (vy[i] < miny) {
			miny = vy[i];
		} else if (vy[i] > maxy) {
			maxy = vy[i];
		}
	}

	// Draw, scanning y 
	result = 0;
    y = miny;
	while (y <= maxy): (y += 1) {
		ints = 0;
        i = 0;
		while (i < n): (i += 1) {
			if (i == 0) { // (!i)
				ind1 = n - 1;
				ind2 = 0;
			} else {
				ind1 = i - 1;
				ind2 = i;
			}
			y1 = vy[ind1];
			y2 = vy[ind2];
			if (y1 < y2) {
				x1 = vx[ind1];
				x2 = vx[ind2];
			} else if (y1 > y2) {
				y2 = vy[ind1];
				y1 = vy[ind2];
				x2 = vx[ind1];
				x1 = vx[ind2];
			} else {
				continue;
			}
			if ( ((y >= y1) and (y < y2)) || ((y == maxy) and (y > y1) and (y <= y2)) ) {
				gfxPrimitivesPolyInts[ints] = ((65536 * (y - y1)) / (y2 - y1)) * (x2 - x1) + (65536 * x1);
                ints += 1;
			} 	    
		}

		// qsort(gfxPrimitivesPolyInts, ints, sizeof(int), _gfxPrimitivesCompareInt);
        sys.SDL_qsort(gfxPrimitivesPolyInts.?.ptr, ints, @sizeOf(i32), _gfxPrimitivesCompareInt);
        // std.sort.sort(i32, gfxPrimitivesPolyInts.?, null, _gfxPrimitivesCompareInt);

		// Set color 
		result = 0;
	    result |= sys.SDL_SetRenderDrawBlendMode(renderer, if (a == 255)  sys.SDL_BLENDMODE_NONE else sys.SDL_BLENDMODE_BLEND);
		result |= sys.SDL_SetRenderDrawColor(renderer, r, g, b, a);	
        
        i = 0;
		while (i < ints): (i += 2) {
			xa = gfxPrimitivesPolyInts[i] + 1;
			xa = (xa >> 16) + ((xa & 32768) >> 15);
			xb = gfxPrimitivesPolyInts[i+1] - 1;
			xb = (xb >> 16) + ((xb & 32768) >> 15);
			result |= hline(renderer, xa, xb, y);
		}
	}

	return (result);
}

fn _gfxPrimitivesCompareInt(arg_a: ?*const i32, arg_b: ?*const i32) c_int {
    return arg_a.?.* - arg_b.?.*;
}

pub fn pixelRGBAWeight(renderer: *sys.SDL_Renderer,  x: i16,  y: i16,  r: u8,  g: u8,  b: u8,  a: u8,  weight: u32) i32 {
	//
	// Modify Alpha by weight 
	//
	var ax: u32 = a;
	ax = ((ax * weight) >> 8);
	if (ax > 255) {
		a = 255;
	} else {
		a = @intCast(u8, (ax & 0x000000ff));
	}

	return pixelRGBA(renderer, x, y, r, g, b, a);
}






pub fn arcRGBA(renderer: *sys.SDL_Renderer,  x: i16,  y: i16,  rad: i16,  start_: i16,  end_: i16,  r: u8,  g: u8,  b: u8,  a: u8) i32 {
    var  start: i16 =  start_;
    var  end: i16 =  end_;


	//Sanity check radius 
	if (rad < 0) {
		return (-1);
	}

	//Special case for rad=0 - draw a point 
	if (rad == 0) {
		return (pixelRGBA(renderer, x, y, r, g, b, a));
	}

	// Octant labeling
	//      
	//  \ 5 | 6 /
	//   \  |  /
	//  4 \ | / 7
	//     \|/
	//------+------ +x
	//     /|\
	//  3 / | \ 0
	//   /  |  \
	//  / 2 | 1 \
	//      +y
    //
	// Initially reset bitmask to 0x00000000
	// the set whether or not to keep drawing a given octant.
	// For example: 0x00111100 means we're drawing in octants 2-5
    var drawoct: u8 = 0;

	//Fixup angles
    start = @rem(start, 360);
    end = @rem(end, 360);
	// 0 <= start & end < 360; note that sometimes start > end - if so, arc goes back through 0.
	while (start < 0) start += 360;
	while (end < 0) end += 360;
    start = @rem(start, 360);
    end = @rem(end, 360);

	// now, we find which octants we're drawing in.
    const startoct: i32 = @divTrunc(start , 45); 
    const endoct: i32 = @divTrunc(end , 45); 
    var oct: i32 = startoct - 1; 

	// stopval_start, stopval_end; what values of cx to stop at.
    var stopval_start: i32 = 0;
    var stopval_end: i32 = 0;
    var dstart: f64 = 0;
    var dend: f64 = 0;
    var temp: f64 = 0;

	while (true) {
		oct = @rem((oct + 1), 8);

		if (oct == startoct) {
			// need to compute stopval_start for this octant.  Look at picture above if this is unclear
			dstart = @intToFloat(f64, start);
			switch (oct) {
                0, 3 => {
                    temp = std.math.sin(dstart * std.math.pi / 180.0);
                },

			    1, 6 => {
    				temp = std.math.cos(dstart * std.math.pi / 180.0);
                },

			    2, 5 => {
    				temp = -std.math.cos(dstart * std.math.pi / 180.0);
                },

                4, 7 => {
    				temp = -std.math.sin(dstart * std.math.pi / 180.0);
                },
                else => unreachable,
			}
			temp *= @intToFloat(f64, rad);
			stopval_start = @floatToInt(i32, temp);

			// This isn't arbitrary, but requires graph paper to explain well.
			// The basic idea is that we're always changing drawoct after we draw, so we
			// stop immediately after we render the last sensible pixel at x = ((int)temp).
			// and whether to draw in this octant initially
			if (@rem(oct, 2) != 0) {
                drawoct |= @intCast(u8, (@as(i32, 1) << @intCast(u5, oct)));			// this is basically like saying drawoct[oct] = true, if drawoct were a bool array
            } else{
                drawoct &= @intCast(u8, 255 - (@as(i32, 1) << @intCast(u5, oct)));    // this is basically like saying drawoct[oct] = false 
            }	
		}
		if (oct == endoct) {
			// need to compute stopval_end for this octant
			dend = @intToFloat(f64, end);
			switch (oct) {
                0, 3 => {
                    temp = std.math.sin(dend * std.math.pi / 180);
                },
                1, 6 => {
                    temp = std.math.cos(dend * std.math.pi / 180);
                },
                2, 5 => {
                    temp = -std.math.cos(dend * std.math.pi / 180);
                },
                4, 7 => {
                    temp = -std.math.sin(dend * std.math.pi / 180);
                },
                else => unreachable,
			}
            temp = temp * @intToFloat(f64, rad);
			stopval_end = @floatToInt(i32, temp);

			// and whether to draw in this octant initially
			if (startoct == endoct)	{
				// note:      we start drawing, stop, then start again in this case
				// otherwise: we only draw in this octant, so initialize it to false, it will get set back to true
				if (start > end) {
					// unfortunately, if we're in the same octant and need to draw over the whole circle,
					// we need to set the rest to true, because the while loop will end at the bottom.
					drawoct = 255;
				} else {
					drawoct &= @intCast(u8, 255 - (@as(i32, 1) << @intCast(u5, oct)));
				}
			} else if (@rem(oct, 2) != 0) {
                drawoct &= @intCast(u8, 255 - (@as(i32, 1) << @intCast(u5, oct)));
            } else {
                drawoct |= @intCast(u8, (@as(i32, 1) << @intCast(u5, oct)));
            }
		} else if (oct != startoct) { // already verified that it's != endoct
			drawoct |= @intCast(u8, (@as(i32, 1)  << @intCast(u5, oct))); // draw this entire segment
		}
        if (!(oct != endoct)) {
            break;
        }
	} 

	// so now we have what octants to draw and when to draw them. all that's left is the actual raster code.

	//Set color 
	var result: i32 = 0;
	result |= sys.SDL_SetRenderDrawBlendMode(renderer, if (a == 255) sys.SDL_BLENDMODE_NONE else sys.SDL_BLENDMODE_BLEND);
	result |= sys.SDL_SetRenderDrawColor(renderer, r, g, b, a);

	//Draw arc 
	var cx: i16 = 0;
	var cy: i16 = rad;
	var df: i16 = 1 - rad;
	var d_e: i16 = 3;
	var d_se: i16 = -2 * rad + 5;
    var xpcx: i16 = undefined; 
    var xmcx: i16 = undefined; 
    var xpcy: i16 = undefined; 
    var xmcy: i16 = undefined;
    var ypcy: i16 = undefined; 
    var ymcy: i16 = undefined; 
    var ypcx: i16 = undefined; 
    var ymcx: i16 = undefined;

	while (true) {
		ypcy = y + cy;
		ymcy = y - cy;
		if (cx > 0) {
			xpcx = x + cx;
			xmcx = x - cx;

			// always check if we're drawing a certain octant before adding a pixel to that octant.
			if ((drawoct & 4) != 0)  result |= sys.SDL_RenderDrawPoint(renderer, xmcx, ypcy);
			if ((drawoct & 2) != 0)  result |= sys.SDL_RenderDrawPoint(renderer, xpcx, ypcy);
			if ((drawoct & 32) != 0) result |= sys.SDL_RenderDrawPoint(renderer, xmcx, ymcy);
			if ((drawoct & 64) != 0) result |= sys.SDL_RenderDrawPoint(renderer, xpcx, ymcy);
		} else {
			if ((drawoct & 96 != 0)) result |= sys.SDL_RenderDrawPoint(renderer, x, ymcy);
			if ((drawoct & 6) != 0)  result |= sys.SDL_RenderDrawPoint(renderer, x, ypcy);
		}

		xpcy = x + cy;
		xmcy = x - cy;
		if (cx > 0 and cx != cy) {
			ypcx = y + cx;
			ymcx = y - cx;
			if ((drawoct & 8) != 0)   result |= sys.SDL_RenderDrawPoint(renderer, xmcy, ypcx);
			if ((drawoct & 1) != 0)   result |= sys.SDL_RenderDrawPoint(renderer, xpcy, ypcx);
			if ((drawoct & 16) != 0)  result |= sys.SDL_RenderDrawPoint(renderer, xmcy, ymcx);
			if ((drawoct & 128) != 0) result |= sys.SDL_RenderDrawPoint(renderer, xpcy, ymcx);
		} else if (cx == 0) {
			if ((drawoct & 24) != 0)  result |= sys.SDL_RenderDrawPoint(renderer, xmcy, y);
			if ((drawoct & 129) != 0) result |= sys.SDL_RenderDrawPoint(renderer, xpcy, y);
		}

		// Update whether we're drawing an octant
		if (stopval_start == cx) {
			// works like an on-off switch.
			// This is just in case start & end are in the same octant.
			if ((drawoct & (@as(i32, 1) << @intCast(u5, startoct))) != 0) {
                drawoct &= @intCast(u8, 255 - (@as(i32, 1) << @intCast(u5, startoct)));
            } else {
                drawoct |= @intCast(u8, (@as(i32, 1) << @intCast(u5, startoct)));
            }
		}
		if (stopval_end == cx) {
			if ((drawoct & (@as(i32, 1) << @intCast(u5, endoct))) != 0) {
                drawoct &= @intCast(u8, 255 - (@as(i32, 1) << @intCast(u5, endoct)));
            } else {
                drawoct |= @intCast(u8, (@as(i32, 1) << @intCast(u5, endoct)));
            }
		}

		// Update pixels
		if (df < 0) {
			df += d_e;
			d_e += 2;
			d_se += 2;
		} else {
			df += d_se;
			d_e += 2;
			d_se += 4;
			cy -= 1;
		}
		cx += 1;
        if (!(cx <= cy)) {
            break;
        }
	}

	return (result);
}

pub fn hline(renderer: *sys.SDL_Renderer,  x1: i16,  x2: i16,  y: i16) i32 {
	return sys.SDL_RenderDrawLine(renderer, x1, y, x2, y);
}

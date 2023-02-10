const std = @import("std");
const sys = @import("raw_sdl.zig").sys;

pub const Rect = struct {
    raw: sys.SDL_Rect,

    pub fn init(x_: i32, y_: i32, width_: i32, height_: i32) Rect {
        return Rect{ .raw = sys.SDL_Rect{
            .x = x_,
            .y = y_,
            .w = width_,
            .h = height_,
        } };
    }

    pub fn init_checked(x_: i32, y_: i32, width_: u32, height_: u32) Rect {
        return Rect{ .raw = sys.SDL_Rect{
            .x = clamp_position(x_),
            .y = clamp_position(y_),
            .w = clamp_size(width_),
            .h = clamp_size(height_),
        } };
    }

    pub fn from_center(center_: Point, width_: u32, height_: u32) Rect {
        const raw =sys.SDL_Rect{
            .x = 0,
            .y = 0,
            .w = clamp_size(width_),
            .h = clamp_size(height_),
        };
        var rect = Rect{.raw=raw};
        rect.center_on_p(center_);
        return rect;
    }

    pub fn from_center_unchecked(center_: Point, width_: u32, height_: u32) Rect {
        const raw =sys.SDL_Rect{
            .x = 0,
            .y = 0,
            .w = width_,
            .h = height_,
        };
        var rect = Rect{.raw=raw};
        rect.center_on_p_unchecked(center_);
        return rect;
    }

    /// The horizontal position of this rectangle.
    pub fn x(self: *const Rect)  i32 {
        return self.raw.x;
    }

    /// The vertical position of this rectangle.
    pub fn y(self: *const Rect)  i32 {
        return self.raw.y;
    }

    /// The width of this rectangle.
    pub fn width(self: *const Rect)  i32 {
        return self.raw.w;
    }

    /// The height of this rectangle.
    pub fn height(self: *const Rect)  i32 {
        return self.raw.h;
    }

    /// Returns the width and height of this rectangle.
    pub fn size(self: *const Rect)  struct {i32, i32} {
        return .{self.raw.w, self.raw.h};
    }

    /// Sets the horizontal position of this rectangle to the given value,
    /// clamped to be less than or equal to std.math.maxInt(i32) / 2.
    pub fn set_x(self: *Rect, x_: i32) void {
        self.raw.x = clamp_position(x_);
    }

    pub fn set_x_unchecked(self: *Rect, x_: i32) void {
        self.raw.x = x_;
    }

    /// Sets the vertical position of this rectangle to the given value,
    /// clamped to be less than or equal to std.math.maxInt(i32) / 2.
    pub fn set_y(self: *Rect, y_: i32) void{
        self.raw.y = clamp_position(y_);
    }
    pub fn set_y_unchecked(self: *Rect, y_: i32) void{
        self.raw.y = y_;
    }

    /// Sets the width of this rectangle to the given value,
    /// clamped to be less than or equal to std.math.maxInt(i32) / 2.
    pub fn set_width(self: *Rect, width_: u32) void{
        self.raw.w = clamp_size(width_);
    }
    pub fn set_width_unchecked(self: *Rect, width_: u32) void{
        self.raw.w = width_;
    }

    /// Sets the height of this rectangle to the given value,
    /// clamped to be less than or equal to std.math.maxInt(i32) / 2.
    pub fn set_height(self: *Rect, height_: u32) void {
        self.raw.h = clamp_size(height_);
    }

    pub fn set_height_unchecked(self: *Rect, height_: u32) void {
        self.raw.h = height_;
    }

    /// Returns the x-position of the left side of this rectangle.
    pub fn left(self: *const Rect) i32 {
        return self.raw.x;
    }

    /// Returns the x-position of the right side of this rectangle.
    pub fn right(self: *const Rect) i32 {
        return self.raw.x + self.raw.w;
    }

    /// Returns the y-position of the top side of this rectangle.
    pub fn top(self: *const Rect) i32 {
        return self.raw.y;
    }

    /// Returns the y-position of the bottom side of this rectangle.
    pub fn bottom(self: *const Rect) i32 {
        return self.raw.y + self.raw.h;
    }

    test "center test" {
        const rect = Rect.init(1,0, 2,3);
        const p = Point.init(2, 1);
        const c = rect.center();

        try std.testing.expect(p.raw.x == c.raw.x);
        try std.testing.expect(p.raw.y == c.raw.y);
    }
    pub fn center(self: *const Rect) Point {
        const x_ = self.raw.x + (@divTrunc(self.raw.w , 2));
        const y_ = self.raw.y + (@divTrunc(self.raw.h , 2));

        return Point.init(x_, y_);
    }

    pub fn top_left(self: *const Rect) Point {
        return Point.init(self.left(), self.top());
    }

    pub fn top_right(self: *const Rect) Point {
        return Point.init(self.left(), self.bottom());
    }

    pub fn bottom_left(self: *const Rect) Point {
        return Point.init(self.left(), self.bottom());
    }

    pub fn bottom_right(self: *const Rect) Point {
        return Point.init(self.right(), self.bottom());
    }

    pub fn set_right(self: *Rect, right_ : i32) void {
        self.raw.x = clamp_position(clamp_position(right_) - self.raw.w);
    }

    pub fn set_right_unchecked(self: *Rect, right_ : i32) void {
        self.raw.x = right_ - self.raw.w;
    }

    pub fn set_bottom(self: *Rect, bottom_: i32) void {
        self.raw.y = clamp_position(clamp_position(bottom_) - self.raw.h);
    }

    pub fn set_bottom_unchecked(self: *Rect, bottom_: i32) void {
        self.raw.y = bottom_ - self.raw.h;
    }

    pub fn center_on(self: *Rect, point: struct{i32, i32}) void {
        self.raw.x = clamp_position(clamp_position(point[0]) - @divTrunc(self.raw.w , 2));
        self.raw.y = clamp_position(clamp_position(point[1]) - @divTrunc(self.raw.h , 2));
    }

    pub fn center_on_unchecked(self: *Rect, point: struct{i32, i32}) void {
        self.raw.x = point[0] - @divTrunc(self.raw.w , 2);
        self.raw.y = point[1] - @divTrunc(self.raw.h , 2);
    }

    pub fn center_on_p(self: *Rect, point: Point) void {
        self.raw.x = clamp_position(clamp_position(point.x()) - @divTrunc(self.raw.w, 2));
        self.raw.y = clamp_position(clamp_position(point.y()) - @divTrunc(self.raw.h , 2));
    }

    pub fn center_on_p_unchecked(self: *Rect, point: Point) void {
        self.raw.x = point.x() - @divTrunc(self.raw.w , 2);
        self.raw.y = point.y() - @divTrunc(self.raw.h , 2);
    }

    pub fn offset(self: *Rect, x_:i32, y_:i32) void {
        self.raw.x = clamp_position(self.raw.x +| x_);
        self.raw.y = clamp_position(self.raw.y +| y_);
    }

    pub fn offset_unchecked(self: *Rect, x_:i32, y_:i32) void {
        self.raw.x += x_;
        self.raw.y += y_;
    }

    pub fn reposition(self: *Rect, point: struct{i32, i32}) void {
        self.raw.x = clamp_position(point[0]);
        self.raw.y = clamp_position(point[1]);
    }

    pub fn reposition_unchecked(self: *Rect, point: struct{i32, i32}) void {
        self.raw.x = point[0];
        self.raw.y = point[1];
    }

    pub fn resize(self: *Rect, width_: u32, height_: u32) void {
        self.raw.w = clamp_size(width_);
        self.raw.h = clamp_size(height_);
    }

    pub fn resize_unchecked(self: *Rect, width_: i32, height_: i32) void {
        self.raw.w = width_;
        self.raw.h = height_;
    }

    pub fn contains_point(self: *const Rect, point: Point) bool {
        const x_ = point.raw.x;
        const y_ = point.raw.y;
        const inside_x = x_ >= self.left() and x_ < self.right();
        return inside_x and (self.top() and y_ < self.bottom());
    }

    pub fn contains_point_t(self: *const Rect, point: struct{i32, i32}) bool {
        const x_ = point[0];
        const y_ = point[1];
        const inside_x = x_ >= self.left() and x_ < self.right();
        return inside_x and (self.top() and y_ < self.bottom());
    }

    pub fn contains_rect(self: *const Rect, other: Rect) bool {
        return other.left() >= self.left()
            and other.right() <= self.right()
            and other.top() >= self.top()
            and other.bottom() <= self.bottom();
    }

    pub fn from(raw: sys.SDL_Rect) Rect {
        return Rect.init(raw.x, raw.y, raw.w, raw.h);
    }

    /// https://wiki.libsdl.org/SDL2/SDL_EnclosePoints
    pub fn from_enclose_points(points: []Point, clipping_rect: ?Rect) ?Rect {
        if (points.len == 0) {
            return null;
        }

        const clip_ptr: *const sys.SDL_Rect = if (clipping_rect) |r| &r.raw else return null;
        
        var out = undefined;
        const ret = sys.SDL_EnclosePoints(points.ptr, @intCast(i32, points.len), clip_ptr, &out) != sys.SDL_FALSE;

        if (ret) {
            return Rect.from(out.*);
        } else {
            return null;
        }
    }


    /// https://wiki.libsdl.org/SDL2/SDL_HasIntersection
    pub fn has_intersection(self: *const Rect, other: Rect) bool {
        return sys.SDL_HasIntersection(&self.raw, &other.raw) != sys.SDL_FALSE;
    }

    /// https://wiki.libsdl.org/SDL2/SDL_IntersectRect
    pub fn intersection(self: *const Rect, other: Rect) ?Rect {
        var out = undefined;

        const ret = sys.SDL_IntersectRect(*self.raw, *other.raw, &out) != sys.SDL_FALSE;

        if (ret) {
            return Rect.from(out.*);
        } else {
            return null;
        }
    }

    /// https://wiki.libsdl.org/SDL2/SDL_UnionRect
    pub fn union_rect(self: *const Rect, other: Rect) Rect {
        var out = undefined;

        sys.SDL_UnionRect(&self.raw, &other.raw, &out);

        return Rect.from(out.*);
    }

    /// https://wiki.libsdl.org/SDL2/SDL_IntersectRectAndLine
    pub fn intersect_line(self: *const Rect, start: Point, end: Point) struct {Point, Point}{
        var start_x = start.raw.x;
        var start_y = start.raw.y;

        var end_x = end.raw.x;
        var end_y = end.raw.y;

        const ret = sys.SDL_IntersectRectAndLine(&self.raw, &start_x, &start_y, &end_x, &end_y) != sys.SDL_FALSE;

        if (ret) {
            return .{Point.init(start_x, start_y), Point.init(end_x, end_y)};
        } else {
            return null;
        }
    }
};



pub const Point = struct {
    raw: sys.SDL_Point,
    
    pub fn init(x_: i32, y_: i32) Point {
        return Point{
            .raw= sys.SDL_Point{
                .x=x_,
                .y=y_,
            }
        };
    }

    pub fn init_checked(x_: i32, y_: i32) Point {
        return Point{
            .raw= sys.SDL_Point{
                .x=clamp_position(x_),
                .y=clamp_position(y_),
            }
        };
    }


    pub fn from(raw: sys.SDL_Point) Point {
        return Point.init(raw.x, raw.y);
    }

    
    pub fn offset(self: *Point, x_:i32, y_:i32) Point {
        const x__ = clamp_position(self.raw.x +| x_);
        const y__ = clamp_position(self.raw.y +| y_);

        return Point.init(x__, y__);
    }

    pub fn offset_unchecked(self: *Point, x_:i32, y_:i32) void {
        const x__ = self.raw.x + x_;
        const y__ = self.raw.y + y_;

        return Point.init(x__, y__);
    }


    pub fn scale(self: Point, f: i32) Point {
        return Point.init(self.raw.x *| f, self.raw.y *| f);
    }

    pub fn scale_unchecked(self: Point, f: i32) Point {
        return Point.init(self.raw.x * f, self.raw.y * f);
    }

    pub fn x(self: Point) i32 {
        return self.raw.x;
    }

    pub fn y(self: Point) i32 {
        return self.raw.y;
    }
};





const max_int_value = std.math.maxInt(i32) / 2;
const min_int_value = std.math.minInt(i32) / 2;


fn clamp_position(val: i32)  i32 {
    if (val > max_int_value) {
        return max_int_value;
    } else if (val < min_int_value) {
        return min_int_value;
    } else {
        return val;
    }
}

fn clamp_size(val: u32) u32 {
    if (val == 0) {
        return 1;
    } else if (val > max_int_value) {
        return max_int_value;
    } else {
        return val;
    }
}

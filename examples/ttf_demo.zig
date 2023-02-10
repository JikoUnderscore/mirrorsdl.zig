const std = @import("std");
const sdl2 = @import("sdl2");



fn get_centered_rect(rect_width: u32, rect_height: u32, cons_width: u32, cons_height: u32) sdl2.rect.Rect {
    const wr = @intToFloat(f32, rect_width) / @intToFloat(f32, cons_width);
    const hr = @intToFloat(f32, rect_height) / @intToFloat(f32, cons_height);

    const w_h: struct{i32, i32} = bl: {    
        if (wr > @as(f32, 1) or hr > @as(f32, 1)) {
            if (wr > hr) {
                std.debug.print("Scaling down! The text will look worse!", .{});
                break: bl .{@intCast(i32, cons_width),@intCast(i32, (@floatToInt(i32, @intToFloat(f32, rect_height) / wr))) };
            } else {
                std.debug.print("Scaling down! The text will look worse!", .{});
                break: bl .{(@floatToInt(i32, @intToFloat(f32, rect_width) / hr)), @intCast(i32, cons_height)};
            }
        } else {
            break: bl .{@intCast(i32, rect_width), @intCast(i32, rect_height)};
        }
    };
    const w: i32 = w_h[0];
    const h: i32 = w_h[1];

    const cx =  @divTrunc((800 - w) , @as(i32, 2)) ;
    const cy = @divTrunc((600 - h) , @as(i32, 2));
    return sdl2.rect.Rect.init(cx, cy, w, h);
}   



pub fn main() !void {
    const sdl_context = try sdl2.init();
    defer sdl_context.deinit();
    errdefer std.log.debug("{s}\n", .{sdl2.get_error()});

    var canvas = try cnvs:{
        const video_subsys = try sdl_context.video();

        var w = video_subsys.window("TTF example", 800, 600);
        const window = try w.position_centered().opengl().build();

        break: cnvs window.into_canvas().build();
    };
    defer canvas.deinit();

    const texture_creator = canvas.texture_creator();
    const ttf_context = try sdl2.ttf.init();


    var font = try ttf_context.load_font("./assets/JetBrainsMono-Regular.ttf", 128);
    defer font.deinit();

    font.set_style(sdl2.ttf.FontStyle.BOLD);

    const texture = try txtr: {
        const surface = try font.render("'ello zig").blended_color(sdl2.pixels.Color.RGBA(255,0,0,255));
        defer surface.deinit();
        
        break: txtr texture_creator.create_texture_from_surface(&surface);
    };
    defer texture.deinit();

    canvas.set_draw_color(sdl2.pixels.Color.RGBA(195, 217, 255, 255));
    canvas.clear();

    const tq =  texture.query();
    const width = tq.width;
    const height = tq.height;

    const padding = 64;
    const target = get_centered_rect(width, height, 800 - padding, 600 - padding);

    try canvas.copy(&texture, null, target);
    canvas.present();

    var event_pump = try sdl_context.event_pump();
    defer event_pump.deinit();

    mainloop: while (true) {
        while (event_pump.poll_iter()) |event| {
            switch (event) {
                .Quit=> {
                    break: mainloop;
                },
                .KeyDown => |kd|{
                    if (kd.keycode)|kc| {
                        switch (kc) {
                            .Escape => {
                                break: mainloop;
                            },
                            else => {}
                        }
                    }
                 },
                else => {},
            }
        }
    }

}
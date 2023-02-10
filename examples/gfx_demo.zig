const std = @import("std");
const sdl2 = @import("sdl2");

pub fn main() !void {
    const sdl_context = try sdl2.init();
    defer sdl_context.deinit();
    errdefer std.log.debug("{s}\n", .{sdl2.get_error()});

    var canvas: sdl2.render.WindowCanvas = try ret: {
        const video_sys = try sdl_context.video();
        var w = video_sys.window("draw line", 1080, 720);
        const window = try w.position_centered().opengl().build();

        break: ret window.into_canvas().build();
    };


    canvas.set_draw_color( sdl2.pixels.Color.RGB(0, 0, 0));
    canvas.clear();

    canvas.present(); 
    var lastx: i16 = 0;
    var lasty: i16 = 0;

    var event_pump = try sdl_context.event_pump();
    defer event_pump.deinit();



    mainloop: while (true) {
        while (event_pump.poll_iter()) |event| {
            switch (event) {
                .Quit=> {
                    break: mainloop;
                },

                sdl2.events.Event.KeyDown => |kd|{
                    if (kd.keycode)|kc| {
                        if (kc == .Space) {
                        
                        }
                    }
                },

                sdl2.events.Event.MouseButtonDown => |mbd|{
                    const color = .{
                        @truncate(u8, @intCast(u32, mbd.x)), 
                        @truncate(u8, @intCast(u32, mbd.y)),
                        255,
                        255,
                    };

                    try canvas.line_tuple( lastx, lasty, @truncate(i16, mbd.x), @truncate(i16, mbd.y),  color);
                    lastx = @truncate(i16, mbd.x);
                    lasty = @truncate(i16, mbd.y);
                    std.debug.print("mouse button at {} {}\n", .{mbd.x, mbd.y});
                    canvas.present();

                },

                else => {
                },
            }
        }
    }











}
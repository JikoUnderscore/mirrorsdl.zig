const std = @import("std");
const sdl2 = @import("sdl2");

pub fn main() !void {
    const png = "assets/cursor.png";
    
    const sdl_context = try sdl2.init();
    defer sdl_context.deinit();
    errdefer std.log.debug("{s}\n", .{sdl2.get_error()});

    const image_context = try sdl2.image.init(sdl2.image.InitFlags.PNG | sdl2.image.InitFlags.JPG);
    defer image_context.deinit();


    var canvas: sdl2.render.WindowCanvas = try cnvs: { 
        const video_subsystem = try sdl_context.video();

        var w = video_subsystem.window("zig: Cursor", 800, 600);
        const window = try w.position_centered().build();
    
        break: cnvs window.into_canvas().software().build();
    };
    defer canvas.deinit();


    const surface = try sdl2.surface.Surface.from_file(png);
    defer surface.deinit();
    
    
    const cursor = try sdl2.cursor.Cursor.from_surface(&surface, 0, 0);
    defer cursor.deinit();
    cursor.set();

    canvas.clear();
    canvas.present();

    canvas.set_draw_color_tuple(.{255,255,255,255});

    var events = try sdl_context.event_pump();
    defer events.deinit();

    var is_running = true;
    while (is_running) {
        while (events.poll_iter()) |event| {
            switch (event) {
                .Quit => {
                    is_running = false;
                },

                .MouseButtonDown => |mbd|{
                    try canvas.fill_rect(sdl2.rect.Rect.init(mbd.x, mbd.y, 1, 1));
                    canvas.present();
                },
                else =>{}
            }
        }
    }
}
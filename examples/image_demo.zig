const std = @import("std");
const sdl2 = @import("sdl2");

pub fn main() !void {
    const sdl_context = try sdl2.init();
    defer sdl_context.deinit();
    errdefer std.log.debug("{s}\n", .{sdl2.get_error()});

    const png = "./assets/Ziggy_2.png";

    var canvas: sdl2.render.WindowCanvas = try ret: {
        const video_sys = try sdl_context.video();
        var w = video_sys.window("Video", 560, 698);
        const window = try w.position_centered().build();

        break: ret window.into_canvas().build();
    };



    const texture_creator = canvas.texture_creator();
    const texture = try texture_creator.load_texture(png);
    defer texture.deinit();

    canvas.set_draw_color_tuple( .{50,80,255,255});
    canvas.clear();
    try canvas.copy( &texture, null, null);
    canvas.present();

    
    var event_pump = try sdl_context.event_pump();
    defer event_pump.deinit();

    mainloop: while (true) {
        while (event_pump.poll_iter()) |event| {
            switch (event) {
                .Quit=> {
                    break: mainloop;
                },
                else => { },
            }
        }
    }

}

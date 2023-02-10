const std = @import("std");
const sdl2 = @import("sdl2");


pub fn main() !void {
    const sdl_context = try sdl2.init();
    defer sdl_context.deinit();
    errdefer std.log.debug("{s}\n", .{sdl2.get_error()});

    var canvas: sdl2.render.WindowCanvas = try  blk: {
        const video_subsys = try sdl_context.video();
        var w = video_subsys.window("Events", 800, 600);
        const window = try w.position_centered().resizable().build();
        
        break: blk window.into_canvas().build();
    };
    defer canvas.deinit();



    canvas.set_draw_color(sdl2.pixels.Color.RGB(255, 0, 0));
    canvas.clear();
    canvas.present();

    var event_pump = try sdl_context.event_pump();
    defer event_pump.deinit();

    mainloop: while (true) {
        while (event_pump.poll_iter()) |event| {
            switch (event) {
                .Quit=> {
                    break: mainloop;
                },
                .MouseMotion => {},
                else => |e|{
                    std.debug.print("{}\n", .{e});
                },
            }
        }


        canvas.clear();
        canvas.present();
        std.time.sleep(1_000_000_000 / 30);

    }


}
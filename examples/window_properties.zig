const std = @import("std");
const sdl2 = @import("sdl2");



pub fn main() !void {
    const sdl_context = try sdl2.init();
    defer sdl_context.deinit();

    var canvas = try ret: {
        const video_subsystem = try sdl_context.video();
        
        var w = video_subsystem.window("sdl Window", 800, 600);
        const window = try w.resizable().build();
    
        break: ret window.into_canvas().present_vsync().build();
    };
    defer canvas.deinit();


    var tick: i64 = 0;

    var event_pump = try sdl_context.event_pump();
    defer event_pump.deinit();

    const alloc = std.heap.page_allocator;

    var is_running = true;
    while (is_running) {
        while (event_pump.poll_iter()) |event| {
            switch (event) {
                .Quit=> {
                    is_running = false;
                },
                .KeyDown => |kd|{
                    if (kd.keycode)|kc| {
                        switch (kc) {
                            .Escape => {
                                is_running = false;
                            },
                            else => {}
                        }
                    }
                 },
                else => {},
            }
        }


        {
            const position =  canvas.window.position();
            const size = canvas.window.size();

            const title = try std.fmt.allocPrint(alloc, "Window - pos({}x{}), size({}x{}): {}", .{position[0], position[1], size[0], size[1], tick});
            defer alloc.free(title);

            canvas.window.set_title(title);

            tick += 1;
        }

        canvas.set_draw_color_tuple( .{0,0,0,0});
        canvas.clear();
        canvas.present();
    }

}
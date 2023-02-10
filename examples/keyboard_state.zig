const std = @import("std");
const sdl2 = @import("sdl2");


pub fn main() !void {
    const allocator =  std.heap.c_allocator;

    const sdl_context = try sdl2.init();
    defer sdl_context.deinit();
    errdefer std.log.debug("{s}\n", .{sdl2.get_error()});

    const video_subsys = try sdl_context.video();
    var w = video_subsys.window("Keyboard", 800, 600);
    const window = try w.position_centered().build();
    defer window.deinit();

    var events = try sdl_context.event_pump();
    defer events.deinit();

    const HashSet = std.AutoArrayHashMap(sdl2.scancode.Scancode, void);

    var prev_keys = HashSet.init(allocator);
    defer prev_keys.deinit();

    const keys = events.keyboard_state();

    mainloop: while (true) {
        while (events.poll_iter()) |event| {
            switch (event) {
                .Quit => {
                    break :mainloop;
                },
                else => {},
            }
        }

        {
            var curent_keys = HashSet.init(allocator);
            defer curent_keys.deinit();

            var iter = keys.pressed_scancodes();
            while (iter.iter()) |sc| {
                curent_keys.put(sc, {}) catch unreachable;
            }

            if (curent_keys.unmanaged.entries.len != 0 or prev_keys.unmanaged.entries.len != 0) {
                std.debug.print("curent {any}\n", .{curent_keys.keys()});
                std.debug.print("prev {any}\n", .{prev_keys.keys()});
            }
            prev_keys = curent_keys.move();

        }
        std.time.sleep(100_000_000);

    }
}
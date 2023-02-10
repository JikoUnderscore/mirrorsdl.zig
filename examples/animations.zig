const std = @import("std");
const sdl2 = @import("sdl2");

pub fn main() !void {
    const sdl_context: sdl2.Sdl = try sdl2.init();
    defer sdl_context.deinit();
    errdefer std.log.debug("{s}\n", .{sdl2.get_error()});

    var canvas: sdl2.render.WindowCanvas = try cnvs: {
        const video_subsystem: sdl2.VideoSubsystem = try sdl_context.video();

        var w = video_subsystem.window("SDL2", 640, 480);
        const window = try w.position_centered().build();

        break: cnvs window.into_canvas().accelerated().build();
    };
    defer canvas.deinit();

    const texture_creator = canvas.texture_creator();

    canvas.set_draw_color_tuple(.{ 0, 0, 0, 255 });

    const timer = try sdl_context.timer();
    defer timer.deinit();

    var event_pump = try sdl_context.event_pump();
    defer event_pump.deinit();


    
    const texture = try txtr: {
        const temp_surface = try sdl2.surface.Surface.load_bmp("assets/characters.bmp");
        defer temp_surface.deinit();

        break: txtr    texture_creator.create_texture_from_surface(&temp_surface);
    };
    defer texture.deinit();

    const frames_per_anim = 4;
    const sprite_tile_size: i32 = 32;

    // Baby walk animation
    var source_rect_baby = sdl2.rect.Rect.init(0, 0, sprite_tile_size, sprite_tile_size);
    var dest_rect_baby = sdl2.rect.Rect.init(0, 0, sprite_tile_size * 4, sprite_tile_size * 4);
    dest_rect_baby.center_on_p(sdl2.rect.Point.init(-64, 120));

    // King walk animation
    var source_rect_king = sdl2.rect.Rect.init(0, 32, sprite_tile_size, sprite_tile_size);
    var dest_rect_king = sdl2.rect.Rect.init(0, 32, sprite_tile_size * 4, sprite_tile_size * 4);
    dest_rect_king.center_on_p(sdl2.rect.Point.init(0, 240));

    // Soldier walk animation
    var source_rect_soldier = sdl2.rect.Rect.init(0, 64, sprite_tile_size, sprite_tile_size);
    var dest_rect_soldier = sdl2.rect.Rect.init(0, 64, sprite_tile_size * 4, sprite_tile_size * 4);
    dest_rect_soldier.center_on_p(sdl2.rect.Point.init(440, 360));

    var running = true;
    while (running) {
        while (event_pump.poll_iter()) |event| {
            switch (event) {
                .Quit=> {
                    running = false;
                },
                .KeyDown => |kd|{
                    if (kd.keycode)|kc| {
                        switch (kc) {
                            .Escape => {
                                running = false;
                            },
                            else => {}
                        }
                    }
                 },
                else => {},
            }
        }

        const ticks = @intCast(i32, timer.ticks());

        source_rect_baby.set_x_unchecked(32 * @rem(@divTrunc(ticks, 100), frames_per_anim));
        dest_rect_baby.set_x_unchecked(1 * (@rem(@divTrunc(ticks, 14), 768)) - 128);

        source_rect_king.set_x_unchecked(32 * (@rem((@divTrunc(ticks, 100)), frames_per_anim)));
        dest_rect_king.set_x_unchecked((1 * (@rem((@divTrunc(ticks, 12)), 768)) - 672) * -1);

        source_rect_soldier.set_x_unchecked(32 * (@rem((@divTrunc(ticks, 100)), frames_per_anim)));
        dest_rect_soldier.set_x_unchecked(1 * (@rem((@divTrunc(ticks, 10)), 768)) - 128);

        canvas.clear();


        try canvas.copy_ex(&texture, source_rect_baby, dest_rect_baby, 0.0, null, false, false);
        try canvas.copy_ex(&texture, source_rect_king, dest_rect_king, 0.0, null, true, false);
        try canvas.copy_ex(&texture, source_rect_soldier, dest_rect_soldier, 0.0, null, false, false);
        canvas.present();

        std.time.sleep(100_000);
    }
}

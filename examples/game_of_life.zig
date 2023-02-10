const std = @import("std");
const sdl2 = @import("sdl2");


const PLAYGROUND_WIDTH = 49;
const PLAYGROUND_HEIGHT = 40;
const SQUARE_SIZE = 16;

const TextureColor = enum { Yellow, White };

fn lambda(texture_canvas: *sdl2.render.WindowCanvas, user_context: TextureColor) void {
    texture_canvas.set_draw_color_tuple(.{ 0, 0, 0, 255 });
    texture_canvas.clear();

    switch (user_context) {
        TextureColor.Yellow => {
            var i: u32 = 0;
            while (i < SQUARE_SIZE) : (i += 1) {
                var j: u32 = 0;
                while (j < SQUARE_SIZE) : (j += 1) {
                    if ((j + i) % 4 == 0) {
                        texture_canvas.set_draw_color(sdl2.pixels.Color.RGB(255, 255, 0));
                        texture_canvas.draw_point_unchecked(sdl2.rect.Point.init(@intCast(i32, i), @intCast(i32, j)));
                    }
                    if ((i + j * 2) % 9 == 0) {
                        texture_canvas.set_draw_color(sdl2.pixels.Color.RGB(200, 200, 0));
                        texture_canvas.draw_point_unchecked(sdl2.rect.Point.init(@intCast(i32, i), @intCast(i32, j)));
                    }
                }
            }
        },
        TextureColor.White => {
            var i: u32 = 0;
            while (i < SQUARE_SIZE) : (i += 1) {
                var j: u32 = 0;
                while (j < SQUARE_SIZE) : (j += 1) {
                    if ((j + i) % 7 == 0) {
                        texture_canvas.set_draw_color(sdl2.pixels.Color.RGB(192, 192, 192));
                        texture_canvas.draw_point_unchecked(sdl2.rect.Point.init(@intCast(i32, i), @intCast(i32, j)));
                    }
                    if ((i + j * 2) % 5 == 0) {
                        texture_canvas.set_draw_color(sdl2.pixels.Color.RGB(64, 64, 64));
                        texture_canvas.draw_point_unchecked(sdl2.rect.Point.init(@intCast(i32, i), @intCast(i32, j)));
                    }
                }
            }
        },
    }

    var i: u32 = 0;
    while (i < SQUARE_SIZE) : (i += 1) {
        var j: u32 = 0;
        while (j < SQUARE_SIZE) : (j += 1) {
            if ((j + i) % 7 == 0) {
                texture_canvas.set_draw_color(sdl2.pixels.Color.RGB(192, 192, 192));
                texture_canvas.draw_point_unchecked(sdl2.rect.Point.init(@intCast(i32, i), @intCast(i32, j)));
            }
            if ((i + j * 2) % 5 == 0) {
                texture_canvas.set_draw_color(sdl2.pixels.Color.RGB(64, 64, 64));
                texture_canvas.draw_point_unchecked(sdl2.rect.Point.init(@intCast(i32, i), @intCast(i32, j)));
            }
        }
    }
}


fn dummt_texture(canvas: *sdl2.render.WindowCanvas, texture_creator: *const sdl2.render.TextureCreator) !struct { sdl2.render.Texture, sdl2.render.Texture } {
    var squ_texture1 = try texture_creator.create_texture_target(null, SQUARE_SIZE, SQUARE_SIZE);
    var squ_texture2 = try texture_creator.create_texture_target(null, SQUARE_SIZE, SQUARE_SIZE);

    const STRU = struct { *sdl2.render.Texture, TextureColor };
    var textures = [2]STRU{
        .{ &squ_texture1, TextureColor.White },
        .{ &squ_texture2, TextureColor.Yellow },
    };

    try canvas.with_multiple_texture_canvas(STRU, TextureColor, &textures, lambda);

    return .{ squ_texture1, squ_texture2 };
}

pub fn main() !void {
    const sdl_context = try sdl2.init();
    defer sdl_context.deinit();
    errdefer std.log.debug("{s}\n", .{sdl2.get_error()});

    var canvas: sdl2.render.WindowCanvas = try blk: {
        const video_subsys = try sdl_context.video();
        var w = video_subsys.window("Game of Life", SQUARE_SIZE * PLAYGROUND_WIDTH, SQUARE_SIZE * PLAYGROUND_HEIGHT);
        const window = try w.position_centered().resizable().build();

        break :blk window.into_canvas().target_texture().present_vsync().build();
    };
    defer canvas.deinit();

    std.debug.print("Useing SDL_Renderer \"{s}\"", .{canvas.info().name});

    canvas.set_draw_color(sdl2.pixels.Color.RGB(0, 0, 100));
    canvas.clear();
    canvas.present();

    const texture_creator = canvas.texture_creator();
    const textures = try dummt_texture(&canvas, &texture_creator);
    const square_texture1: sdl2.render.Texture = textures[0];
    defer square_texture1.deinit();
    const square_texture2 = textures[1];
    defer square_texture2.deinit();

    var game = GameOfLife.init();

    var event_pump = try sdl_context.event_pump();
    defer event_pump.deinit();

    var frame: u32 = 0;
    mainloop: while (true) {
        while (event_pump.poll_iter()) |event| {
            switch (event) {
                .Quit => {
                    break :mainloop;
                },
                sdl2.events.Event.KeyDown => |kd| {
                    if (!kd.repeat) {
                        if (kd.keycode) |kc| {
                            switch (kc) {
                                sdl2.keycode.Keycode.Space => {
                                    game.toggle_state();
                                },
                                else => {},
                            }
                        }
                    }
                },

                else => {},
            }
        }

        if (frame >= 30) {
            game.update();
            frame = 0;
        }
        canvas.set_draw_color_tuple(.{ 0, 0, 0, 255 });
        canvas.clear();

        for (game.playground) |unit, i| {
            const square_texture = if (frame >= 15) &square_texture1 else &square_texture2;
            if (unit) {
                try canvas.copy(square_texture, null, sdl2.rect.Rect.init(
                    @intCast(i32, (i % PLAYGROUND_WIDTH) * SQUARE_SIZE), 
                    @intCast(i32, (i / PLAYGROUND_WIDTH) * SQUARE_SIZE),
                     SQUARE_SIZE, SQUARE_SIZE));
            }
        }
        canvas.present();
        if (game.state == State.Playing) {
            frame += 1;
        }
    }
}

const State = enum {
    Paused,
    Playing,
};

const GameOfLife = struct {
    playground: [PLAYGROUND_WIDTH * PLAYGROUND_HEIGHT]bool,
    state: State,

    pub fn init() GameOfLife {
        var pg: [PLAYGROUND_WIDTH * PLAYGROUND_HEIGHT]bool = [_]bool{false} ** (PLAYGROUND_WIDTH * PLAYGROUND_HEIGHT);

        var i: u32 = 0;
        while (i < PLAYGROUND_HEIGHT - 1) : (i += 1) {
            pg[(1 + i * PLAYGROUND_WIDTH)] = true;
            pg[((PLAYGROUND_WIDTH - 2) + i * PLAYGROUND_WIDTH)] = true;
        }

        i = 0;
        while (i < PLAYGROUND_WIDTH - 2) : (i += 1) {
            pg[(PLAYGROUND_WIDTH + i)] = true;
            pg[((PLAYGROUND_HEIGHT - 2) * PLAYGROUND_WIDTH + i)] = true;
        }

        return GameOfLife{
            .playground = pg,
            .state = State.Paused,
        };
    }

    pub fn get(self: *const GameOfLife, x: i32, y: i32) ?bool {
        return if (x >= 0 and y >= 0 and x < PLAYGROUND_WIDTH and y < PLAYGROUND_HEIGHT)
            self.playground[@intCast(usize , x + y * PLAYGROUND_WIDTH)]
        else 
            null;
    }

    pub fn update(self: *GameOfLife) void {
        
        var new_pg = self.playground;
        for (new_pg)|*square, u| {
            // const u = @intCast(u32, u_);
            const x = u % PLAYGROUND_WIDTH;
            const y = u / PLAYGROUND_WIDTH;

            var count: u32 = 0;

            var i: i32 = -1;
            while (i < 2): (i += 1) {
                var j: i32 = -1;
                while (j < 2): (j += 1) {
                    if (!(i == 0 and j == 0)) {
                        const peek_x: i32 = @intCast(i32 ,x) + i;
                        const peek_y: i32 = @intCast(i32, y) + j;
                        if (self.get(peek_x, peek_y)) |t|{
                            if (t) {
                                count += 1;
                            }
                        }
                    }
                }
            }

            if (count > 3 or count < 2) {
                square.* = false;
            } else if (count == 3) {
                square.* = true;
            } else if (count == 2) {
                square.* = square.*;
            }

        }
        self.playground = new_pg;
    }

    pub fn toggle_state(self: *GameOfLife) void {
        self.state = switch (self.state) {
            .Paused => .Playing,
            .Playing => .Paused,
        };
    }
};

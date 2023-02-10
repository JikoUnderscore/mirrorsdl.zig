const std = @import("std");
const sdl2 = @import("sdl2");
// const raw_sdl = sdl2.raw_sdl_api;

const NUM_RANDOM = 4096;

var RX: [NUM_RANDOM + 1]i16 = undefined;
var RY: [NUM_RANDOM + 1]i16 = undefined;

var TX1: [NUM_RANDOM + 1][3]i16 = undefined;
var TY1: [NUM_RANDOM + 1][3]i16 = undefined;

// made of 2 triangles
var SX1: [NUM_RANDOM + 1][6]i16 = undefined;
var SY1: [NUM_RANDOM + 1][6]i16 = undefined;

var LW: [NUM_RANDOM + 1]u8 = undefined;

var RR1: [NUM_RANDOM + 1]i16 = undefined;
var RR2: [NUM_RANDOM + 1]i16 = undefined;

var A1: [NUM_RANDOM + 1]i16 = undefined;
var A2: [NUM_RANDOM + 1]i16 = undefined;

var RR: [NUM_RANDOM + 1]u8 = undefined;
var RG: [NUM_RANDOM + 1]u8 = undefined;
var RB: [NUM_RANDOM + 1]u8 = undefined;
var RA: [NUM_RANDOM + 1]u8 = undefined;

const WIDTH = 640;
const HEIGHT = 480;

var timer: sdl2.TimerSubsystem = undefined;

pub fn main() !void {
    const sdl_context = try sdl2.init();
    defer sdl_context.deinit();
    errdefer std.log.debug("{s}\n", .{sdl2.get_error()});

    timer = try sdl_context.timer();
    defer timer.deinit();

    var canvas: sdl2.render.WindowCanvas = try ret: {
        const video_sys = try sdl_context.video();
        var w = video_sys.window("Test gfx", WIDTH, HEIGHT);
        const window = try w.position_centered().position_centered().build();

        break :ret window.into_canvas().accelerated() .build();
    };

    canvas.set_draw_color_tuple(.{ 0xA0, 0xA0, 0xA0, 0xFF });
    canvas.clear();
    // canvas.present();

    const info = canvas.info();
    std.debug.print("Useing SDL_Renderer \"{s}\", flags {} (bits {b})\n", .{ info.name, info.get_active_flags(), info.flags });
    std.debug.print("Platform: {s}\n", .{sdl2.get_platform()});

    var event_pump = try sdl_context.event_pump();
    defer event_pump.deinit();

    var is_running = true;
    var test_number: i8 = 0;
    var to_draw_it = true;

    const number_of_tests = 28;

    while (is_running) {
        while (event_pump.poll_iter()) |event| {
            switch (event) {
                .Quit => {
                    is_running = false;
                },
                .KeyDown => |kd_| {
                    const kd = kd_; // sdl2.events.Event.KeyDown

                    if (kd.keycode) |keycode| {
                        switch (keycode) {
                            .Space => {
                                test_number += 1;
                                to_draw_it = true;
                            },
                            else => {},
                        }
                    }
                },
                .MouseButtonDown => |mbd| {
                    switch (mbd.mouse_btn) {
                        .Left => {
                            test_number += 1;
                            to_draw_it = true;
                        },
                        .Right => {
                            test_number -= 1;
                            to_draw_it = true;
                        },
                        else => {},
                    }
                },
                else => {},
            }
        }

        if (to_draw_it) {
            std.debug.print("test numer {}\n", .{test_number});
            test_number = if (test_number < 0) number_of_tests - 1 else @rem(test_number, number_of_tests);

            create_random_points(test_number);

            switch (test_number) {
                0 => execute_test(&canvas, test_pixel, test_number, "Pixel"),
                1 => execute_test(&canvas, test_hline, test_number, "Hline"),
                2 => execute_test(&canvas, test_vline, test_number, "Vline"),
                3 => execute_test(&canvas, test_rectangle, test_number, "Rectangle"),
                4 => execute_test(&canvas, test_rounded_rectangle, test_number, "RoundedRectangle"),
                5 => execute_test(&canvas, test_box, test_number, "Box"),
                6 => execute_test(&canvas, test_line, test_number, "Line"),
                7 => execute_test(&canvas, test_aaline, test_number, "AALine"),
                8 => execute_test(&canvas, test_circle, test_number, "Circle"),
                9 => execute_test(&canvas, test_aacircle, test_number, "Circle"),
                10 => execute_test(&canvas, test_filled_circle, test_number, "Circle"),
                else => {},
            }

            canvas.present();

            to_draw_it = false;
        }

        timer.delay(25);
    }
}

fn create_random_points(seed: i8) void {
    var rnd = std.rand.DefaultPrng.init(@intCast(u64, seed));
    var rand = rnd.random();

    var i: usize = 0;
    while (i < NUM_RANDOM + 1) : (i += 1) {
        // Random points in a quadrant
        RX[i] = @intCast(i16, rand.int(u16) % (WIDTH / 2));
        RY[i] = @intCast(i16, rand.int(u16) % (HEIGHT / 2));

        // 5-Pixel Triangle
        TX1[i][0] = RX[i];
        TY1[i][0] = RY[i];
        TX1[i][1] = RX[i] + 1;
        TY1[i][1] = RY[i] + 2;
        TX1[i][2] = RX[i] + 2;
        TY1[i][2] = RY[i] + 1;

        // 10x10 square made from 3 triangles
        SX1[i][0] = RX[i];
        SY1[i][0] = RY[i];
        SX1[i][1] = RX[i] + 10;
        SY1[i][1] = RY[i];
        SX1[i][2] = RX[i];
        SY1[i][2] = RY[i] + 10;
        SX1[i][3] = RX[i];
        SY1[i][3] = RY[i] + 10;
        SX1[i][4] = RX[i] + 10;
        SY1[i][4] = RY[i];
        SX1[i][5] = RX[i] + 10;
        SY1[i][5] = RY[i] + 10;

        // Line widths
        LW[i] = 2 + (rand.int(u8) % 7);

        // Random Radii
        RR1[i] = @intCast(i16, rand.int(u16) % 32);
        RR2[i] = @intCast(i16, rand.int(u16) % 32);

        // Random Angles
        A1[i] = @intCast(i16, rand.int(u16) % 360);
        A2[i] = @intCast(i16, rand.int(u16) % 360);

        // Random Colors
        RR[i] = rand.int(u8) & 255;
        RG[i] = rand.int(u8) & 255;
        RB[i] = rand.int(u8) & 255;

        // X-position dependent Alpha
        const af: f32 = (@intToFloat(f32, RX[i]) / (WIDTH / 2.0));
        // std.debug.print("{d}\n", .{af});
        RA[i] = @truncate(u8, @floatToInt(u32, (255.0 * af)));
    }
}

fn execute_test(canvas: *sdl2.render.WindowCanvas, func: *const fn (canvas: *sdl2.render.WindowCanvas) i32, test_num: i32, comptime test_name: []const u8) void {
    clear_screen_and_draw_ui(canvas, test_name);

    const then = timer.ticks();
    const num_primitives = func(canvas);
    const now = timer.ticks();
    if (now > then) {
        const fps = @intCast(u32, (num_primitives * 1000)) / (now - then);
        var buf: [256]u8 = .{0} ** 256;
        const title = std.fmt.bufPrint(&buf, "Test {} {s}: {} / sec", .{ test_num, test_name, fps }) catch unreachable;
        canvas.string_polygon_tuple_unchecked(@intCast(i16, WIDTH / 2 - 4 * title.len), 30 - 4, title, .{ 255, 255, 255, 255 });
        std.debug.print("{s}\n", .{title});
    }
}

fn clear_screen_and_draw_ui(canvas: *sdl2.render.WindowCanvas, comptime title: []const u8) void {
    canvas.set_draw_color_tuple(.{ 0, 0, 0, 255 });
    canvas.clear();

    const step_x: f32 = 1.0 / (WIDTH / 2.0);
    const step_y: f32 = 1.0 / ((HEIGHT - 80.0) / 2.0);
    var fx: f32 = 0.0;
    var fy: f32 = 0.0;

    var x: i32 = WIDTH / 2;
    while (x < WIDTH) : (x += 1) {
        fy = 0.0;

        var y: i32 = (HEIGHT - 40) / 2 + 60;
        while (y < HEIGHT) : (y += 1) {
            const fxy = 1.0 - fx * fy;
            canvas.pixel_tuple_unchecked(@intCast(i16, x), @intCast(i16, y), .{ @floatToInt(u8, (128.0 * fx * fx)), @floatToInt(u8, (128.0 * fxy * fxy)), @floatToInt(u8, (128.0 * fy * fy)), 255 });
            fy += step_y;
        }
        fx += step_x;
    }

    canvas.hline_tuple_unchecked(0, WIDTH, 40 - 1, .{ 255, 255, 255, 255 });
    canvas.hline_tuple_unchecked(0, WIDTH, 60 - 1, .{ 255, 255, 255, 255 });
    canvas.hline_tuple_unchecked(0, WIDTH, (HEIGHT - 40) / 2 + 40 + 1, .{ 255, 255, 255, 255 });
    canvas.hline_tuple_unchecked(0, WIDTH, (HEIGHT - 40) / 2 + 60 - 1, .{ 255, 255, 255, 255 });
    canvas.vline_tuple_unchecked(WIDTH / 2, 40, HEIGHT, .{ 255, 255, 255, 255 });

    const title1 = "Current Primitive: " ++ title ++ "  -  Space to continue. ESC to Quit.";
    canvas.string_polygon_tuple_unchecked(WIDTH / 2 - 4 * title1.len, 10 - 4, title1, .{ 255, 255, 0, 255 });

    const title2 = "A=0-255 on Black";
    canvas.string_polygon_tuple_unchecked(WIDTH / 4 - 4 * title2.len, 50 - 4, title2, .{ 255, 255, 255, 255 });

    const title3 = "A=0-254 on Black";
    canvas.string_polygon_tuple_unchecked(3 * WIDTH / 4 - 4 * title3.len, 50 - 4, title3, .{ 255, 255, 255, 255 });

    const title4 = "A=255, Color Test";
    canvas.string_polygon_tuple_unchecked(WIDTH / 4 - 4 * title4.len, (HEIGHT - 40) / 2 + 50 - 4, title4, .{ 255, 255, 255, 255 });

    const title5 = "A=0-254 on Color";
    canvas.string_polygon_tuple_unchecked(3 * WIDTH / 4 - 4 * title5.len, (HEIGHT - 40) / 2 + 50 - 4, title5, .{ 255, 255, 255, 255 });
}

fn set_viewport(canvas: *sdl2.render.WindowCanvas, x1: i32, y1: i32, x2: i32, y2: i32) void {
    const clip = sdl2.rect.Rect.init(
        x1 + 10,
        y1 + 10,
        x2 - x1 - 2 * 10,
        y2 - y1 - 2 * 10,
    );
    canvas.set_viewport(clip);
}

fn test_pixel(canvas: *sdl2.render.WindowCanvas) i32 {
    var i: usize = 0;

    set_viewport(canvas, 0, 60, WIDTH / 2, 60 + (HEIGHT - 80) / 2);
    while (i < NUM_RANDOM) : (i += 1) {
        canvas.pixel_tuple_unchecked(RX[i], RY[i], .{ RR[i], RG[i], RB[i], 255 });
    }

    set_viewport(canvas, WIDTH / 2, 60, WIDTH, 60 + (HEIGHT - 80) / 2);
    i = 0;
    while (i < NUM_RANDOM) : (i += 1) {
        canvas.pixel_tuple_unchecked(RX[i], RY[i], .{ RR[i], RG[i], RB[i], RA[i] });
    }

    set_viewport(canvas, WIDTH / 2, 80 + (HEIGHT - 80) / 2, WIDTH, HEIGHT);
    i = 0;
    while (i < NUM_RANDOM) : (i += 1) {
        canvas.pixel_tuple_unchecked(RX[i], RY[i], .{ RR[i], RG[i], RB[i], RA[i] });
    }

    set_viewport(canvas, 0, 80 + (HEIGHT - 80) / 2, WIDTH / 2, HEIGHT);
    i = 0;
    while (i < NUM_RANDOM) : (i += 1) {
        var r: u8 = 0;
        var g: u8 = 0;
        var b: u8 = 0;
        if (RX[i] < (WIDTH / 6)) {
            r = 255;
        } else if (RX[i] < (WIDTH / 3)) {
            g = 255;
        } else {
            b = 255;
        }
        canvas.pixel_tuple_unchecked(RX[i], RY[i], .{ r, g, b, 255 });
    }

    canvas.set_viewport(null);

    // Accuracy test
    // clear_center(canvas);
    // pixelRGBA(renderer, WIDTH/2, HEIGHT/2, 255, 255, 255, 255);

    return (4 * NUM_RANDOM) / 1;
}

fn test_hline(canvas: *sdl2.render.WindowCanvas) i32 {
    var i: usize = 0;

    set_viewport(canvas, 0, 60, WIDTH / 2, 60 + (HEIGHT - 80) / 2);
    while (i < NUM_RANDOM) : (i += 2) {
        canvas.hline_tuple_unchecked(RX[i], RX[i + 1], RY[i + 1], .{ RR[i], RG[i], RB[i], 255 });
    }

    set_viewport(canvas, WIDTH / 2, 60, WIDTH, 60 + (HEIGHT - 80) / 2);
    i = 0;
    while (i < NUM_RANDOM) : (i += 2) {
        canvas.hline_tuple_unchecked(RX[i], RX[i + 1], RY[i + 1], .{ RR[i], RG[i], RB[i], RA[i] });
    }

    set_viewport(canvas, WIDTH / 2, 80 + (HEIGHT - 80) / 2, WIDTH, HEIGHT);
    i = 0;
    while (i < NUM_RANDOM) : (i += 2) {
        canvas.hline_tuple_unchecked(RX[i], RX[i + 1], RY[i + 1], .{ RR[i], RG[i], RB[i], RA[i] });
    }

    set_viewport(canvas, 0, 80 + (HEIGHT - 80) / 2, WIDTH / 2, HEIGHT);
    i = 0;
    while (i < NUM_RANDOM) : (i += 2) {
        var r: u8 = 0;
        var g: u8 = 0;
        var b: u8 = 0;
        if (RX[i] < (WIDTH / 6)) {
            r = 255;
        } else if (RX[i] < (WIDTH / 3)) {
            g = 255;
        } else {
            b = 255;
        }
        canvas.hline_tuple_unchecked(RX[i], RX[i] + RR1[i], RY[i + 1], .{ r, g, b, 255 });
    }

    canvas.set_viewport(null);

    // Accuracy test
    // ClearCenter(renderer, "1x1 pixel");
    // clear_center(canvas);
    // pixelRGBA(renderer, WIDTH/2, HEIGHT/2, 255, 255, 255, 255);

    return (4 * NUM_RANDOM) / 1;
}

fn test_vline(canvas: *sdl2.render.WindowCanvas) i32 {
    var i: usize = 0;

    set_viewport(canvas, 0, 60, WIDTH / 2, 60 + (HEIGHT - 80) / 2);
    while (i < NUM_RANDOM) : (i += 2) {
        canvas.vline_tuple_unchecked(RX[i], RY[i], RY[i + 1], .{ RR[i], RG[i], RB[i], 255 });
    }

    set_viewport(canvas, WIDTH / 2, 60, WIDTH, 60 + (HEIGHT - 80) / 2);
    i = 0;
    while (i < NUM_RANDOM) : (i += 2) {
        canvas.vline_tuple_unchecked(RX[i], RY[i], RY[i + 1], .{ RR[i], RG[i], RB[i], RA[i] });
    }

    set_viewport(canvas, WIDTH / 2, 80 + (HEIGHT - 80) / 2, WIDTH, HEIGHT);
    i = 0;
    while (i < NUM_RANDOM) : (i += 2) {
        canvas.vline_tuple_unchecked(RX[i], RY[i], RY[i + 1], .{ RR[i], RG[i], RB[i], RA[i] });
    }

    set_viewport(canvas, 0, 80 + (HEIGHT - 80) / 2, WIDTH / 2, HEIGHT);
    i = 0;
    while (i < NUM_RANDOM) : (i += 2) {
        var r: u8 = 0;
        var g: u8 = 0;
        var b: u8 = 0;
        if (RX[i] < (WIDTH / 6)) {
            r = 255;
        } else if (RX[i] < (WIDTH / 3)) {
            g = 255;
        } else {
            b = 255;
        }
        canvas.vline_tuple_unchecked(RX[i], RY[i], RY[i] + RR1[i], .{ r, g, b, 255 });
    }

    canvas.set_viewport(null);

    return (4 * NUM_RANDOM) / 1;
}

fn test_rectangle(canvas: *sdl2.render.WindowCanvas) i32 {
    set_viewport(canvas, 0, 60, WIDTH / 2, 60 + (HEIGHT - 80) / 2);
    var i: usize = 0;
    while (i < NUM_RANDOM) : (i += 2) {
        canvas.rectangle_tuple_unchecked( RX[i], RY[i], RX[i + 1], RY[i + 1], .{ RR[i], RG[i], RB[i], 255 });
    }

    set_viewport(canvas, WIDTH / 2, 60, WIDTH, 60 + (HEIGHT - 80) / 2);
    i = 0;
    while (i < NUM_RANDOM) : (i += 2) {
        canvas.rectangle_tuple_unchecked(RX[i], RY[i], RX[i + 1], RY[i + 1], .{ RR[i], RG[i], RB[i], RA[i] });
    }

    set_viewport(canvas, WIDTH / 2, 80 + (HEIGHT - 80) / 2, WIDTH, HEIGHT);
    i = 0;
    while (i < NUM_RANDOM) : (i += 2) {
        canvas.rectangle_tuple_unchecked(RX[i], RY[i], RX[i + 1], RY[i + 1], .{ RR[i], RG[i], RB[i], RA[i] });
    }

    set_viewport(canvas, 0, 80 + (HEIGHT - 80) / 2, WIDTH / 2, HEIGHT);
    i = 0;
    while (i < NUM_RANDOM) : (i += 2) {
        var r: u8 = 0;
        var g: u8 = 0;
        var b: u8 = 0;
        if (RX[i] < (WIDTH / 6)) {
            r = 255;
        } else if (RX[i] < (WIDTH / 3)) {
            g = 255;
        } else {
            b = 255;
        }
        canvas.rectangle_tuple_unchecked( RX[i], RY[i], RX[i] + RR1[i], RY[i] + RR2[i], .{ r, g, b, 255 });
    }

    canvas.set_viewport(null);

    return (4 * NUM_RANDOM) / 1;
}

fn test_rounded_rectangle(canvas: *sdl2.render.WindowCanvas) i32 {
    set_viewport(canvas, 0, 60, WIDTH / 2, 60 + (HEIGHT - 80) / 2);
    var i: usize = 0;
    while (i < NUM_RANDOM) : (i += 2) {
        canvas.rounded_rectangle_tuple_unchecked(RX[i], RY[i], RX[i + 1], RY[i + 1], 4,.{ RR[i], RG[i], RB[i], 255 });
    }

    set_viewport(canvas, WIDTH / 2, 60, WIDTH, 60 + (HEIGHT - 80) / 2);
    i = 0;
    while (i < NUM_RANDOM) : (i += 2) {
        canvas.rounded_rectangle_tuple_unchecked(RX[i], RY[i], RX[i + 1], RY[i + 1], 4, .{ RR[i], RG[i], RB[i], RA[i] });
    }

    set_viewport(canvas, WIDTH / 2, 80 + (HEIGHT - 80) / 2, WIDTH, HEIGHT);
    i = 0;
    while (i < NUM_RANDOM) : (i += 2) {
        canvas.rounded_rectangle_tuple_unchecked(RX[i], RY[i], RX[i + 1], RY[i + 1], 4, .{ RR[i], RG[i], RB[i], RA[i] });
    }

    set_viewport(canvas, 0, 80 + (HEIGHT - 80) / 2, WIDTH / 2, HEIGHT);
    i = 0;
    while (i < NUM_RANDOM) : (i += 2) {
        var r: u8 = 0;
        var g: u8 = 0;
        var b: u8 = 0;
        if (RX[i] < (WIDTH / 6)) {
            r = 255;
        } else if (RX[i] < (WIDTH / 3)) {
            g = 255;
        } else {
            b = 255;
        }
        canvas.rounded_rectangle_tuple_unchecked( RX[i], RY[i], RX[i] + RR1[i], RY[i] + RR2[i], 4, .{ r, g, b, 255 });
    }

    canvas.set_viewport(null);

    return (4 * NUM_RANDOM) / 1;
}

fn test_line(canvas: *sdl2.render.WindowCanvas) i32 {
    set_viewport(canvas, 0, 60, WIDTH / 2, 60 + (HEIGHT - 80) / 2);
    var i: usize = 0;
    while (i < NUM_RANDOM) : (i += 2) {
        canvas.line_tuple_unchecked(RX[i], RY[i], RX[i+1], RY[i+1], .{ RR[i], RG[i], RB[i], 255 });
    }

    set_viewport(canvas, WIDTH / 2, 60, WIDTH, 60 + (HEIGHT - 80) / 2);
    i = 0;
    while (i < NUM_RANDOM) : (i += 2) {
        canvas.line_tuple_unchecked(RX[i], RY[i], RX[i+1], RY[i+1],  .{ RR[i], RG[i], RB[i], RA[i] });
    }

    set_viewport(canvas, WIDTH / 2, 80 + (HEIGHT - 80) / 2, WIDTH, HEIGHT);
    i = 0;
    while (i < NUM_RANDOM) : (i += 2) {
        canvas.line_tuple_unchecked(RX[i], RY[i], RX[i+1], RY[i+1],  .{ RR[i], RG[i], RB[i], RA[i] });
    }

    set_viewport(canvas, 0, 80 + (HEIGHT - 80) / 2, WIDTH / 2, HEIGHT);
    i = 0;
    while (i < NUM_RANDOM) : (i += 2) {
        var r: u8 = 0;
        var g: u8 = 0;
        var b: u8 = 0;
        if (RX[i] < (WIDTH / 6)) {
            r = 255;
        } else if (RX[i] < (WIDTH / 3)) {
            g = 255;
        } else {
            b = 255;
        }
        canvas.line_tuple_unchecked( RX[i], RY[i], RX[i]+RR1[i], RY[i]+RR2[i],  .{ r, g, b, 255 });
    }

    canvas.set_viewport(null);

    return (4 * NUM_RANDOM) / 1;
}

fn test_box(canvas: *sdl2.render.WindowCanvas) i32 {
    set_viewport(canvas, 0, 60, WIDTH / 2, 60 + (HEIGHT - 80) / 2);
    var i: usize = 0;
    while (i < NUM_RANDOM) : (i += 2) {
        canvas.box_tuple_unchecked(RX[i], RY[i], RX[i + 1], RY[i + 1], .{ RR[i], RG[i], RB[i], 255 });
    }

    set_viewport(canvas, WIDTH / 2, 60, WIDTH, 60 + (HEIGHT - 80) / 2);
    i = 0;
    while (i < NUM_RANDOM) : (i += 2) {
        canvas.box_tuple_unchecked(RX[i], RY[i], RX[i + 1], RY[i + 1],  .{ RR[i], RG[i], RB[i], RA[i] });
    }

    set_viewport(canvas, WIDTH / 2, 80 + (HEIGHT - 80) / 2, WIDTH, HEIGHT);
    i = 0;
    while (i < NUM_RANDOM) : (i += 2) {
        canvas.box_tuple_unchecked(RX[i], RY[i], RX[i + 1], RY[i + 1],  .{ RR[i], RG[i], RB[i], RA[i] });
    }

    set_viewport(canvas, 0, 80 + (HEIGHT - 80) / 2, WIDTH / 2, HEIGHT);
    i = 0;
    while (i < NUM_RANDOM) : (i += 2) {
        var r: u8 = 0;
        var g: u8 = 0;
        var b: u8 = 0;
        if (RX[i] < (WIDTH / 6)) {
            r = 255;
        } else if (RX[i] < (WIDTH / 3)) {
            g = 255;
        } else {
            b = 255;
        }
        canvas.box_tuple_unchecked( RX[i], RY[i], RX[i] + RR1[i], RY[i] + RR2[i],  .{ r, g, b, 255 });
    }

    canvas.set_viewport(null);

    return (4 * NUM_RANDOM) / 1;
}

fn test_aaline(canvas: *sdl2.render.WindowCanvas) i32 {
    set_viewport(canvas, 0, 60, WIDTH / 2, 60 + (HEIGHT - 80) / 2);
    var i: usize = 0;
    while (i < NUM_RANDOM) : (i += 4) {
        canvas.aa_line_tuple_unchecked(RX[i], RY[i], RX[i + 1], RY[i + 1], .{ RR[i], RG[i], RB[i], 255 });
    }

    set_viewport(canvas, WIDTH / 2, 60, WIDTH, 60 + (HEIGHT - 80) / 2);
    i = 0;
    while (i < NUM_RANDOM) : (i += 4) {
        canvas.aa_line_tuple_unchecked(RX[i], RY[i], RX[i + 1], RY[i + 1],  .{ RR[i], RG[i], RB[i], RA[i] });
    }

    set_viewport(canvas, WIDTH / 2, 80 + (HEIGHT - 80) / 2, WIDTH, HEIGHT);
    i = 0;
    while (i < NUM_RANDOM) : (i += 4) {
        canvas.aa_line_tuple_unchecked(RX[i], RY[i], RX[i + 1], RY[i + 1],  .{ RR[i], RG[i], RB[i], RA[i] });
    }

    set_viewport(canvas, 0, 80 + (HEIGHT - 80) / 2, WIDTH / 2, HEIGHT);
    i = 0;
    while (i < NUM_RANDOM) : (i += 4) {
        var r: u8 = 0;
        var g: u8 = 0;
        var b: u8 = 0;
        if (RX[i] < (WIDTH / 6)) {
            r = 255;
        } else if (RX[i] < (WIDTH / 3)) {
            g = 255;
        } else {
            b = 255;
        }
        canvas.aa_line_tuple_unchecked( RX[i], RY[i], RX[i] + RR1[i], RY[i] + RR2[i],  .{ r, g, b, 255 });
    }

    canvas.set_viewport(null);

    return (4 * NUM_RANDOM) / 1;
}

fn test_circle(canvas: *sdl2.render.WindowCanvas) i32 {
    set_viewport(canvas, 0, 60, WIDTH / 2, 60 + (HEIGHT - 80) / 2);
    var i: usize = 0;
    while (i < NUM_RANDOM) : (i += 2) {
        canvas.circle_tuple_unchecked(RX[i], RY[i], RR1[i], .{ RR[i], RG[i], RB[i], 255 });
    }

    set_viewport(canvas, WIDTH / 2, 60, WIDTH, 60 + (HEIGHT - 80) / 2);
    i = 0;
    while (i < NUM_RANDOM) : (i += 2) {
        canvas.circle_tuple_unchecked(RX[i], RY[i], RR1[i],  .{ RR[i], RG[i], RB[i], RA[i] });
    }

    set_viewport(canvas, WIDTH / 2, 80 + (HEIGHT - 80) / 2, WIDTH, HEIGHT);
    i = 0;
    while (i < NUM_RANDOM) : (i += 2) {
        canvas.circle_tuple_unchecked(RX[i], RY[i], RR1[i],  .{ RR[i], RG[i], RB[i], RA[i] });
    }

    set_viewport(canvas, 0, 80 + (HEIGHT - 80) / 2, WIDTH / 2, HEIGHT);
    i = 0;
    while (i < NUM_RANDOM) : (i += 2) {
        var r: u8 = 0;
        var g: u8 = 0;
        var b: u8 = 0;
        if (RX[i] < (WIDTH / 6)) {
            r = 255;
        } else if (RX[i] < (WIDTH / 3)) {
            g = 255;
        } else {
            b = 255;
        }
        canvas.circle_tuple_unchecked( RX[i], RY[i], RR1[i],  .{ r, g, b, 255 });
    }

    canvas.set_viewport(null);

    return (4 * NUM_RANDOM) / 1;
}

fn test_aacircle(canvas: *sdl2.render.WindowCanvas) i32 {
    set_viewport(canvas, 0, 60, WIDTH / 2, 60 + (HEIGHT - 80) / 2);
    var i: usize = 0;
    while (i < NUM_RANDOM) : (i += 4) {
        canvas.aa_circle_tuple_unchecked(RX[i], RY[i], RR1[i], .{ RR[i], RG[i], RB[i], 255 });
    }

    set_viewport(canvas, WIDTH / 2, 60, WIDTH, 60 + (HEIGHT - 80) / 2);
    i = 0;
    while (i < NUM_RANDOM) : (i += 4) {
        canvas.aa_circle_tuple_unchecked(RX[i], RY[i], RR1[i],  .{ RR[i], RG[i], RB[i], RA[i] });
    }

    set_viewport(canvas, WIDTH / 2, 80 + (HEIGHT - 80) / 2, WIDTH, HEIGHT);
    i = 0;
    while (i < NUM_RANDOM) : (i += 4) {
        canvas.aa_circle_tuple_unchecked(RX[i], RY[i], RR1[i],  .{ RR[i], RG[i], RB[i], RA[i] });
    }

    set_viewport(canvas, 0, 80 + (HEIGHT - 80) / 2, WIDTH / 2, HEIGHT);
    i = 0;
    while (i < NUM_RANDOM) : (i += 4) {
        var r: u8 = 0;
        var g: u8 = 0;
        var b: u8 = 0;
        if (RX[i] < (WIDTH / 6)) {
            r = 255;
        } else if (RX[i] < (WIDTH / 3)) {
            g = 255;
        } else {
            b = 255;
        }
        canvas.aa_circle_tuple_unchecked( RX[i], RY[i], RR1[i],  .{ r, g, b, 255 });
    }

    canvas.set_viewport(null);

    return (4 * NUM_RANDOM) / 1;
}

fn test_filled_circle(canvas: *sdl2.render.WindowCanvas) i32 {
    set_viewport(canvas, 0, 60, WIDTH / 2, 60 + (HEIGHT - 80) / 2);
    var i: usize = 0;
    while (i < NUM_RANDOM) : (i += 4) {
        canvas.filled_circle_tuple_unchecked(RX[i], RY[i], RR1[i], .{ RR[i], RG[i], RB[i], 255 });
    }

    set_viewport(canvas, WIDTH / 2, 60, WIDTH, 60 + (HEIGHT - 80) / 2);
    i = 0;
    while (i < NUM_RANDOM) : (i += 4) {
        canvas.filled_circle_tuple_unchecked(RX[i], RY[i], RR1[i],  .{ RR[i], RG[i], RB[i], RA[i] });
    }

    set_viewport(canvas, WIDTH / 2, 80 + (HEIGHT - 80) / 2, WIDTH, HEIGHT);
    i = 0;
    while (i < NUM_RANDOM) : (i += 4) {
        canvas.filled_circle_tuple_unchecked(RX[i], RY[i], RR1[i],  .{ RR[i], RG[i], RB[i], RA[i] });
    }

    set_viewport(canvas, 0, 80 + (HEIGHT - 80) / 2, WIDTH / 2, HEIGHT);
    i = 0;
    while (i < NUM_RANDOM) : (i += 4) {
        var r: u8 = 0;
        var g: u8 = 0;
        var b: u8 = 0;
        if (RX[i] < (WIDTH / 6)) {
            r = 255;
        } else if (RX[i] < (WIDTH / 3)) {
            g = 255;
        } else {
            b = 255;
        }
        canvas.filled_circle_tuple_unchecked( RX[i], RY[i], RR1[i],  .{ r, g, b, 255 });
    }

    canvas.set_viewport(null);

    return (4 * NUM_RANDOM) / 1;
}

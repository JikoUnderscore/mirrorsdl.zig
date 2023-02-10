const sys = @import("./../raw_sdl.zig").sys;



pub const MouseState = struct {
    mouse_state: u32,
    x: i32,
    y: i32,



    pub fn from_sdl_state(state: u32) MouseState {
        return MouseState{
            .mouse_state= state,
            .x=0,
            .y=0,
        };
    }
};

/// https://wiki.libsdl.org/SDL2/SDL_MouseButtonEvent
pub const MouseButton = enum(u8) {
    Unknown = 0,
    Left = sys.SDL_BUTTON_LEFT,
    Middle = sys.SDL_BUTTON_MIDDLE,
    Right = sys.SDL_BUTTON_RIGHT,
    X1 = sys.SDL_BUTTON_X1,
    X2 = sys.SDL_BUTTON_X2,


    pub fn from(button: u8) MouseButton {
        return switch (button) {
            sys.SDL_BUTTON_LEFT => .Left,
            sys.SDL_BUTTON_MIDDLE => .Middle,
            sys.SDL_BUTTON_RIGHT => .Right,
            sys.SDL_BUTTON_X1 => .X1,
            sys.SDL_BUTTON_X2 => .X2,
            else => .Unknown,
        };
    }
};



pub const MouseWheelDirection = union(enum) {
    Normal,
    Flipped,
    Unknown: u32,

    pub fn from(direction: u32) MouseWheelDirection {
        return switch (direction) {
            0 => .Normal,
            1 => .Flipped,
            else => MouseWheelDirection{.Unknown=direction},
        };
    }
};
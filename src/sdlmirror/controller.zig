const sys = @import("raw_sdl.zig").sys;

/// https://wiki.libsdl.org/SDL2/SDL_GameControllerAxis
pub const Axis = enum(i8) {
    LeftX = sys.SDL_CONTROLLER_AXIS_LEFTX,
    LeftY = sys.SDL_CONTROLLER_AXIS_LEFTY,
    RightX = sys.SDL_CONTROLLER_AXIS_RIGHTX,
    RightY = sys.SDL_CONTROLLER_AXIS_RIGHTY,
    TriggerLeft = sys.SDL_CONTROLLER_AXIS_TRIGGERLEFT,
    TriggerRight = sys.SDL_CONTROLLER_AXIS_TRIGGERRIGHT,

    pub fn try_from(n: u8) ?Axis {
        return switch (n) {
            sys.SDL_CONTROLLER_AXIS_INVALID => null,
            sys.SDL_CONTROLLER_AXIS_LEFTX => Axis.LeftX,
            sys.SDL_CONTROLLER_AXIS_LEFTY => Axis.LeftY,
            sys.SDL_CONTROLLER_AXIS_RIGHTX => Axis.RightX,
            sys.SDL_CONTROLLER_AXIS_RIGHTY => Axis.RightY,
            sys.SDL_CONTROLLER_AXIS_TRIGGERLEFT => Axis.TriggerLeft,
            sys.SDL_CONTROLLER_AXIS_TRIGGERRIGHT => Axis.TriggerRight,
            // sys.SDL_CONTROLLER_AXIS_MAX => null,
            else => null,
        };
    }

    pub fn from(n: u8) Axis {
        return switch (n) {
            // sys.SDL_CONTROLLER_AXIS_INVALID => null,
            sys.SDL_CONTROLLER_AXIS_LEFTX => Axis.LeftX,
            sys.SDL_CONTROLLER_AXIS_LEFTY => Axis.LeftY,
            sys.SDL_CONTROLLER_AXIS_RIGHTX => Axis.RightX,
            sys.SDL_CONTROLLER_AXIS_RIGHTY => Axis.RightY,
            sys.SDL_CONTROLLER_AXIS_TRIGGERLEFT => Axis.TriggerLeft,
            sys.SDL_CONTROLLER_AXIS_TRIGGERRIGHT => Axis.TriggerRight,
            // sys.SDL_CONTROLLER_AXIS_MAX => null,
            else => unreachable,
        };
    }
};

/// https://wiki.libsdl.org/SDL2/SDL_GameControllerButton
pub const Button = enum(i8) {
    A = sys.SDL_CONTROLLER_BUTTON_A,
    B = sys.SDL_CONTROLLER_BUTTON_B,
    X = sys.SDL_CONTROLLER_BUTTON_X,
    Y = sys.SDL_CONTROLLER_BUTTON_Y,
    Back = sys.SDL_CONTROLLER_BUTTON_BACK,
    Guide = sys.SDL_CONTROLLER_BUTTON_GUIDE,
    Start = sys.SDL_CONTROLLER_BUTTON_START,
    LeftStick = sys.SDL_CONTROLLER_BUTTON_LEFTSTICK,
    RightStick = sys.SDL_CONTROLLER_BUTTON_RIGHTSTICK,
    LeftShoulder = sys.SDL_CONTROLLER_BUTTON_LEFTSHOULDER,
    RightShoulder = sys.SDL_CONTROLLER_BUTTON_RIGHTSHOULDER,
    DPadUp = sys.SDL_CONTROLLER_BUTTON_DPAD_UP,
    DPadDown = sys.SDL_CONTROLLER_BUTTON_DPAD_DOWN,
    DPadLeft = sys.SDL_CONTROLLER_BUTTON_DPAD_LEFT,
    DPadRight = sys.SDL_CONTROLLER_BUTTON_DPAD_RIGHT,
    Misc1 = sys.SDL_CONTROLLER_BUTTON_MISC1,
    Paddle1 = sys.SDL_CONTROLLER_BUTTON_PADDLE1,
    Paddle2 = sys.SDL_CONTROLLER_BUTTON_PADDLE2,
    Paddle3 = sys.SDL_CONTROLLER_BUTTON_PADDLE3,
    Paddle4 = sys.SDL_CONTROLLER_BUTTON_PADDLE4,
    Touchpad = sys.SDL_CONTROLLER_BUTTON_TOUCHPAD,

    pub fn from(n: u8) Button {
        return switch (n) {
            sys.SDL_CONTROLLER_BUTTON_A => .A,
            sys.SDL_CONTROLLER_BUTTON_B => .B,
            sys.SDL_CONTROLLER_BUTTON_X => .X,
            sys.SDL_CONTROLLER_BUTTON_Y => .Y,
            sys.SDL_CONTROLLER_BUTTON_BACK => .Back,
            sys.SDL_CONTROLLER_BUTTON_GUIDE => .Guide,
            sys.SDL_CONTROLLER_BUTTON_START => .Start,
            sys.SDL_CONTROLLER_BUTTON_LEFTSTICK => .LeftStick,
            sys.SDL_CONTROLLER_BUTTON_RIGHTSTICK => .RightStick,
            sys.SDL_CONTROLLER_BUTTON_LEFTSHOULDER => .LeftShoulder,
            sys.SDL_CONTROLLER_BUTTON_RIGHTSHOULDER => .RightShoulder,
            sys.SDL_CONTROLLER_BUTTON_DPAD_UP => .DPadUp,
            sys.SDL_CONTROLLER_BUTTON_DPAD_DOWN => .DPadDown,
            sys.SDL_CONTROLLER_BUTTON_DPAD_LEFT => .DPadLeft,
            sys.SDL_CONTROLLER_BUTTON_DPAD_RIGHT => .DPadRight,
            sys.SDL_CONTROLLER_BUTTON_MISC1 => .Misc1,
            sys.SDL_CONTROLLER_BUTTON_PADDLE1 => .Paddle1,
            sys.SDL_CONTROLLER_BUTTON_PADDLE2 => .Paddle2,
            sys.SDL_CONTROLLER_BUTTON_PADDLE3 => .Paddle3,
            sys.SDL_CONTROLLER_BUTTON_PADDLE4 => .Paddle4,
            sys.SDL_CONTROLLER_BUTTON_TOUCHPAD => .Touchpad,
            else => unreachable,
        };
    }

    pub fn try_from(n: u8) ?Button {
        return switch (n) {
            sys.SDL_CONTROLLER_BUTTON_A => .A,
            sys.SDL_CONTROLLER_BUTTON_B => .B,
            sys.SDL_CONTROLLER_BUTTON_X => .X,
            sys.SDL_CONTROLLER_BUTTON_Y => .Y,
            sys.SDL_CONTROLLER_BUTTON_BACK => .Back,
            sys.SDL_CONTROLLER_BUTTON_GUIDE => .Guide,
            sys.SDL_CONTROLLER_BUTTON_START => .Start,
            sys.SDL_CONTROLLER_BUTTON_LEFTSTICK => .LeftStick,
            sys.SDL_CONTROLLER_BUTTON_RIGHTSTICK => .RightStick,
            sys.SDL_CONTROLLER_BUTTON_LEFTSHOULDER => .LeftShoulder,
            sys.SDL_CONTROLLER_BUTTON_RIGHTSHOULDER => .RightShoulder,
            sys.SDL_CONTROLLER_BUTTON_DPAD_UP => .DPadUp,
            sys.SDL_CONTROLLER_BUTTON_DPAD_DOWN => .DPadDown,
            sys.SDL_CONTROLLER_BUTTON_DPAD_LEFT => .DPadLeft,
            sys.SDL_CONTROLLER_BUTTON_DPAD_RIGHT => .DPadRight,
            sys.SDL_CONTROLLER_BUTTON_MISC1 => .Misc1,
            sys.SDL_CONTROLLER_BUTTON_PADDLE1 => .Paddle1,
            sys.SDL_CONTROLLER_BUTTON_PADDLE2 => .Paddle2,
            sys.SDL_CONTROLLER_BUTTON_PADDLE3 => .Paddle3,
            sys.SDL_CONTROLLER_BUTTON_PADDLE4 => .Paddle4,
            sys.SDL_CONTROLLER_BUTTON_TOUCHPAD => .Touchpad,
            else => null,
        };
    }
};

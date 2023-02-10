const std = @import("std");
const sys = @import("raw_sdl.zig").sys;

const SDLError = @import("errors.zig").SDLError;

const Keycode = @import("keyboard/keycode.zig").Keycode;
const Scancode = @import("keyboard/scancode.zig").Scancode;
const Mods = @import("keyboard/keyboard.zig").Mods;
// const Mod = @import("keyboard/keyboard.zig").Mod;
const KeyboardState = @import("keyboard/keyboard.zig").KeyboardState;
const HatState = @import("joystick.zig").HatState;
const Axis = @import("controller.zig").Axis;
const Button = @import("controller.zig").Button;

const string = @import("sdl.zig").string;
const MouseState = @import("sdl.zig").mouse.MouseState;
const MouseButton = @import("sdl.zig").mouse.MouseButton;
const MouseWheelDirection = @import("sdl.zig").mouse.MouseWheelDirection;

const c_void = anyopaque;


var IS_EVENT_PUMP_ALIVE: bool = false;

pub const EventPump = struct {
    
    /// https://wiki.libsdl.org/SDL2/SDL_InitSubSystem
    pub fn init() SDLError!EventPump {
        if (IS_EVENT_PUMP_ALIVE) {
            return SDLError.There_can_only_be_one_EventPump;
        } else {
            const result = sys.SDL_InitSubSystem(sys.SDL_INIT_EVENTS);

            if (result == 0) {
                IS_EVENT_PUMP_ALIVE = true;

                return EventPump{};
            } else {
                return SDLError.SDL_InitSubSystem_EventPump_Err;
            }
        }
    }

    /// https://wiki.libsdl.org/SDL2/SDL_QuitSubSystem
    pub fn deinit(_: EventPump) void {
        // assert
        if (IS_EVENT_PUMP_ALIVE == false) {
            @panic("EventPump already close, there can be only one");
        }
        sys.SDL_QuitSubSystem(sys.SDL_INIT_EVENTS);
        IS_EVENT_PUMP_ALIVE = false;
    }

    pub fn is_event_enabled(_: EventPump, event_type:  EventType) bool {
        const res = sys.SDL_EventState(@enumToInt(event_type), sys.SDL_QUERY);

        return res != sys.SDL_DISABLE;
    }

    /// Returns if the event type was enabled before the call.
    pub fn enable_event(_: EventPump, event_type: EventType) bool {
        const res = sys.SDL_EventState(@enumToInt(event_type), sys.SDL_ENABLE);
        
        return res != sys.SDL_DISABLE;
    }

    /// Returns if the event type was enabled before the call.
    pub fn disable_event(_: EventPump, event_type: EventType) bool {
        const res = sys.SDL_EventState(@enumToInt(event_type), sys.SDL_DISABLE);
        
        return res != sys.SDL_DISABLE;
    }

    /// https://wiki.libsdl.org/SDL2/SDL_Event
    pub fn poll_iter(_: EventPump) ?Event {
        var event: sys.SDL_Event = undefined;
        if (sys.SDL_PollEvent(&event) == 1) {
            return from_raw_event(event);
        }
        return null;
    }

    pub fn pump_events(_: EventPump) void {
        sys.SDL_PumpEvents();
    }

    pub fn wait_event_timeout(_: EventPump, timeout: u32) ?Event {
        var event: sys.SDL_Event = undefined;
        if (sys.SDL_WaitEventTimeout(&event, @intCast(i32, timeout)) == 1) {
            return from_raw_event(event);
        }
        return null;
    }

    pub fn wait_iter(_: EventPump) ?Event {
        var event: sys.SDL_Event = undefined;
        if (sys.SDL_WaitEvent(&event) == 1) {
            return from_raw_event(event);
        }
        return null;
    }

    pub fn keyboard_state(_: EventPump) KeyboardState {
        return KeyboardState.init();
    }
    
    pub fn mouse_state(_: EventPump) void {
        @panic("todo");
    }

    pub fn relative_mouse_state(_: EventPump) void {
        @panic("todo");
    }

};

fn from_raw_event(event_raw: sys.SDL_Event) Event {
    const raw_type = event_raw.type;

    return switch (raw_type) {
        sys.SDL_QUIT => Event{.Quit = .{ .timestamp = event_raw.quit.timestamp }},
        sys.SDL_APP_TERMINATING => Event{.AppTerminating= .{ .timestamp = event_raw.common.timestamp }},
        sys.SDL_APP_LOWMEMORY => Event{.AppLowMemory= .{ .timestamp = event_raw.common.timestamp }},
        sys.SDL_APP_WILLENTERBACKGROUND => Event{.AppWillEnterBackground = .{ .timestamp = event_raw.common.timestamp }},
        sys.SDL_APP_DIDENTERBACKGROUND => Event{.AppDidEnterBackground = .{ .timestamp = event_raw.common.timestamp }},
        sys.SDL_APP_WILLENTERFOREGROUND => Event{.AppWillEnterForeground = .{ .timestamp = event_raw.common.timestamp }},
        sys.SDL_APP_DIDENTERFOREGROUND => Event{.AppDidEnterForeground = .{ .timestamp = event_raw.common.timestamp }},

        sys.SDL_DISPLAYEVENT => Event{.Display = .{
            .timestamp = @intCast(u32, event_raw.display.timestamp),
            .display_index = @intCast(i32, event_raw.display.display),
            .display_event = DisplayEvent.None,
        }},

        sys.SDL_WINDOWEVENT => Event{.Window= .{
            .timestamp=event_raw.window.timestamp,
            .window_id=event_raw.window.windowID,
            .win_event=WindowEvent.from(event_raw.window.event, event_raw.window.data1,event_raw.window.data2)
        }},

        sys.SDL_KEYDOWN => Event{.KeyDown= .{
            .timestamp=event_raw.key.timestamp,
            .window_id=event_raw.key.windowID,
            .keycode= Keycode.from_i32(event_raw.key.keysym.sym),
            .scancode= Scancode.from_i32(@intCast(i32, event_raw.key.keysym.scancode)),
            .keymod = event_raw.key.keysym.mod,
            .repeat=event_raw.key.repeat != 0,
        }},
        sys.SDL_KEYUP => Event{.KeyUp= .{
            .timestamp= event_raw.key.timestamp,
            .window_id= event_raw.key.windowID,
            .keycode= Keycode.from_i32(event_raw.key.keysym.sym),
            .scancode= Scancode.from_i32(@intCast(i32, event_raw.key.keysym.scancode)),
            .keymod= event_raw.key.keysym.mod,
            .repeat= event_raw.key.repeat != 0,
        }},
        sys.SDL_TEXTEDITING => {
            var text= std.BoundedArray(u8, 32).init(0) catch unreachable;
            for (event_raw.edit.text)|c| {
                if (c == 0) {
                    break;
                }
                text.append(c) catch unreachable;
            }
            
            return Event{.TextEditing= .{
                .timestamp=event_raw.edit.timestamp,
                .window_id=event_raw.edit.windowID,
                .text=text, 
                .start= event_raw.edit.start,
                .length= event_raw.edit.length,
                }
            };
        },
        sys.SDL_TEXTINPUT => {
            var text= std.BoundedArray(u8, 32).init(0) catch unreachable;
            for (event_raw.edit.text)|c| {
                if (c == 0) {
                    break;
                }
                text.append(c) catch unreachable;
            }
            
            return Event{.TextInput= .{
                .timestamp= event_raw.edit.timestamp,
                .window_id=event_raw.edit.windowID,
                .text=text, 
                }
            };
        },

        sys.SDL_MOUSEMOTION => Event{.MouseMotion= .{
            .timestamp=event_raw.motion.timestamp,
            .window_id=event_raw.motion.windowID,
            .which=event_raw.motion.which,
            .mousestate= MouseState.from_sdl_state(event_raw.motion.state),
            .x=event_raw.motion.x,
            .y=event_raw.motion.y,
            .xrel=event_raw.motion.xrel,
            .yrel=event_raw.motion.yrel,
        }},
        sys.SDL_MOUSEBUTTONDOWN => Event{.MouseButtonDown= .{
            .timestamp=event_raw.button.timestamp,
            .window_id=event_raw.button.windowID,
            .which=event_raw.button.which,
            .mouse_btn= MouseButton.from(event_raw.button.button),
            .clicks= event_raw.button.clicks,
            .x=event_raw.button.x,
            .y=event_raw.button.y,
        }},
        sys.SDL_MOUSEBUTTONUP => Event{.MouseButtonUp= .{
            .timestamp=event_raw.button.timestamp,
            .window_id=event_raw.button.windowID,
            .which=event_raw.button.which,
            .mouse_btn=MouseButton.from(event_raw.button.button),
            .clicks=event_raw.button.clicks,
            .x=event_raw.button.x,
            .y=event_raw.button.y,
        }},
        sys.SDL_MOUSEWHEEL => Event{.MouseWheel= .{
            .timestamp= event_raw.wheel.timestamp,
            .window_id= event_raw.wheel.windowID,
            .which= event_raw.wheel.which,
            .x= event_raw.wheel.x,
            .y= event_raw.wheel.y,
            .direction= MouseWheelDirection.from(event_raw.wheel.direction),
        }},

        sys.SDL_JOYAXISMOTION => Event{.JoyAxisMotion= .{
            .timestamp= event_raw.jaxis.timestamp,
            .which= @intCast(u32, event_raw.jaxis.which),
            .axis_idx= event_raw.jaxis.axis,
            .value= event_raw.jaxis.value,
        }},
        sys.SDL_JOYBALLMOTION => Event{.JoyBallMotion= .{
            .timestamp= event_raw.jball.timestamp,
            .which= @intCast(u32, event_raw.jball.which),
            .ball_idx= event_raw.jball.ball,
            .xrel= event_raw.jball.xrel,
            .yrel= event_raw.jball.yrel,
        }},
        sys.SDL_JOYHATMOTION => Event{.JoyHatMotion= .{
            .timestamp= event_raw.jhat.timestamp,
            .which= @intCast(u32, event_raw.jhat.which),
            .hat_idx= event_raw.jhat.hat,
            .state= HatState.from(event_raw.jhat.value),
        }},
        sys.SDL_JOYBUTTONDOWN => Event{.JoyButtonDown= .{
            .timestamp= event_raw.jbutton.timestamp,
            .which= @intCast(u32, event_raw.jbutton.which),
            .button_idx= event_raw.jbutton.button,            
        }},
        sys.SDL_JOYBUTTONUP => Event{.JoyButtonUp= .{
            .timestamp= event_raw.jbutton.timestamp,
            .which= @intCast(u32, event_raw.jbutton.which),
            .button_idx= event_raw.jbutton.button,
        }},
        sys.SDL_JOYDEVICEADDED => Event{.JoyDeviceAdded= .{
            .timestamp= event_raw.jdevice.timestamp,
            .which= @intCast(u32, event_raw.jdevice.which),
        }},
        sys.SDL_JOYDEVICEREMOVED => Event{.JoyDeviceRemoved= .{
            .timestamp= event_raw.jdevice.timestamp,
            .which= @intCast(u32, event_raw.jdevice.which),
        }},

        sys.SDL_CONTROLLERAXISMOTION => Event{.ControllerAxisMotion= .{
            .timestamp= event_raw.caxis.timestamp,
            .which= @intCast(u32, event_raw.caxis.which),
            .axis= Axis.from(event_raw.caxis.axis),
            .value= event_raw.caxis.value,
        }},
        sys.SDL_CONTROLLERBUTTONDOWN => Event{.ControllerButtonDown= .{
            .timestamp= event_raw.cbutton.timestamp,
            .which= @intCast(u32, event_raw.cbutton.which) ,
            .button= Button.from(event_raw.cbutton.button),
        }},
        sys.SDL_CONTROLLERBUTTONUP => Event{.ControllerButtonUp= .{
            .timestamp= event_raw.cbutton.timestamp,
            .which= @intCast(u32, event_raw.cbutton.which) ,
            .button= Button.from(event_raw.cbutton.button),
        }},
        sys.SDL_CONTROLLERDEVICEADDED => Event{.ControllerDeviceAdded= .{
            .timestamp= event_raw.cdevice.timestamp,
            .which= @intCast(u32, event_raw.cdevice.which) ,
        }},
        sys.SDL_CONTROLLERDEVICEREMOVED => Event{.ControllerDeviceRemoved= .{
            .timestamp=event_raw.cdevice.timestamp,
            .which= @intCast(u32, event_raw.cdevice.which), 
        }},
        sys.SDL_CONTROLLERDEVICEREMAPPED => Event{.ControllerDeviceRemapped= .{
            .timestamp=event_raw.cdevice.timestamp,
            .which= @intCast(u32, event_raw.cdevice.which),  
        }},

        sys.SDL_FINGERDOWN => Event{.FingerDown= .{
            .timestamp= event_raw.tfinger.timestamp,
            .touch_id= event_raw.tfinger.touchId,
            .finger_id= event_raw.tfinger.fingerId,
            .x= event_raw.tfinger.x,
            .y= event_raw.tfinger.y,
            .dx= event_raw.tfinger.dx,
            .dy= event_raw.tfinger.dy,
            .pressure= event_raw.tfinger.pressure,
        }},
        sys.SDL_FINGERUP => Event{.FingerUp= .{
            .timestamp= event_raw.tfinger.timestamp,
            .touch_id= event_raw.tfinger.touchId,
            .finger_id= event_raw.tfinger.fingerId,
            .x= event_raw.tfinger.x,
            .y= event_raw.tfinger.y,
            .dx= event_raw.tfinger.dx,
            .dy= event_raw.tfinger.dy,
            .pressure= event_raw.tfinger.pressure,
        }},
        sys.SDL_FINGERMOTION => Event{.FingerMotion= .{
            .timestamp= event_raw.tfinger.timestamp,
            .touch_id= event_raw.tfinger.touchId,
            .finger_id= event_raw.tfinger.fingerId,
            .x= event_raw.tfinger.x,
            .y= event_raw.tfinger.y,
            .dx= event_raw.tfinger.dx,
            .dy= event_raw.tfinger.dy,
            .pressure= event_raw.tfinger.pressure,
        }},
        sys.SDL_DOLLARGESTURE => Event{.DollarGesture= .{
            .timestamp= event_raw.dgesture.timestamp,
            .touch_id= event_raw.dgesture.touchId,
            .gesture_id= event_raw.dgesture.gestureId,
            .num_fingers= event_raw.dgesture.numFingers,
            .err= event_raw.dgesture.@"error",
            .x= event_raw.dgesture.x,
            .y= event_raw.dgesture.y,
        }},
        sys.SDL_DOLLARRECORD => Event{.DollarRecord= .{
            .timestamp= event_raw.dgesture.timestamp,
            .touch_id= event_raw.dgesture.touchId,
            .gesture_id= event_raw.dgesture.gestureId,
            .num_fingers= event_raw.dgesture.numFingers,
            .err= event_raw.dgesture.@"error",
            .x= event_raw.dgesture.x,
            .y= event_raw.dgesture.y,
        }},
        sys.SDL_MULTIGESTURE => Event{.MultiGesture= .{
            .timestamp= event_raw.mgesture.timestamp,
            .touch_id= event_raw.mgesture.touchId,
            .d_theta= event_raw.mgesture.dTheta,
            .d_dist= event_raw.mgesture.dDist,
            .x= event_raw.mgesture.x,
            .y= event_raw.mgesture.y,
            .num_fingers= event_raw.mgesture.numFingers,
        }},

        sys.SDL_CLIPBOARDUPDATE => Event{.ClipboardUpdate= .{
            .timestamp= event_raw.common.timestamp,
        }},
        sys.SDL_DROPFILE => Event{.DropFile= .{
            .timestamp= event_raw.drop.timestamp,
            .window_id= event_raw.drop.windowID,
            .filename=  std.mem.span(event_raw.drop.file),  // TODO: see if the string is owned, used after free?
        }},
        sys.SDL_DROPTEXT => Event{.DropText= .{
            .timestamp= event_raw.drop.timestamp,
            .window_id= event_raw.drop.windowID,
            .filename= std.mem.span(event_raw.drop.file),  // TODO: see if the string is owned, used after free?
        }},
        sys.SDL_DROPBEGIN => Event{.DropBegin= .{
            .timestamp= event_raw.drop.timestamp,
            .window_id= event_raw.drop.windowID,
        }},
        sys.SDL_DROPCOMPLETE => Event{.DropComplete= .{
            .timestamp= event_raw.drop.timestamp,
            .window_id= event_raw.drop.windowID,
        }},

        sys.SDL_AUDIODEVICEADDED => Event{.AudioDeviceAdded= .{
            .timestamp= event_raw.adevice.timestamp,
            .which= event_raw.adevice.which,
            .iscapture = event_raw.adevice.iscapture != 0,
        }},
        sys.SDL_AUDIODEVICEREMOVED => Event{.AudioDeviceRemoved= .{
            .timestamp= event_raw.adevice.timestamp,
            .which= event_raw.adevice.which,
            .iscapture=  event_raw.adevice.iscapture != 0,
        }},

        sys.SDL_RENDER_TARGETS_RESET => Event{.RenderTargetsReset= .{
            .timestamp= event_raw.common.timestamp,
        }},
        sys.SDL_RENDER_DEVICE_RESET => Event{.RenderDeviceReset= .{
            .timestamp= event_raw.common.timestamp,
        }},


        sys.SDL_FIRSTEVENT => @panic("unused event SDL_FIRSTEVENT"),
        sys.SDL_LASTEVENT => @panic("unused event SDL_LASTEVENT"),

    // pub const SDL_LOCALECHANGED: c_int = 263;
    // pub const SDL_SYSWMEVENT: c_int = 513;
    // pub const SDL_KEYMAPCHANGED: c_int = 772;
    // pub const SDL_TEXTEDITING_EXT: c_int = 773;
    // pub const SDL_CONTROLLERTOUCHPADDOWN: c_int = 1622;
    // pub const SDL_CONTROLLERTOUCHPADMOTION: c_int = 1623;
    // pub const SDL_CONTROLLERTOUCHPADUP: c_int = 1624;
    // pub const SDL_CONTROLLERSENSORUPDATE: c_int = 1625;

    // pub const SDL_SENSORUPDATE: c_int = 4608;
    // pub const SDL_POLLSENTINEL: c_int = 32512;



        else => ret: {
            if (raw_type < 32_768) { // SDL_USEREVENT = 32_768
                break: ret Event{.Unknown = .{ 
                    .timestamp= event_raw.common.timestamp, 
                    .type_= event_raw.common.type,
                }};
            } else {
                const event = event_raw.user;

                break: ret Event{.User= .{
                    .timestamp=event.timestamp,
                    .window_id=event.windowID,
                    .type_=raw_type,
                    .code=event.code,
                    .data1=event.data1,
                    .data2=event.data2,
                }};
            }
        }
    };


}


pub const Orientation = enum(i32) {
    /// The display orientation can’t be determined
    Unknown = sys.SDL_ORIENTATION_UNKNOWN,
    /// The display is in landscape mode, with the right side up, relative to portrait mode
    Landscape = sys.SDL_ORIENTATION_LANDSCAPE,
    /// The display is in landscape mode, with the left side up, relative to portrait mode
    LandscapeFlipped = sys.SDL_ORIENTATION_LANDSCAPE_FLIPPED,
    /// The display is in portrait mode
    Portrait = sys.SDL_ORIENTATION_PORTRAIT,
    /// The display is in portrait mode, upside down
    PortraitFlipped = sys.SDL_ORIENTATION_PORTRAIT_FLIPPED,
};

pub const DisplayEvent = union(enum) {
    None,
    Orientation: Orientation,
    Connected,
    Disconnected,
};

pub const WindowEvent = union(enum) {
    None,
    Shown,
    Hidden,
    Exposed,
    Moved: struct{ i32, i32 },
    Resized: struct{ i32, i32 },
    SizeChanged: struct{ i32, i32 },
    Minimized,
    Maximized,
    Restored,
    Enter,
    Leave,
    FocusGained,
    FocusLost,
    Close,
    TakeFocus,
    HitTest,

    pub fn from(id: u8, data1: i32, data2: i32) WindowEvent {
        return switch (id) {
            0 => WindowEvent.None,
            1 => WindowEvent.Shown,
            2 => WindowEvent.Hidden,
            3 => WindowEvent.Exposed,
            4 => WindowEvent{.Moved=.{data1, data2}},
            5 => WindowEvent{.Resized= .{data1, data2}} ,
            6 => WindowEvent{.SizeChanged= .{data1, data2}},
            7 => WindowEvent.Minimized,
            8 => WindowEvent.Maximized,
            9 => WindowEvent.Restored,
            10 => WindowEvent.Enter,
            11 => WindowEvent.Leave,
            12 => WindowEvent.FocusGained,
            13 => WindowEvent.FocusLost,
            14 => WindowEvent.Close,
            15 => WindowEvent.TakeFocus,
            16 => WindowEvent.HitTest,
            else => WindowEvent.None,
        };
    }
};


pub const Event = union(enum) {
    Quit: struct {
        timestamp: u32,
    },
    AppTerminating: struct {
        timestamp: u32,
    },
    AppLowMemory: struct {
        timestamp: u32,
    },
    AppWillEnterBackground: struct {
        timestamp: u32,
    },
    AppDidEnterBackground: struct {
        timestamp: u32,
    },
    AppWillEnterForeground: struct {
        timestamp: u32,
    },
    AppDidEnterForeground: struct {
        timestamp: u32,
    },

    Display: struct {
        timestamp: u32,
        display_index: i32,
        display_event: DisplayEvent,
    },
    Window: struct {
        timestamp: u32,
        window_id: u32,
        win_event: WindowEvent,
    },
    // TODO: SysWMEvent
    KeyDown: struct {
        timestamp: u32,
        window_id: u32,
        keycode: ?Keycode,
        scancode: ?Scancode,
        keymod: Mods, //Mod, TODO: Make to use `Mod` type
        repeat: bool,
    },
    KeyUp: struct {
        timestamp: u32,
        window_id: u32,
        keycode: ?Keycode,
        scancode: ?Scancode,
        keymod: Mods, //Mod, TODO: Make to use `Mod` type
        repeat: bool,
    },

    TextEditing: struct {
        timestamp: u32,
        window_id: u32,
        text: std.BoundedArray(u8, 32),
        start: i32,
        length: i32,
    },

    TextInput: struct {
        timestamp: u32,
        window_id: u32,
        text: std.BoundedArray(u8, 32),
    },

    MouseMotion: struct {
        timestamp: u32,
        window_id: u32,
        which: u32,
        mousestate: MouseState,
        x: i32,
        y: i32,
        xrel: i32,
        yrel: i32,
    },

    MouseButtonDown: struct {
        timestamp: u32,
        window_id: u32,
        which: u32,
        mouse_btn: MouseButton,
        clicks: u8,
        x: i32,
        y: i32,
    },
    MouseButtonUp: struct {
        timestamp: u32,
        window_id: u32,
        which: u32,
        mouse_btn: MouseButton,
        clicks: u8,
        x: i32,
        y: i32,
    },

    MouseWheel: struct {
        timestamp: u32,
        window_id: u32,
        which: u32,
        x: i32,
        y: i32,
        direction: MouseWheelDirection,
    },

    JoyAxisMotion: struct {
        timestamp: u32,
        /// The joystick's `id`
        which: u32,
        axis_idx: u8,
        value: i16,
    },

    JoyBallMotion: struct {
        timestamp: u32,
        /// The joystick's `id`
        which: u32,
        ball_idx: u8,
        xrel: i16,
        yrel: i16,
    },

    JoyHatMotion: struct {
        timestamp: u32,
        /// The joystick's `id`
        which: u32,
        hat_idx: u8,
        state: HatState,
    },

    JoyButtonDown: struct {
        timestamp: u32,
        /// The joystick's `id`
        which: u32,
        button_idx: u8,
    },
    JoyButtonUp: struct {
        timestamp: u32,
        /// The joystick's `id`
        which: u32,
        button_idx: u8,
    },

    JoyDeviceAdded: struct {
        timestamp: u32,
        /// The newly added joystick's `joystick_index`
        which: u32,
    },
    JoyDeviceRemoved: struct {
        timestamp: u32,
        /// The joystick's `id`
        which: u32,
    },

    ControllerAxisMotion: struct {
        timestamp: u32,
        /// The controller's joystick `id`
        which: u32,
        axis: Axis,
        value: i16,
    },

    ControllerButtonDown: struct {
        timestamp: u32,
        /// The controller's joystick `id`
        which: u32,
        button: Button,
    },
    ControllerButtonUp: struct {
        timestamp: u32,
        /// The controller's joystick `id`
        which: u32,
        button: Button,
    },

    ControllerDeviceAdded: struct {
        timestamp: u32,
        /// The newly added controller's `joystick_index`
        which: u32,
    },
    ControllerDeviceRemoved: struct {
        timestamp: u32,
        /// The controller's joystick `id`
        which: u32,
    },
    ControllerDeviceRemapped: struct {
        timestamp: u32,
        /// The controller's joystick `id`
        which: u32,
    },

    // // Triggered when the gyroscope or accelerometer is updated
    // #[cfg(feature = "hidapi")]
    // ControllerSensorUpdated {
    //     timestamp: u32,
    //     which: u32,
    //     sensor: crate::sensor::SensorType,
    //     /// Data from the sensor.
    //     ///
    //     /// See the `sensor` module for more information.
    //     data: [f32; 3],
    // },

    FingerDown: struct {
        timestamp: u32,
        touch_id: i64,
        finger_id: i64,
        x: f32,
        y: f32,
        dx: f32,
        dy: f32,
        pressure: f32,
    },
    FingerUp: struct {
        timestamp: u32,
        touch_id: i64,
        finger_id: i64,
        x: f32,
        y: f32,
        dx: f32,
        dy: f32,
        pressure: f32,
    },
    FingerMotion: struct {
        timestamp: u32,
        touch_id: i64,
        finger_id: i64,
        x: f32,
        y: f32,
        dx: f32,
        dy: f32,
        pressure: f32,
    },

    DollarGesture: struct {
        timestamp: u32,
        touch_id: i64,
        gesture_id: i64,
        num_fingers: u32,
        err: f32,
        x: f32,
        y: f32,
    },
    DollarRecord: struct {
        timestamp: u32,
        touch_id: i64,
        gesture_id: i64,
        num_fingers: u32,
        err: f32,
        x: f32,
        y: f32,
    },

    MultiGesture: struct {
        timestamp: u32,
        touch_id: i64,
        d_theta: f32,
        d_dist: f32,
        x: f32,
        y: f32,
        num_fingers: u16,
    },

    ClipboardUpdate: struct {
        timestamp: u32,
    },

    DropFile: struct {
        timestamp: u32,
        window_id: u32,
        filename: string,
    },
    DropText: struct {
        timestamp: u32,
        window_id: u32,
        filename: string,
    },
    DropBegin: struct {
        timestamp: u32,
        window_id: u32,
    },
    DropComplete: struct {
        timestamp: u32,
        window_id: u32,
    },

    AudioDeviceAdded: struct {
        timestamp: u32,
        which: u32,
        iscapture: bool,
    },
    AudioDeviceRemoved: struct {
        timestamp: u32,
        which: u32,
        iscapture: bool,
    },

    RenderTargetsReset: struct {
        timestamp: u32,
    },
    RenderDeviceReset: struct {
        timestamp: u32,
    },

    User: struct {
        timestamp: u32,
        window_id: u32,
        type_: u32,
        code: i32,
        data1: ?*c_void,
        data2: ?*c_void,
    },

    Unknown: struct {
        timestamp: u32,
        type_: u32,
    },
};



pub const EventType = enum(u32) {
        QUIT = sys.SDL_QUIT,
        APP_TERMINATING = sys.SDL_APP_TERMINATING,
        APP_LOWMEMORY = sys.SDL_APP_LOWMEMORY,
        APP_WILLENTERBACKGROUND = sys.SDL_APP_WILLENTERBACKGROUND,
        APP_DIDENTERBACKGROUND = sys.SDL_APP_DIDENTERBACKGROUND,
        APP_WILLENTERFOREGROUND = sys.SDL_APP_WILLENTERFOREGROUND,
        APP_DIDENTERFOREGROUND = sys.SDL_APP_DIDENTERFOREGROUND,
        DISPLAYEVENT = sys.SDL_DISPLAYEVENT,
        WINDOWEVENT = sys.SDL_WINDOWEVENT,
        KEYDOWN = sys.SDL_KEYDOWN,
        KEYUP = sys.SDL_KEYUP,
        TEXTEDITING = sys.SDL_TEXTEDITING,
        TEXTINPUT = sys.SDL_TEXTINPUT,
        MOUSEMOTION = sys.SDL_MOUSEMOTION,
        MOUSEBUTTONDOWN = sys.SDL_MOUSEBUTTONDOWN,
        MOUSEBUTTONUP = sys.SDL_MOUSEBUTTONUP,
        MOUSEWHEEL = sys.SDL_MOUSEWHEEL,
        JOYAXISMOTION = sys.SDL_JOYAXISMOTION,
        JOYBALLMOTION = sys.SDL_JOYBALLMOTION,
        JOYHATMOTION = sys.SDL_JOYHATMOTION,
        JOYBUTTONDOWN = sys.SDL_JOYBUTTONDOWN,
        JOYBUTTONUP = sys.SDL_JOYBUTTONUP,
        JOYDEVICEADDED = sys.SDL_JOYDEVICEADDED,
        JOYDEVICEREMOVED = sys.SDL_JOYDEVICEREMOVED,
        CONTROLLERAXISMOTION = sys.SDL_CONTROLLERAXISMOTION,
        CONTROLLERBUTTONDOWN = sys.SDL_CONTROLLERBUTTONDOWN,
        CONTROLLERBUTTONUP = sys.SDL_CONTROLLERBUTTONUP,
        CONTROLLERDEVICEADDED = sys.SDL_CONTROLLERDEVICEADDED,
        CONTROLLERDEVICEREMOVED = sys.SDL_CONTROLLERDEVICEREMOVED,
        CONTROLLERDEVICEREMAPPED = sys.SDL_CONTROLLERDEVICEREMAPPED,
        FINGERDOWN = sys.SDL_FINGERDOWN,
        FINGERUP = sys.SDL_FINGERUP,
        FINGERMOTION = sys.SDL_FINGERMOTION,
        DOLLARGESTURE = sys.SDL_DOLLARGESTURE,
        DOLLARRECORD = sys.SDL_DOLLARRECORD,
        MULTIGESTURE = sys.SDL_MULTIGESTURE,
        CLIPBOARDUPDATE = sys.SDL_CLIPBOARDUPDATE,
        DROPFILE = sys.SDL_DROPFILE,
        DROPTEXT = sys.SDL_DROPTEXT,
        DROPBEGIN = sys.SDL_DROPBEGIN,
        DROPCOMPLETE = sys.SDL_DROPCOMPLETE,
        AUDIODEVICEADDED = sys.SDL_AUDIODEVICEADDED,
        AUDIODEVICEREMOVED = sys.SDL_AUDIODEVICEREMOVED,
        RENDER_TARGETS_RESET = sys.SDL_RENDER_TARGETS_RESET,
        RENDER_DEVICE_RESET = sys.SDL_RENDER_DEVICE_RESET,
        FIRSTEVENT = sys.SDL_FIRSTEVENT,
        LASTEVENT = sys.SDL_LASTEVENT,
    // pub const SDL_LOCALECHANGED: c_int = 263;
    // pub const SDL_SYSWMEVENT: c_int = 513;
    // pub const SDL_KEYMAPCHANGED: c_int = 772;
    // pub const SDL_TEXTEDITING_EXT: c_int = 773;
    // pub const SDL_CONTROLLERTOUCHPADDOWN: c_int = 1622;
    // pub const SDL_CONTROLLERTOUCHPADMOTION: c_int = 1623;
    // pub const SDL_CONTROLLERTOUCHPADUP: c_int = 1624;
    // pub const SDL_CONTROLLERSENSORUPDATE: c_int = 1625;

    // pub const SDL_SENSORUPDATE: c_int = 4608;
    // pub const SDL_POLLSENTINEL: c_int = 32512;
};
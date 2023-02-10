const std = @import("std");
const sys = @import("./../raw_sdl.zig").sys;
const Rect = @import("./../rect.zig").Rect;
const Window = @import("./../render.zig").Window;
const Scancode = @import("scancode.zig").Scancode;


pub const Mods = u16; // usecase for @distinct(u16)
pub const Mod = struct {
    pub const NO_MOD: Mods = 0x0000;         // no modifier is applicable
    pub const LSHIFT_MOD: Mods = 0x0001;     // the left Shift key is down
    pub const RSHIFT_MOD: Mods = 0x0002;     // the right Shift key is down
    pub const LCTRL_MOD: Mods = 0x0040;      // the left Ctrl (Control) key is down
    pub const RCTRL_MOD: Mods = 0x0080;      // the right Ctrl (Control) key is down
    pub const LALT_MOD: Mods = 0x0100;       // the left Alt key is down
    pub const RALT_MOD: Mods = 0x0200;       // the right Alt key is down
    pub const LGUI_MOD: Mods = 0x0400;       // the left GUI key (often the Windows key) is down
    pub const RGUI_MOD: Mods = 0x0800;       // the right GUI key (often the Windows key) is down
    pub const NUM_MOD: Mods = 0x1000;        // the Num Lock key (may be located on an extended keypad) is down
    pub const CAPS_MOD: Mods = 0x2000;       // the Caps Lock key is down
    pub const MODE_MOD: Mods = 0x4000;       // the !AltGr key is down
    pub const SCROLLLOCK_MOD: Mods = 0x8000;     // the Scroll Lock key is down

    // pub const RESERVED_MOD: Mods = SCROLLLOCK_MOD;

    pub const CTRL_MOD = LCTRL_MOD | RCTRL_MOD;
    pub const SHIFT_MOD = LSHIFT_MOD | RSHIFT_MOD;
    pub const ALT_MOD = LALT_MOD | RALT_MOD;
    pub const GUI_MOD = LGUI_MOD | RGUI_MOD;
};




pub const KeyboardState = struct {
    keyboard_state: []const u8,

    pub fn init() KeyboardState {
        var len: c_int = undefined; // 512
        var state_ptr = sys.SDL_GetKeyboardState(&len);

        return KeyboardState{ 
            .keyboard_state = state_ptr[0..@intCast(usize, len)] 
        };
    }


    pub fn is_scancode_pressed(self: *const KeyboardState, scancode: Scancode) bool {
        return self.keyboard_state[@intCast(usize, scancode)] != 0;
    }


    pub fn scancodes(self: *const KeyboardState) ScancodeIterator {
        return ScancodeIterator{
            .index = 0,
            .keyboard_state = self.keyboard_state,
        };
    }

    pub fn pressed_scancodes(self: *const KeyboardState) PressedScancodeIterator {
        return PressedScancodeIterator{
            .inter = self.scancodes(),
        };
    }



};



pub const ScancodeIterator = struct {
    index: usize,
    keyboard_state: []const u8,


    pub fn iter(self: *ScancodeIterator) ?struct {Scancode, bool} {
        if (self.index < self.keyboard_state.len) {
            const i = self.index;
            self.index += 1;

            if (Scancode.from_i32(@intCast(i32, i))) |scancode| {
                const pressed = self.keyboard_state[i] != 0;

                return .{scancode, pressed};
            } else {
                return self.iter();
            }
        } else {
            return null;
        }
    }

};

pub const PressedScancodeIterator = struct {
    inter: ScancodeIterator,

    pub fn iter(self: *PressedScancodeIterator) ?Scancode {
        while (self.inter.iter()) |sc| {
            if (sc[1]) {
                return sc[0];
            }
        }
        return null;
    }
};





pub const KeyboardUtil = struct {
    pub fn focused_window_id(_: KeyboardUtil) ?u32 {
        const raw = sys.SDL_GetKeyboardFocus();

        if (raw)|r| {
            return sys.SDL_GetWindowID(r);
        } else {
            return null;
        }
    }

    pub fn mod_state(_: KeyboardUtil) Mods {
        return @intCast(Mods, sys.SDL_GetModState());
    }

    pub fn set_mod_state(_: KeyboardUtil, flags: Mods) void {
        sys.SDL_SetModState(flags);
    }
};


pub const TextInputUtil = struct {

    pub fn start(_: TextInputUtil) void {
        sys.SDL_StartTextInput();
    }

    pub fn is_active(_: TextInputUtil) bool {
        return sys.SDL_IsTextInputActive() == sys.SDL_TRUE;
    }

    pub fn stop(_: TextInputUtil) void {
        sys.SDL_StopTextInput();
    }

    pub fn set_rect(_: TextInputUtil, rect: Rect) void {
        sys.SDL_SetTextInputRect(&rect.raw);
    }

    pub fn has_screen_keyboard_support(_: TextInputUtil) bool {
        return sys.SDL_HasScreenKeyboardSupport() == sys.SDL_TRUE;
    }

    pub fn is_screen_keyboard_shown(_: TextInputUtil, window: *const Window) bool {
        return sys.SDL_IsScreenKeyboardShown(window.raw) == sys.SDL_TRUE;
    }
};
pub const  HatState = enum(u8) {
    Centered = 0,
    Up = 0x01,
    Right = 0x02,
    Down = 0x04,
    Left = 0x08,
    RightUp = 0x02 | 0x01,
    RightDown = 0x02 | 0x04,
    LeftUp = 0x08 | 0x01,
    LeftDown = 0x08 | 0x04,


    pub fn from(raw: u8) HatState {
        return switch (raw) {
            0 => .Centered,
            1 => .Up,
            2 => .Right,
            4 => .Down,
            8 => .Left,
            3 => .RightUp,
            6 => .RightDown,
            9 => .LeftUp,
            12 => .LeftDown,

            // The Xinput driver on Windows can report hat states on certain hardware that don't
            // make any sense from a gameplay perspective, and so aren't worth putting in the
            // HatState enumeration.
            else => .Centered,
        };
    }
};
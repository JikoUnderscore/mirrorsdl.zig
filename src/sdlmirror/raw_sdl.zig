pub const sys = @cImport({
    @cInclude("SDL.h");
    @cInclude("SDL_image.h");
    @cInclude("SDL_ttf.h");

    //gfx
    @cInclude("SDL2_rotozoom.h");
    @cInclude("SDL2_imageFilter.h");
    @cInclude("SDL2_gfxPrimitives_font.h");
    @cInclude("SDL2_gfxPrimitives.h");
    @cInclude("SDL2_framerate.h");
});
pub const image = sys;
pub const ttf = sys;
pub const gfx = sys;

### Windows

SDL2   
```iwr -URI https://github.com/libsdl-org/SDL/releases/download/release-2.26.2/SDL2-devel-2.26.2-VC.zip -OutFile .\SDL\SDL2-devel-2.26.2-VC.zip; Expand-Archive ".\SDL\SDL2-devel-2.26.2-VC.zip" -DestinationPath .\SDL```

SDL2_ttf   
`iwr -URI https://github.com/libsdl-org/SDL_ttf/releases/download/release-2.20.1/SDL2_ttf-devel-2.20.1-VC.zip -OutFile .\SDL\SDL2_ttf-devel-2.20.1-VC.zip; Expand-Archive ".\SDL\SDL2_ttf-devel-2.20.1-VC.zip" -DestinationPath .\SDL`

SDL2_image   
`iwr -URI https://github.com/libsdl-org/SDL_image/releases/download/release-2.6.2/SDL2_image-devel-2.6.2-VC.zip -OutFile .\SDL\SDL2_image-devel-2.6.2-VC.zip; Expand-Archive ".\SDL\SDL2_image-devel-2.6.2-VC.zip" -DestinationPath .\SDL`

[SDL2_gfx](https://sourceforge.net/projects/sdl2gfx/)   
`iwr -URI https://github.com/JikoUnderscore/SDL2_gfx/releases/download/v1.0.4/SDL2_gfx-1.0.4-windows.zip -OutFile .\SDL\SDL2_gfx-1.0.4-windows.zip; Expand-Archive ".\SDL\SDL2_gfx-1.0.4-windows.zip" -DestinationPath .\SDL`









dislike:
    function name, function paramiter and local var can not be the same name
    .\mirrorsdl.zig\src\sdlmirror\rect.zig:348,15

    Having to type
    @divExact   ->  ~/      or /E
    @divFloor   ->  !/      or /F
    @divTrunc   ->  #/      or /T
    @rem        ->  %rem
    @mod        ->  %mod
    .\mirrorsdl.zig\examples\animations.zig:80,53:

    zig:
        source_rect_baby.set_x_unchecked(32 * @rem(@divTrunc(ticks, 100), frames_per_anim));
        source_rect_baby.set_x_unchecked(32 * ((ticks #/ 100) %rem frames_per_anim));
    rust:
        source_rect_0.set_x(32 * ((ticks / 100) % frames_per_anim));
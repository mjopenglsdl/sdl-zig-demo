const c = @cImport({
    @cInclude("SDL2/SDL.h");
    @cInclude("SDL2/SDL_image.h");
});
const assert = @import("std").debug.assert;

pub fn main() !void {
    // init
    if (c.SDL_Init(c.SDL_INIT_VIDEO) != 0) {
        c.SDL_Log("Unable to initialize SDL: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    }
    defer c.SDL_Quit();

    if ((c.IMG_Init(c.IMG_INIT_PNG) & c.IMG_INIT_PNG) == 0) {
        c.SDL_Log("Unable to initialize IMG: %s", c.SDL_GetError());
        return error.IMGInitializationFailed;
    }
    defer c.IMG_Quit();

    //
    const SCREEN_WIDTH = 640;
    const SCREEN_HEIGHT = 480;
    const win = c.SDL_CreateWindow("My Game Window", c.SDL_WINDOWPOS_UNDEFINED, c.SDL_WINDOWPOS_UNDEFINED, SCREEN_WIDTH, SCREEN_HEIGHT, c.SDL_WINDOW_OPENGL) orelse
        {
        c.SDL_Log("Unable to create window: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    };
    defer c.SDL_DestroyWindow(win);

    const ren = c.SDL_CreateRenderer(win, -1, 0) orelse {
        c.SDL_Log("Unable to create renderer: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    };
    defer c.SDL_DestroyRenderer(ren);

    const zig_bmp = @embedFile("test_img");
    const rw = c.SDL_RWFromConstMem(zig_bmp, zig_bmp.len) orelse {
        c.SDL_Log("Unable to get RWFromConstMem: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    };
    defer assert(c.SDL_RWclose(rw) == 0);

    const zig_surface = c.IMG_Load_RW(rw, 0) orelse {
        c.SDL_Log("Unable to load bmp: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    };
    defer c.SDL_FreeSurface(zig_surface);

    const zig_texture = c.SDL_CreateTextureFromSurface(ren, zig_surface) orelse {
        c.SDL_Log("Unable to create texture from surface: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    };
    defer c.SDL_DestroyTexture(zig_texture);

    var quit = false;
    var event: c.SDL_Event = undefined;

    while (!quit) {
        while (c.SDL_PollEvent(&event) != 0) {
            switch (event.type) {
                c.SDL_QUIT => {
                    quit = true;
                },
                c.SDL_KEYDOWN => {
                    switch (event.key.keysym.sym) {
                        c.SDLK_ESCAPE => {
                            quit = true;
                        },
                        else => {},
                    }
                },
                else => {},
            }
        }

        _ = c.SDL_RenderClear(ren);
        _ = c.SDL_RenderCopy(ren, zig_texture, null, null);
        c.SDL_RenderPresent(ren);

        c.SDL_Delay(17);
    }
}

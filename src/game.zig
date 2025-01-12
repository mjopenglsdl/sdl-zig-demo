const c = @cImport({
    @cInclude("SDL2/SDL.h");
    @cInclude("SDL2/SDL_image.h");
});

const assert = @import("std").debug.assert;

const SCREEN_WIDTH = 640;
const SCREEN_HEIGHT = 480;

pub const Game = struct {
    win: *c.SDL_Window = undefined,
    ren: *c.SDL_Renderer = undefined,

    tex_bg: *c.SDL_Texture = undefined,

    running: bool = false,

    pub fn init(s: *Game) !void {
        if (c.SDL_Init(c.SDL_INIT_VIDEO) != 0) {
            c.SDL_Log("Unable to initialize SDL: %s", c.SDL_GetError());
            return error.SDLInitializationFailed;
        }

        if ((c.IMG_Init(c.IMG_INIT_PNG) & c.IMG_INIT_PNG) == 0) {
            c.SDL_Log("Unable to initialize IMG: %s", c.IMG_GetError());
            return error.IMGInitializationFailed;
        }

        s.win = c.SDL_CreateWindow("My Game Window", c.SDL_WINDOWPOS_UNDEFINED, c.SDL_WINDOWPOS_UNDEFINED, SCREEN_WIDTH, SCREEN_HEIGHT, c.SDL_WINDOW_OPENGL) orelse {
            c.SDL_Log("Unable to create window: %s", c.SDL_GetError());
            return error.SDLInitializationFailed;
        };

        s.ren = c.SDL_CreateRenderer(s.win, -1, 0) orelse {
            c.SDL_Log("Unable to create renderer: %s", c.SDL_GetError());
            return error.SDLInitializationFailed;
        };

        try s.loadRes();

        s.running = true;
    }

    pub fn clean(s: *Game) void {
        c.SDL_DestroyTexture(s.tex_bg);

        c.SDL_DestroyRenderer(s.ren);
        c.SDL_DestroyWindow(s.win);
        c.IMG_Quit();
        c.SDL_Quit();
    }

    pub fn run(s: *Game) void {
        var event: c.SDL_Event = undefined;

        while (s.running) {
            s.onEvent(&event);
            s.onUpdate();
            s.onRender();
            c.SDL_Delay(17);
        }
    }

    fn loadRes(s: *Game) !void {
        const f_zig_img = @embedFile("test_img");
        const rw = c.SDL_RWFromConstMem(f_zig_img, f_zig_img.len) orelse {
            c.SDL_Log("Unable to get RWFromConstMem: %s", c.SDL_GetError());
            return error.SDLInitializationFailed;
        };
        defer assert(c.SDL_RWclose(rw) == 0);

        const zig_surface = c.IMG_Load_RW(rw, 0) orelse {
            c.SDL_Log("Unable to load bmp: %s", c.SDL_GetError());
            return error.SDLInitializationFailed;
        };
        defer c.SDL_FreeSurface(zig_surface);

        s.tex_bg = c.SDL_CreateTextureFromSurface(s.ren, zig_surface) orelse {
            c.SDL_Log("Unable to create texture from surface: %s", c.SDL_GetError());
            return error.SDLInitializationFailed;
        };
    }

    fn onEvent(s: *Game, event: *c.SDL_Event) void {
        while (c.SDL_PollEvent(event) != 0) {
            switch (event.type) {
                c.SDL_QUIT => {
                    s.running = false;
                },
                c.SDL_KEYDOWN => {
                    switch (event.key.keysym.sym) {
                        c.SDLK_ESCAPE => {
                            s.running = false;
                        },
                        else => {},
                    }
                },
                else => {},
            }
        }
    }

    fn onUpdate(s: *Game) void {
        _ = s;
    }

    fn onRender(s: *Game) void {
        _ = c.SDL_RenderClear(s.ren);

        _ = c.SDL_RenderCopy(s.ren, s.tex_bg, null, null);

        c.SDL_RenderPresent(s.ren);
    }
};

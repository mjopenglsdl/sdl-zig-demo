const c = @cImport({
    @cInclude("SDL2/SDL.h");
    @cInclude("SDL2/SDL_image.h");
});

const assert = @import("std").debug.assert;

pub fn loadTex(ren: *c.SDL_Renderer, comptime res_name: []const u8) !*c.SDL_Texture {
    const f_zig_img = @embedFile(res_name);
    const rw = c.SDL_RWFromConstMem(f_zig_img, f_zig_img.len) orelse {
        c.SDL_Log("Unable to get RWFromConstMem: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    };
    defer assert(c.SDL_RWclose(rw) == 0);

    const zig_surface = c.IMG_Load_RW(rw, 0) orelse {
        c.SDL_Log("Unable to load img: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    };
    defer c.SDL_FreeSurface(zig_surface);

    const tex = c.SDL_CreateTextureFromSurface(ren, zig_surface) orelse {
        c.SDL_Log("Unable to create texture from surface: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    };

    return tex;
}

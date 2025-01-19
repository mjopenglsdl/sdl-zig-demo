const util = @import("util.zig");
const c = @cImport({
    @cInclude("SDL2/SDL.h");

    // * compiler bug: rm this line causes error (zig 0.13)
    // src/game.zig:44:27: error: expected type '*cimport.struct_SDL_Renderer', found '*cimport.struct_SDL_Renderer'
    @cInclude("SDL2/SDL_image.h");
});

pub const Actor = struct {
    current_frame: u8 = 0,
    tex: *c.SDL_Texture = undefined,

    sprite_clips: [4]c.SDL_Rect = undefined,

    pub fn init(s: *Actor) !void {
        s.sprite_clips[0] = c.SDL_Rect{ .x = 0, .y = 0, .w = 64, .h = 205 };
        s.sprite_clips[1] = c.SDL_Rect{ .x = 64, .y = 0, .w = 64, .h = 205 };
        s.sprite_clips[2] = c.SDL_Rect{ .x = 128, .y = 0, .w = 64, .h = 205 };
        s.sprite_clips[3] = c.SDL_Rect{ .x = 192, .y = 0, .w = 64, .h = 205 };
    }

    pub fn onUpdate(s: *Actor) void {
        s.current_frame = s.current_frame + 1;
        if (s.current_frame >= s.sprite_clips.len) {
            s.current_frame = 0;
        }
    }

    pub fn getRenderInfo(s: *Actor) struct { *c.SDL_Texture, c.SDL_Rect, c.SDL_Rect } {
        const dest_rect = c.SDL_Rect{ .x = 0, .y = 0, .w = 240, .h = 480 };
        return .{ s.tex, s.sprite_clips[s.current_frame], dest_rect };
    }

    pub fn clean(s: *Actor) void {
        c.SDL_DestroyTexture(s.tex);
    }
};

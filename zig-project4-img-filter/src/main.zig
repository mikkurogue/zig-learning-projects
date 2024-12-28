const c = @cImport({
    @cDefine("_NO_CRT_STDIO_INLINE", "1");
    @cInclude("stdio.h");
    @cInclude("spng.h");
});

pub fn main() !void {
    const path = "pedro_pascal.png";
    const file_descriptor = c.fopen(path, "rb");

    defer c.fclose(file_descriptor);
    errdefer c.fclose(file_descriptor);

    if (file_descriptor == null) {
        @panic("Could not open file!");
    }

    const ctx = c.spng_ctx_new(0) orelse unreachable;
    _ = c.spng_set_png_file(ctx, @ptrCast(file_descriptor));

    // make var image_header  here
    _ = get_image_header(ctx);
}

fn get_image_header(ctx: *c.spng_ctx) !c.spng_ihdr {
    var image_header: c.spng_ihdr = undefined;
    if (c.spng_get_ihdr(ctx, &image_header) != 0) {
        return error.CouldNotGetImageHeader;
    }

    return image_header;
}

fn calc_output_size(ctx: *c.spng_ctx) !u64 {
    var output_size: u64 = 0;

    const status = c.spng_decoded_image_size(ctx, c.SPNG_FMT_RGBA8, &output_size);
    if (status != 0) {
        return error.CouldNotCalculateOutputSize;
    }

    return output_size;
}

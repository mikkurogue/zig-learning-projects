const std = @import("std");
const stdin = std.io.getStdIn();
const stdout = std.io.getStdOut().writer();

const Base64 = struct {
    _table: *const [64]u8,
    pub fn init() Base64 {
        const upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        const lower = "abcdefghijklmnopqrstuvwxyz";
        const numbers_symbols = "0123456789+/";
        return Base64{
            ._table = upper ++ lower ++ numbers_symbols,
        };
    }
    /// get the character from a specific index
    pub fn _char_at(self: Base64, index: u8) u8 {
        return self._table[index];
    }
    /// Get the character index
    fn _char_index(self: Base64, char: u8) u8 {
        if (char == '=') return 64;

        var index: u8 = 0;
        for (0..63) |_| {
            if (self._char_at(index) == char) break;

            index += 1;
        }

        return index;
    }
    /// Encode []u8 to base64 string
    pub fn encode(self: Base64, allocator: std.mem.Allocator, input: []const u8) ![]u8 {
        if (input.len == 0) return "";

        const n_output = try _calc_encode_length(input);
        var output = try allocator.alloc(u8, n_output);
        var tmp_buffer = [3]u8{ 0, 0, 0 };
        var count: u8 = 0;
        var output_index: usize = 0;

        for (input, 0..) |_, i| {
            tmp_buffer[count] = input[i];
            count += 1;
            if (count == 3) {
                output[output_index] = self._char_at(tmp_buffer[0] >> 2);
                output[output_index + 1] = self._char_at(((tmp_buffer[0] & 0x03) << 4) + (tmp_buffer[1] >> 4));
                output[output_index + 2] = self._char_at(((tmp_buffer[1] & 0x0f) << 2) + (tmp_buffer[2] >> 6));
                output[output_index + 3] = self._char_at(tmp_buffer[2] & 0x3f);
                output_index += 4;
                count = 0;
            }
        }

        if (count == 1) {
            output[output_index] = self._char_at(tmp_buffer[0] >> 2);
            output[output_index + 1] = self._char_at((tmp_buffer[0] & 0x03) << 4);
            output[output_index + 2] = '=';
            output[output_index + 3] = '=';
        }

        if (count == 2) {
            output[output_index] = self._char_at(tmp_buffer[0] >> 2);
            output[output_index + 1] = self._char_at(((tmp_buffer[0] & 0x03) << 4) + (tmp_buffer[1] >> 4));
            output[output_index + 2] = self._char_at((tmp_buffer[1] & 0x0f) << 2);
            output[output_index + 3] = '=';
            output_index += 4;
        }

        return output;
    }
    /// Decode base64 string to []u8
    pub fn decode(self: Base64, allocator: std.mem.Allocator, input: []const u8) ![]u8 {
        if (input.len == 0) return "";

        const n_output = try _calc_decode_length(input);
        var tmp_buffer = [4]u8{ 0, 0, 0, 0 };
        var output = try allocator.alloc(u8, n_output);
        var count: u8 = 0;
        var output_index: u64 = 0;
        for (0..output.len) |i| {
            output[i] = 0;
        }

        for (0..input.len) |i| {
            tmp_buffer[count] = self._char_index(input[i]);
            count += 1;
            if (count == 4) {
                output[output_index] = (tmp_buffer[0] << 2) + (tmp_buffer[1] >> 4);
                if (tmp_buffer[2] != 64) {
                    output[output_index + 1] = (tmp_buffer[1] << 4) + (tmp_buffer[2] >> 2);
                }
                if (tmp_buffer[3] != 64) {
                    output[output_index + 2] = (tmp_buffer[2] << 6) + tmp_buffer[3];
                }
                output_index += 3;
                count = 0;
            }
        }

        return output;
    }
};

pub fn main() !void {
    var memory_buffer: [1000]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&memory_buffer);
    const allocator = fba.allocator();

    const text = "Testing some more shit";
    const etext = "VGVzdGluZyBzb21lIG1vcmUgc2hpdA==";

    const base64 = Base64.init();

    const encoded_text = try base64.encode(allocator, text);

    const decoded_text = try base64.decode(allocator, etext);

    try stdout.print("Encoded:: {s} \n", .{encoded_text});
    try stdout.print("Decoded:: {s} \n", .{decoded_text});

    // try stdout.print("char at index 28: {c}\n", .{base64._char_at(28)});
}

fn _calc_encode_length(input: []const u8) !usize {
    if (input.len < 3) {
        const n_output: usize = 4;
        return n_output;
    }

    const n_output: usize = try std.math.divCeil(usize, input.len, 3);
    return n_output * 4;
}

fn _calc_decode_length(input: []const u8) !usize {
    if (input.len < 4) {
        const n_output: usize = 3;
        return n_output;
    }
    const n_output: usize = try std.math.divFloor(usize, input.len, 4);

    return n_output * 3;
}

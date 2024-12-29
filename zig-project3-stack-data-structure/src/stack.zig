const std = @import("std");
const Allocator = std.mem.Allocator;

pub fn Stack(comptime T: type) type {
    return struct {
        items: []T,
        cap: usize,
        len: usize,
        allocator: Allocator,

        const Self = @This();

        pub fn init(allocator: Allocator, cap: usize) !Stack(T) {
            var buffer = try allocator.alloc(T, cap);

            return .{
                .items = buffer[0..],
                .cap = cap,
                .len = 0,
                .allocator = allocator,
            };
        }

        pub fn push(self: *Self, val: T) !void {
            if ((self.len + 1) > self.cap) {
                var new_buffer = try self.allocator.alloc(T, self.cap * 2);

                @memcpy(
                    new_buffer[0..self.cap],
                    self.items,
                );

                self.allocator.free(self.items);
                self.items = new_buffer;
                self.cap = self.cap * 2;
            }

            self.items[self.len] = val;
            self.len += 1;
        }

        pub fn pop(self: *Self) void {
            if (self.len == 0) return;

            // set the last item in the Stack (array) to undefined
            self.items[self.len - 1] = undefined;
            // cut the len by 1 and remove the undefined item (?)
            self.len -= 1;
        }

        pub fn deinit(self: *Self) void {
            self.allocator.free(self.items);
        }
    };
}

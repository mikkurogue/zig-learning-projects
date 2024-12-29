const std = @import("std");
const Allocator = std.mem.Allocator;

pub const Error = error{InsufficientCapacity};

pub fn Array(comptime T: type) type {
    return struct {
        allocator: Allocator,
        items: []T,
        len: usize,

        const Self = @This();

        pub fn init(allocator: Allocator) !Array(T) {
            var buffer = try allocator.alloc(T);

            return .{ .allocator = allocator, .items = buffer[0..], .len = 0 };
        }

        pub fn push(self: *Self, val: T) void {
            self.items[self.len] = val;
            self.len += 1;
        }

        pub fn prepend(self: *Self, val: T) void {
            // shift elements 1 place to the right each
            var i: usize = self.len;
            while (i > 0) : (i -= 1) {
                self.items[i] = self.items[i - 1];
            }

            //insert the new value
            self.items[0] = val;
            self.len += 1;
        }

        pub fn pop(self: *Self) void {
            if (self.len == 0) return;

            self.items[self.len - 1] = undefined;
            self.len -= 1;
        }

        pub fn deinit(self: *Self) void {
            self.allocator.free(self.items);
        }
    };
}

pub fn FixedArray(comptime T: type) type {
    return struct {
        allocator: Allocator,
        items: []T,
        len: usize,
        capacity: usize,

        const Self = @This();

        pub fn init(allocator: Allocator, capacity: usize) !FixedArray(T) {
            var buffer = try allocator.alloc(T, capacity);

            return .{ .allocator = allocator, .items = buffer[0..], .len = 0, .capacity = capacity };
        }

        pub fn deinit(self: *Self) void {
            self.allocator.free(self.items);
        }

        pub fn push(self: *Self, val: T) !void {
            if ((self.len + 1) > self.capacity) {
                return Error.InsufficientCapacity;
            }

            self.items[self.len] = val;
            self.len += 1;
        }

        pub fn prepend(self: *Self, val: T) !void {
            if ((self.len + 1) > self.capacity) {
                return Error.InsufficientCapacity;
            }

            // shift elements 1 place to the right each
            var i: usize = self.len;
            while (i > 0) : (i -= 1) {
                self.items[i] = self.items[i - 1];
            }

            //insert the new value
            self.items[0] = val;
            self.len += 1;
        }

        pub fn pop(self: *Self) void {
            if (self.len == 0) return;

            self.items[self.len - 1] = undefined;
            self.len -= 1;
        }
    };
}

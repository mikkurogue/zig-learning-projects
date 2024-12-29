const std = @import("std");
const Allocator = std.mem.Allocator;

pub const Error = error{InsufficientCapacity};

pub fn Array(comptime T: type) type {
    return struct {
        alloc: Allocator,
        items: []T,
        len: usize,

        const Self = @This();

        pub fn init(alloc: Allocator) !Array(T) {
            var buffer = try alloc(T);

            return .{ .alloc = alloc, .items = buffer[0..], .len = 0 };
        }

        pub fn push(self: *Self, val: T) void {
            self.items[self.len] = val;
            self.len += 1;
        }

        pub fn prepend(self: *Self, val: T) void {
            // this probably doesnt work this way, as this replaces?
            self.items[0] = val;
            self.len += 1;
        }

        pub fn pop(self: *Self) void {
            if (self.len == 0) return;

            self.items[self.len - 1] = undefined;
            self.len -= 1;
        }

        pub fn deinit(self: *Self) void {
            self.alloc.free(self.items);
        }
    };
}

pub fn FixedArray(comptime T: type) type {
    return struct {
        alloc: Allocator,
        items: []T,
        len: usize,
        cap: usize,

        const Self = @This();

        pub fn init(alloc: Allocator, capacity: usize) !FixedArray(T) {
            var buffer = try alloc(T, capacity);

            return .{ .alloc = alloc, .items = buffer[0..], .len = 0, .cap = capacity };
        }

        pub fn push(self: *Self, val: T) !void {
            if ((self.len + 1) > self.capacity) {
                return Error.InsufficientCapacity;
            }

            self.items[self.len] = val;
            self.len += 1;
        }

        pub fn prepend(self: *Self, val: T) void {
            if ((self.len + 1) > self.capacity) {
                return Error.InsufficientCapacity;
            }

            // this probably doesnt work this way, as this replaces?
            self.items[0] = val;
            self.len += 1;
        }

        pub fn pop(self: *Self) void {
            if (self.len == 0) return;

            self.items[self.len - 1] = undefined;
            self.len -= 1;
        }

        pub fn deinit(self: *Self) void {
            self.alloc.free(self.items);
        }
    };
}

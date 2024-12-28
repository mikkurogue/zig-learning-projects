const std = @import("std");
const stk = @import("stack.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    const allocator = gpa.allocator();
    const stack_u8 = stk.Stack(u32);
    var stack = try stack_u8.init(allocator, 10);
    defer stack.deinit();

    try stack.push(1);
    try stack.push(2);
    try stack.push(3);
    try stack.push(4);
    try stack.push(5);
    try stack.push(6);

    std.debug.print("stack len: {d}\n", .{stack.len});
    std.debug.print("stack capacity: {d}\n", .{stack.cap});

    stack.pop();
    std.debug.print("stack len: {d}\n", .{stack.len});

    stack.pop();
    std.debug.print("stack len: {d}\n", .{stack.len});

    std.debug.print("stack state: {any}\n", .{stack.items[0..stack.len]});
}

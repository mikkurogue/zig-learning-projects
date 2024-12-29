const std = @import("std");
const stk = @import("stack.zig");
const Array = @import("array.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    //
    const allocator = gpa.allocator();
    const fixed_arr = Array.FixedArray(u8);
    var arr = try fixed_arr.init(allocator, 5);
    defer arr.deinit();

    try arr.push(1);
    try arr.push(3);
    try arr.push_head(8);

    try arr.pop();

    std.debug.print("FixedArray: {any}\n", .{arr.items[0..arr.len]});

    // const stack_u8 = stk.Stack(u32);
    // var stack = try stack_u8.init(allocator, 10);
    // defer stack.deinit();
    //
    // try stack.push(1);
    // try stack.push(2);
    // try stack.push(3);
    // try stack.push(4);
    // try stack.push(5);
    // try stack.push(6);
    //
    // std.debug.print("stack len: {d}\n", .{stack.len});
    // std.debug.print("stack capacity: {d}\n", .{stack.cap});
    //
    // stack.pop();
    // std.debug.print("stack len: {d}\n", .{stack.len});
    //
    // stack.pop();
    // std.debug.print("stack len: {d}\n", .{stack.len});
    //
    // std.debug.print("stack state: {any}\n", .{stack.items[0..stack.len]});
}

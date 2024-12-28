const std = @import("std");
const builtin = @import("builtin");
const net = @import("std").net;
const posix = @import("std").posix;

pub const Socket = struct {
    _address: std.net.Address,
    _stream: std.net.Stream,

    pub fn init() !Socket {
        const host: [4]u8 = [4]u8{ 127, 0, 0, 1 };
        const port: u16 = 3490;
        const addr = net.Address.initIp4(host, port);
        const socket = try posix.socket(addr.any.family, posix.SOCK.STREAM, posix.IPPROTO.TCP);
        const stream = net.Stream{ .handle = socket };
        return Socket{ ._address = addr, ._stream = stream };
    }
};

const std = @import("std");
const Connection = std.net.Server.Connection;
const Map = std.static_string_map.StaticStringMap;

const Str = []u8;
const ConstStr = []const u8;

pub const Method = enum {
    GET,
    pub fn init(text: ConstStr) !Method {
        return MethodMap.get(text).?;
    }
    pub fn is_supported(m: ConstStr) bool {
        const method = MethodMap.get(m);

        if (method) |_| {
            return true;
        }

        return false;
    }
};

const MethodMap = Map(Method).initComptime(.{
    .{ "GET", Method.GET },
});

const Request = struct {
    method: Method,
    version: ConstStr,
    uri: ConstStr,
    pub fn init(method: Method, uri: ConstStr, version: ConstStr) Request {
        return Request{ .method = method, .uri = uri, .version = version };
    }
};

pub fn read_request(conn: Connection, buffer: Str) !void {
    const reader = conn.stream.reader();

    _ = try reader.read(buffer);
}
pub fn parse_request(text: Str) Request {
    const line_index = std.mem.indexOfScalar(Str, text, '\n') orelse text.len;
    var iterator = std.mem.splitScalar(Str, text[0..line_index], ' ');

    const method = try Method.init(iterator.next().?);
    const uri = iterator.next().?;
    const version = iterator.next().?;
    const request = Request.init(method, uri, version);

    return request;
}

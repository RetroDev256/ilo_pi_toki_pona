const std = @import("std");

pub fn main() !void {
    // todo
}

fn inputStr(prompt: []const u8, buffer: []u8) ![]const u8 {
    const stdin = std.io.getStdIn().reader();
    try std.io.getStdOut().writeAll(prompt);
    return try stdin.readUntilDelimiter(buffer, '\n');
}

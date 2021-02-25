const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const print = std.debug.print;

const data = @embedFile("data/day03.txt");

pub fn main() !void {
    var out = std.io.bufferedWriter(std.io.getStdOut().writer());

    var lines = std.mem.tokenize(data, "\r\n");

    var trees11: usize = 0;
    var trees31: usize = 0;
    var trees51: usize = 0;
    var trees71: usize = 0;
    var trees12: usize = 0;

    var width: ?usize = null;
    var i: usize = 0;
    while (lines.next()) |line| : (i += 1) {
        if (width == null) {
            width = line.len;
        } else {
            assert(line.len == width.?);
        }

        trees11 += @boolToInt(line[i % width.?] == '#');
        trees31 += @boolToInt(line[(i*3) % width.?] == '#');
        trees51 += @boolToInt(line[(i*5) % width.?] == '#');
        trees71 += @boolToInt(line[(i*7) % width.?] == '#');
        trees12 += @boolToInt(i&1 == 0 and line[(i/2) % width.?] == '#');
    }

    try out.print("{} {} {} {} {} * {}\n", .{trees11, trees31, trees51, trees71, trees12, trees11 * trees31 * trees51 * trees71 * trees12});
}

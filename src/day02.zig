const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const print = std.debug.print;

const Timer = std.time.Timer;

const data = @embedFile("data/day02.txt");

const EntriesList = std.ArrayList(Record);

const Record = struct {
    min: u32,
    max: u32,
    char: u8,
    pass: []const u8,
};

pub fn main() !void {
    var out = std.io.getStdOut().writer();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const ally = &arena.allocator;

    var lines = std.mem.tokenize(data, "\r\n");

    var entries = EntriesList.init(ally);
    try entries.ensureCapacity(400);
    while (lines.next()) |line| {
        if (line.len == 0) continue;

        var tok = std.mem.tokenize(line, "- :");
        var min = try std.fmt.parseInt(u32, tok.next().?, 10);
        var max = try std.fmt.parseInt(u32, tok.next().?, 10);
        var char = tok.next().?[0];
        var pass = tok.next().?;
        assert(tok.next() == null);

        try entries.append(.{
            .min = min,
            .max = max,
            .char = char,
            .pass = pass,
        });
    }

    var valid: usize = 0;
    for (entries.items) |item| {
        var isValid = (item.pass[item.min-1] == item.char) != (item.pass[item.max-1] == item.char);
        if (!isValid) {
            try out.print("{}-{} {c}: {}\n", .{item.min, item.max, item.char, item.pass});
        } else {
            valid += 1;
        }
    }

    try out.print("Total valid: {}\n", .{valid});
}

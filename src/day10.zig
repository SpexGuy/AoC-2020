const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const print = std.debug.print;

const data = @embedFile("data/day10.txt");

const EntriesList = std.ArrayList(u64);

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const ally = &arena.allocator;

    var lines = std.mem.tokenize(data, "\r\n");

    var entries = EntriesList.init(ally);
    try entries.ensureCapacity(400);

    var max: u64 = 0;
    while (lines.next()) |line| {
        const value = try std.fmt.parseInt(u64, line, 10);
        try entries.append(value);
        if (value > max) max = value;
    }

    std.sort.sort(u64, entries.items, {}, comptime std.sort.asc(u64));

    // this is a mapping from (joltage + 3) -> number of ways to get there.
    // if there is no adapter for a given level, this value will be zero.
    const totals = try ally.alloc(u64, max + 1 + 3);
    std.mem.set(u64, totals, 0);

    // one combo to reach voltage level 0
    totals[0 + 3] = 1;

    // start with a count of 1 for the last jump of three.
    var counts = [_]u64{ 0, 0, 0, 1 };

    var prev: u64 = 0;
    for (entries.items) |id, i| {
        totals[id + 3] = totals[id] + totals[id + 1] + totals[id + 2];
        counts[id - prev] += 1;
        prev = id;
    }

    print("1: {}, 3: {}, p1: {}\n", .{counts[1], counts[3], counts[1] * counts[3]});
    print("p2: {}\n", .{totals[max + 3]});
}
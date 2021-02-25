const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const print = std.debug.print;
const mem = std.mem;

const data = @embedFile("data/day09.txt");

const EntriesList = std.ArrayList(u64);

const Record = struct {
    x: usize = 0,
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const ally = &arena.allocator;

    var lines = std.mem.tokenize(data, "\r\n");

    var entries = EntriesList.init(ally);
    try entries.ensureCapacity(400);

    var result: usize = 0;

    while (lines.next()) |line| {
        if (line.len == 0) continue;
        try entries.append(try std.fmt.parseInt(u64, line, 10));
    }

    const items = entries.items;

    var part1_result: usize = 0;
part1:
    for (items[25..]) |id, i| {
        const list = items[i..i+25];
        var found = false;
        for (list[0..list.len-1]) |a, j| {
            for (list[j+1..]) |b| {
                if (a + b == id) {
                    found = true;
                    continue :part1;
                }
            }
        }
        if (!found) {
            part1_result = id;
            break :part1;
        }
    } else unreachable;

    var part2_result: usize = 0;
part2:
    for (items) |id, i| {
        var total: u64 = 0;
        for (items[i..]) |b, l| {
            if (b == part1_result) break; 
            total += b;
            if (total > part1_result) break;
            if (total == part1_result) {
                var min = ~@as(usize, 0);
                var max = @as(usize, 0);
                for (entries.items[i..i+l+1]) |k| {
                    if (k < min) min = k;
                    if (k > max) max = k;
                }
                part2_result = min + max;
                break :part2;
            }
        }
    } else unreachable;
    
    print("part1: {}, part2: {}\n", .{part1_result, part2_result});
}

pub fn originalPart1() void {
    for (items) |id, i| {
        if (i >= 25) {
            const list = items[i-25..i];
            var found = false;
            for (list[0..list.len-1]) |a, j| {
                for (list[j+1..]) |b| {
                    if (a + b == id) {
                        found = true;
                    }
                }
            }
            if (!found) {
                print("Result: {}\n", .{id});
            }
        }
    }
}

pub fn originalPart2() void {
    const target = 10884537;
    for (items) |id, i| {
        var total: u64 = 0;
        for (items[i..]) |b, l| {
            total += b;
            if (total == 10884537) {
                var min = ~@as(usize, 0);
                var max = @as(usize, 0);
                // note: off by one bug on this line
                // luckily it didn't affect my answer
                for (entries.items[i..i+l]) |k| {
                    if (k < min) min = k;
                    if (k > max) max = k;
                }
                print("Result: {}\n", .{min + max});
            }
        }
    }
}

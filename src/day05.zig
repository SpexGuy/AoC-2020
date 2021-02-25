const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const print = std.debug.print;

const data = @embedFile("data/day05.txt");

const EntriesList = std.ArrayList(u32);

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const ally = &arena.allocator;

    var lines = std.mem.tokenize(data, "\r\n");

    var entries = EntriesList.init(ally);
    try entries.ensureCapacity(400);

    var max_id: u32 = 0;
    while (lines.next()) |line| {
        if (line.len == 0) continue;

        assert(line.len == 10);
        var id: u32 = 0;
        for (line) |char| {
            id = id << 1;
            id |= @boolToInt(char == 'B' or char == 'R');
        }

        if (id > max_id) {
            max_id = id;
        }

        try entries.append(id);
    }

    var array = try ally.alloc(bool, max_id + 1);
    std.mem.set(bool, array, false);

    for (entries.items) |id| {
        array[id] = true;
    }

    for (array) |val, i| {
        if (!val) {
            print("Missing: {}\n", .{i});
        }
    }

    print("Max: {}\n", .{max_id});
}

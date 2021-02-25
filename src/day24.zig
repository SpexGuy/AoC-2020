const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const print = std.debug.print;

const data = @embedFile("data/day24.txt");

const EntriesList = std.ArrayList(Record);
const Map = std.AutoHashMap(Record, void);

const Record = extern struct {
    x: i32 = 0,
    y: i32 = 0,

    fn min(a: Record, b: Record) Record {
        return .{
            .x = if (a.x < b.x) a.x else b.x,
            .y = if (a.y < b.y) a.y else b.y,
        };
    }

    fn max(a: Record, b: Record) Record {
        return .{
            .x = if (a.x > b.x) a.x else b.x,
            .y = if (a.y > b.y) a.y else b.y,
        };
    }

    fn add(a: Record, b: Record) Record {
        return .{
            .x = a.x + b.x,
            .y = a.y + b.y,
        };
    }
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const ally = &arena.allocator;

    var lines = std.mem.tokenize(data, "\r\n");

    var entries = EntriesList.init(ally);
    try entries.ensureCapacity(400);

    var map = Map.init(ally);

    var result: usize = 0;

    var min = Record{};
    var max = Record{};

    while (lines.next()) |line| {
        if (line.len == 0) continue;

        var pos = Record{};

        var rest = line;
        while (rest.len > 0) {
            switch (rest[0]) {
                's' => {
                    pos.y -= 1;
                    pos.x -= @intCast(i32, @boolToInt(rest[1] == 'w'));
                    rest = rest[2..];
                },
                'n' => {
                    pos.y += 1;
                    pos.x += @intCast(i32, @boolToInt(rest[1] == 'e'));
                    rest = rest[2..];
                },
                'e' => {
                    pos.x += 1;
                    rest = rest[1..];
                },
                'w' => {
                    pos.x -= 1;
                    rest = rest[1..];
                },
                else => unreachable,
            }
        }

        if (map.remove(pos)) |_| {
        } else {
            try map.put(pos, {});

            min = min.min(pos);
            max = max.max(pos);
        }
    }

    var next_map = Map.init(ally);

    const neighbors = [_]Record{
        .{ .x = 0, .y = 1 },
        .{ .x = 1, .y = 1 },
        .{ .x = -1, .y = 0 },
        .{ .x = 1, .y = 0 },
        .{ .x = -1, .y = -1 },
        .{ .x = 0, .y = -1 },
    };

    print("initial: {}\n", .{map.count()});
    dump_map(map, min, max);

    var iteration: usize = 0;
    while (iteration < 100) : (iteration += 1) {
        var next_min = Record{};
        var next_max = Record{};
        
        var y = min.y-1;
        while (y <= max.y+1) : (y += 1) {
            var x = min.x-1;
            while (x <= max.x+1) : (x += 1) {
                const self = Record{ .x = x, .y = y };
                var num_neigh: usize = 0;
                for (neighbors) |offset| {
                    var pos = offset.add(self);
                    if (map.contains(pos)) {
                        num_neigh += 1;
                    }
                }

                if (map.contains(self)) {
                    if (num_neigh == 1 or num_neigh == 2) {
                        try next_map.put(self, {});
                        next_max = next_max.max(self);
                        next_min = next_min.min(self);
                    }
                } else {
                    if (num_neigh == 2) {
                        try next_map.put(self, {});
                        next_max = next_max.max(self);
                        next_min = next_min.min(self);
                    }
                }
            }
        }

        min = next_min;
        max = next_max;
        const tmp = next_map;
        next_map = map;
        map = tmp;
        next_map.clearRetainingCapacity();

        const day = iteration + 1;
        if (day <= 10 or day % 10 == 0) {
            print("day {: >2}: {}\n", .{day, map.count()});
            //dump_map(map, min, max);
        }
    }

    print("Result: {}\n", .{map.count()});
}

fn dump_map(map: Map, min: Record, max: Record) void {
    print("map @ ({}, {})\n", .{min.x-1, max.x-1});
    var y = min.y-1;
    while (y <= max.y+1) : (y += 1) {
        var offset = (max.y+1) - y;
        var i: i32 = 0;
        while (i < offset) : (i += 1) {
            print(" ", .{});
        }
        var x = min.x-1;
        while (x <= max.x+1) : (x += 1) {
            if (map.contains(.{.x = x, .y = y})) {
                print("# ", .{});
            } else {
                print(". ", .{});
            }
        }
        print("\n", .{});
    }
    print("\n", .{});
}

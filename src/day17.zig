const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const print = std.debug.print;

const data = @embedFile("data/day17.txt");

const EntriesList = std.ArrayList(Record);

const Record = struct {
    x: usize = 0,
};

const Pos = struct {
    x: i32, y: i32, z: i32, w: i32
};

const Map = std.AutoHashMap(Pos, void);

pub fn main() !void {
    const time = try std.time.Timer.start();
    defer print("Time elapsed: {}\n", .{time.read()});

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const ally = &arena.allocator;

    var lines = std.mem.tokenize(data, "\r\n");

    var entries = EntriesList.init(ally);
    try entries.ensureCapacity(400);

    var result: usize = 0;

    var map = Map.init(ally);

    var width: i32 = 7;
    var min: Pos = .{ .x = 0, .y = 0, .z = 0, .w = 0 };
    var max: Pos = .{ .x = width, .y = width, .z = 0, .w = 0 };
    var y: i32 = 0;
    while (lines.next()) |line| {
        if (line.len == 0) continue;

        for (line) |char, i| {
            if (char == '#') {
                try map.put(.{.x = @intCast(i32, i), .y = y, .z = 0, .w = 0}, {});
            }
        }
        y += 1;
    }

    var iter: u32 = 0;
    while (iter < 6) : (iter += 1) {
        print("iter {}: {}\n", .{iter, map.count()});
        var next_map = Map.init(ally);
        defer {
            map.deinit();
            map = next_map;
        }

        //print("min=({} {} {}) max=({} {} {})\n", .{min.x, min.y, min.z, max.x, max.y, max.z});
        var d = min.w - 1;
        while (d <= max.w + 1) : (d += 1) {
            var c = min.z - 1;
            while (c <= max.z + 1) : (c += 1) {
                //print("z={}\n", .{c});
                var b = min.y - 1;
                while (b <= max.y + 1) : (b += 1) {
                    var a = min.x - 1;
                    while (a <= max.x + 1) : (a += 1) {
                        var neighbors: u32 = 0;

                        var ao: i32 = -1;
                        while (ao <= 1) : (ao += 1) {
                            var bo: i32 = -1;
                            while (bo <= 1) : (bo += 1) {
                                var co: i32 = -1;
                                while (co <= 1) : (co += 1) {
                                    var do: i32 = -1;
                                    while (do <= 1) : (do += 1) {
                                        if (ao != 0 or bo != 0 or co != 0 or do != 0) {
                                            if (map.contains(.{.x = a + ao, .y = b + bo, .z = c + co, .w = d + do})) {
                                                neighbors += 1;
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        if (map.contains(.{ .x = a, .y = b, .z = c, .w = d })) {
                            //print("#", .{});
                            if (neighbors == 2 or neighbors == 3) {
                                try next_map.put(.{.x = a, .y = b, .z = c, .w = d}, {});
                            }
                        } else {
                            //print(".", .{});
                            if (neighbors == 3) {
                                try next_map.put(.{.x = a, .y = b, .z = c, .w = d}, {});
                            }
                        }
                    }
                    //print("\n", .{});
                }
                //print("\n", .{});
            }
        }
        min.x -= 1;
        min.y -= 1;
        min.z -= 1;
        min.w -= 1;
        max.x += 1;
        max.y += 1;
        max.z += 1;
        max.w += 1;
    }

    print("count: {}\n", .{map.count()});
}

const std = @import("std");
const mem = std.mem;
const fmt = std.fmt;
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const print = std.debug.print;

const p1_target: u64 = 1000508;
const buses = [_]u64{
    29,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
37,
0,
0,
0,
0,
0,
467,
0,
0,
0,
0,
0,
0,
0,
23,
0,
0,
0,
0,
13,
0,
0,
0,
17,
0,
19,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
443,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
41
};

const BusTime = struct { bus: u64, offset: u64 };

// 13, 26, 39, 52, 65, 78, 91, 104, 117, 130, 143, 156, 169, 182, 195, 208, 221
// 17, 34, 51, 68, 85, 102, 119, 136, 153, 170, 187, 204, 221

// offset = 102
// period = 221

const bus_main: u64 = 1;
const main_offset: u64 = 0;

const bus_times = [_]BusTime{
    .{ .bus = 467, .offset = 29 },
    .{ .bus = 443, .offset = 60 },
    .{ .bus = 41, .offset = 101 },
    .{ .bus = 37, .offset = 23 },
    .{ .bus = 29, .offset = 0 },
    .{ .bus = 23, .offset = 37 },
    .{ .bus = 19, .offset = 48 },
    .{ .bus = 17, .offset = 46 },
    .{ .bus = 13, .offset = 42 },
};


const EntriesList = std.ArrayList(Record);

const Record = struct {
    x: usize = 0,
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const ally = &arena.allocator;

    var period = bus_main;
    var offset = main_offset;
    for (bus_times) |bus| {
        var time: u64 = offset;
        while (true) : (time += period) {
            if ((time + bus.offset) % bus.bus == 0) {
                break;
            }
        }
        period *= bus.bus;
        offset = time;
        print("bus {}+{} period {} offset {}\n", .{bus.bus, bus.offset, period, offset});
    }

    print("Result: {}\n", .{offset});
}

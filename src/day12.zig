const std = @import("std");
const mem = std.mem;
const Allocator = mem.Allocator;
const assert = std.debug.assert;
const print = std.debug.print;

const data = @embedFile("data/day12.txt");

const EntriesList = std.ArrayList(Record);

const Record = struct {
    x: usize = 0,
};

const north: u32 = 0;
const east: u32 = 1;
const south: u32 = 2;
const west: u32 = 3;

const left = [_]u32 { west, north, east, south };
const back = [_]u32 { south, west, north, east };
const right = [_]u32 { east, south, west, north };
const x = [_]i32 { 0, 1, 0, -1 };
const y = [_]i32 { 1, 0, -1, 0 };

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const ally = &arena.allocator;
    
    var sx: i32 = 0;
    var sy: i32 = 0;
    var wx: i32 = 10;
    var wy: i32 = 1;
    var lines = std.mem.tokenize(data, "\r\n");

    var entries = EntriesList.init(ally);
    try entries.ensureCapacity(400);

    var result: usize = 0;
    var forward = east;

    while (lines.next()) |line| {
        if (line.len == 0) continue;

        var code = line[0];
        const amt = try std.fmt.parseUnsigned(u32, line[1..], 10);

        if (code == 'L') {
            if (amt == 270) code = 'R'
            else if (amt == 180) code = 'B'
            else assert(amt == 90);
        } else         if (code == 'R') {
            if (amt == 270) code = 'L'
            else if (amt == 180) code = 'B'
            else assert(amt == 90);
        }


        var direction: ?u32 = null;
        switch (code) {
            'F' => {
                sx += @intCast(i32, amt) * wx;
                sy += @intCast(i32, amt) * wy;
            },
            'N' => direction = north,
            'E' => direction = east,
            'W' => direction = west,
            'S' => direction = south,
            'R' => {
                var tmp = wy;
                wy = -wx;
                wx = tmp;
            },
            'L' => {
                var tmp = wx;
                wx = -wy;
                wy = tmp;
            },
            'B' => {
                wx = -wx;
                wy = -wy;
            },
            else => unreachable,
        }

        if (direction) |d| {
            wx += @intCast(i32, amt) * x[d];
            wy += @intCast(i32, amt) * y[d];
        }

        //print("{c} {} ({}, {}) face {}\n", .{code, })
    }

    print("x: {}, y: {}\n", .{sx, sy});
}

const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const print = std.debug.print;

const data = @embedFile("data/day11.txt");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const ally = &arena.allocator;

    var width = std.mem.indexOf(u8, data, "\n").?;
    var pitch = width + 1;
    var height = data.len / width;

    // allocate our buffers.  Data for (x, y) is at index
    // pitch + 1 + y*pitch + x.  There is an extra line before
    // and after the buffer, which allows us to safely read
    // "out of bounds" of the problem.
    const a = try ally.alloc(u8, data.len + 2*pitch + 2);
    const b = try ally.alloc(u8, data.len + 2*pitch + 2);

    std.mem.set(u8, a, '.');
    std.mem.set(u8, b, '.');
    a[width+1] = '\n';
    b[width+1] = '\n';

    const ipitch = @intCast(isize, pitch);

    // 8 directions
    const directions = [_]isize{
        -ipitch-1, -ipitch, -ipitch+1,
            -1,                 1,
         ipitch-1,  ipitch,  ipitch+1,
    };

    std.mem.copy(u8, a[pitch + 1..], data);
    const count1 = simulateToCompletion(check, 4, &directions, a, b);
    
    std.mem.copy(u8, a[pitch + 1..], data);
    const count2 = simulateToCompletion(scan, 5, &directions, a, b);

    print("part1: {}, part2: {}\n", .{count1, count2});
}

fn simulateToCompletion(
    comptime checkFunc: fn([]const u8, usize, isize)bool,
    comptime tolerance: comptime_int,
    directions: []const isize,
    a: []u8,
    b: []u8,
) usize {
    var prev = a;
    var next = b;

    var running = true;
    while (running) {
        running = false;
        // the buffers retain their newlines, so we can just print them directly.
        // print("iter\n{}\n\n\n", .{prev});

        for (prev) |c, i| {
            if (c == 'L' or c == '#') {
                var occ: u32 = 0;
                for (directions) |d| {
                    occ += @boolToInt(checkFunc(prev, i, d));
                }
                next[i] = if (c == 'L' and occ == 0) '#' else if (c == '#' and occ >= tolerance) 'L' else c;
                running = running or next[i] != c;
            } else {
                next[i] = c;
            }
        }

        var tmp = prev;
        prev = next;
        next = tmp;
    }

    var count: usize = 0;
    for (prev) |c| {
        if (c == '#') count += 1;
    }
    return count;
}

fn check(d: []const u8, pos: usize, dir: isize) bool {
    const idx = @intCast(isize, pos) + dir;
    return d[@intCast(usize, idx)] == '#';
}

fn scan(d: []const u8, pos: usize, dir: isize) bool {
    var curr = @intCast(isize, pos) + dir;
    while (curr >= 0 and curr < @intCast(isize, d.len)) {
        const ucurr = @intCast(usize, curr);
        if (d[ucurr] == '\n') return false; // detect wraparound
        if (d[ucurr] == '#') return true;
        if (d[ucurr] == 'L') return false;
        curr += dir;
    }
    return false;
}

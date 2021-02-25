const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const print = std.debug.print;

const Timer = std.time.Timer;

const data = @embedFile("data/day01.txt");

const EntriesList = std.ArrayList(i16);
const vec_len = 16;
const Vec = std.meta.Vector(vec_len, i16);
const Mask = std.meta.Vector(vec_len, bool);
const ShuffleMask = std.meta.Vector(vec_len, i32);

/// Returns a mask which rotates a simd vector `rot` slots left.
fn rotate_mask(comptime rot: usize) ShuffleMask {
    comptime {
        var vec: ShuffleMask = undefined;
        var c: usize = 0;
        while (c < vec_len) : (c += 1) {
            vec[c] = (c + rot) % vec_len;
        }
        return vec;
    }
}

fn find_result1(a: Vec, b: Vec, mask: Mask) i64 {
    @setCold(true);

    var result: i64 = -1;
    comptime var ti = 0;
    inline while (ti < vec_len) : (ti += 1) {
        if (mask[ti]) {
            result = @as(i64, a[ti]) * @as(i64, b[ti]);
        }
    }
    return result;
}

fn find_result2(a: Vec, b: Vec, c: Vec, mask: Mask) i64 {
    @setCold(true);

    var result: i64 = -1;
    comptime var ti = 0;
    inline while (ti < vec_len) : (ti += 1) {
        if (mask[ti]) {
            result = @as(i64, a[ti]) * @as(i64, b[ti]) * @as(i64, c[ti]);
        }
    }
    return result;
}


pub fn main() !void {
    var lines = std.mem.tokenize(data, "\r\n");

    var timer = try Timer.start();

    var buffer: [1<<13]u8 align(@alignOf(Vec)) = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    var entries = EntriesList.init(&fba.allocator);
    try entries.ensureCapacity(400);
    while (lines.next()) |line| {
        if (line.len == 0) continue;
        const num = try std.fmt.parseInt(i16, line, 10);
        try entries.append(num);
    }

    while (entries.items.len % vec_len != 0) {
        try entries.append(entries.items[0]);
    }

    var parse_time = timer.lap();

    const items = entries.items;
    const vec_items = @ptrCast([*]Vec, @alignCast(@alignOf(Vec), items.ptr))[0..@divExact(items.len, vec_len)];

    var result1: i64 = -1;
    //part1: 
    {
        var found = false;
        var c: usize = 0;
        while (c < vec_items.len) : (c += 1) {
            var cv = vec_items[c];
            var d: usize = c + 1;
            while (d < vec_items.len) : (d += 1) {
                var dvv = vec_items[d];
                comptime var do = 0;
                inline while (do < vec_len) : (do += 1) {
                    var dv = @shuffle(i16, dvv, undefined, comptime rotate_mask(do));
                    var mask = (cv + dv == @splat(vec_len, @as(i16, 2020)));
                    if (@reduce(.Or, mask) != false) {
                        result1 = find_result1(cv, dv, mask);
                        found = true;
                    }
                }
                //if (found) break :part1;
            }
        }
    }
    var p1_time = timer.lap();

    var result2: i64 = -1;
    //part2:
    {
        var found = false;
        var c: usize = 0;
        while (c < vec_items.len) : (c += 1) {
            var cv = vec_items[c];
            var d: usize = c + 1;
            while (d < vec_items.len) : (d += 1) {
                var dvv = vec_items[d];
                var e: usize = d + 1;
                while (e < vec_items.len) : (e += 1) {
                    var evv = vec_items[e];
                    
                    @setEvalBranchQuota(100000);
                    comptime var do = 0;
                    inline while (do < vec_len) : (do += 1) {
                        var dv = @shuffle(i16, dvv, undefined, comptime rotate_mask(do));
                        var cdv = cv + dv;
                        comptime var eo = 0;
                        inline while (eo < vec_len) : (eo += 1) {
                            var ev = @shuffle(i16, evv, undefined, comptime rotate_mask(eo));
                            var mask = (cdv + ev == @splat(vec_len, @as(i16, 2020)));
                            if (@reduce(.Or, mask) != false) {
                                result2 = find_result2(cv, dv, ev, mask);
                                found = true;
                            }
                        }
                    }

                    //if (found) break :part2;
                }
            }
        }
    }
    var p2_time = timer.lap();

    print("part1: {}, part2: {}\n", .{result1, result2});

    var print_time = timer.lap();

    const total = parse_time + p1_time + p2_time + print_time;
    print(
    \\done, total time: {:>9}
    \\  parse: {:>9}
    \\  p1   : {:>9}
    \\  p2   : {:>9}
    \\  print: {:>9}
    \\
    , .{total, parse_time, p1_time, p2_time, print_time});

}

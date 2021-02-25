const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const print = std.debug.print;

const data = @embedFile("data/day14.txt");

const EntriesList = std.ArrayList(Record);

const Record = struct {
    x: usize = 0,
};

var mem = std.AutoArrayHashMap(u36, u36).init(std.heap.page_allocator);

fn setMem(floating: u36, addr: u36, value: u36) void {
    if (floating == 0) {
        mem.put(addr, value) catch unreachable;
    } else {
        var bot = @ctz(u36, floating);
        var mask = @as(u36, 1) << @intCast(u6, bot);
        var new_floating = floating & ~mask;
        assert(new_floating < floating);
        setMem(new_floating, addr | mask, value);
        setMem(new_floating, addr & ~mask, value);
    }
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const ally = &arena.allocator;

    var lines = std.mem.tokenize(data, "\r\n");

    var entries = EntriesList.init(ally);
    try entries.ensureCapacity(400);

    var result: usize = 0;

    var mask_valid: u36 = 0;
    var mask_values: u36 = 0;

    while (lines.next()) |line| {
        if (line.len == 0) continue;

        if (std.mem.startsWith(u8, line, "mask = ")) {
            var mask = line[7..];
            mask_valid = 0;
            mask_values = 0;
            for (mask) |c| {
                mask_valid <<= 1;
                mask_values <<= 1;
                if (c == '1') {
                    mask_valid |= 1;
                    mask_values |= 1;
                } else if (c == '0') {
                    mask_valid |= 1;
                }
            }
            print("mask: {}\nval:  {b:0>36}\nvad:  {b:0>36}\n\n", .{mask, mask_values, mask_valid});
        }
        else if (std.mem.startsWith(u8, line, "mem[")) {
            var it = std.mem.tokenize(line, "me[] =");
            const idx = try std.fmt.parseUnsigned(u36, it.next().?, 10);
            const val = try std.fmt.parseUnsigned(u36, it.next().?, 10);
            assert(it.next() == null);
            setMem(~mask_valid, idx | mask_values, val);

//            const mod = (val & ~mask_valid) | (mask_values & mask_valid);

//            mem[idx] = mod;
        }
    }

    var sum: u64 = 0;
    var iter = mem.iterator();
    while(iter.next()) |entry| {
        sum += entry.value;
    }

    print("Result: {}\n", .{sum});
}

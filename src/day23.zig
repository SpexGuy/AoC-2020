const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const print = std.debug.print;

const Cups = std.ArrayList(u32);

const initial = [_]u32{
    6,5,3,4,2,7,9,1,8
};

const Cup = struct {
    next: u32,
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const ally = &arena.allocator;

    var cups = try ally.alloc(Cup, 1_000_001);
    for (initial[1..]) |next, prev_index| {
        const prev = initial[prev_index];
        cups[prev].next = next;
    }

    cups[0] = .{ .next = ~@as(u32, 0) };
    cups[1_000_000].next = initial[0];
    cups[initial[initial.len-1]].next = 10;

    {
        var i: usize = 10;
        while (i < 1_000_000) : (i += 1) {
            cups[i].next = @intCast(u32, i+1);
        }
    }

    var current = initial[0];

    var round: usize = 0;
    while (round < 10_000_000) : (round += 1) {
        if ((round % 100_000) == 0) print("Round {}\n", .{round});

        const next0 = cups[current].next;
        const next1 = cups[next0].next;
        const next2 = cups[next1].next;
        const next3 = cups[next2].next;

        var insertAfter = current-1;
        while (true) {
            if (insertAfter == 0) insertAfter = 1_000_000;
            if (insertAfter != next0 and
                insertAfter != next1 and
                insertAfter != next2) break;
            insertAfter -= 1;
        }

        const postInsert = cups[insertAfter].next;

        cups[insertAfter].next = next0;
        cups[next2].next = postInsert;
        cups[current].next = next3;

        current = cups[current].next;
    }

    var after = cups[1].next;
    var after2 = cups[after].next;
    print("{} {} {}\n", .{after, after2, @as(u64, after) * after2});
}

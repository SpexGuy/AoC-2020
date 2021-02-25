const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const print = std.debug.print;

const Nums = std.AutoHashMap(u32, u32);

const EntriesList = std.ArrayList(Record);

const Record = struct {
    turn: u32,
    diff: u32,
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const ally = &arena.allocator;

    var nums = Nums.init(ally);

    var turn: u32 = 0;
    var last_num: u32 = undefined;
    const input = [_]u32{ 2, 0, 1, 9, 5, 19 };
    //const input = [_]u32{ 0, 3, 6 };
    for (input) |v, i| {
        if (turn > 0) {
            try nums.put(last_num, turn);
        }
        last_num = v;
        // if (turn % 16 == 0) {
        //     print("\n{: >4}: ", .{turn});
        // }
        // print("{: >4}, ", .{last_num});
        // turn += 1;
    }

    while (turn < 30000000) : (turn += 1) {
        var diff = if (nums.get(last_num)) |rec| turn - rec else 0;
        try nums.put(last_num, turn);
        last_num = diff;
        // if (turn % 16 == 0) {
        //     print("\n{: >4}: ", .{turn});
        // }
        // print("{: >4}, ", .{diff});
    }

    print("\nResult: {}\n", .{last_num});
}

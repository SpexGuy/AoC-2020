const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const print = std.debug.print;

const data = @embedFile("data/day25.txt");

const EntriesList = std.ArrayList(Record);

const Record = struct {
    x: usize = 0,
};

const initial_subject = 7;
const modulo = 20201227;
const from_door = 5290733;
const from_card = 15231938;

fn find_loops(target: u64) usize {
    var loops: usize = 0;
    var curr: u64 = 1;
    while (curr != target) : (loops += 1) {
        curr = (curr * initial_subject) % modulo;
    }
    return loops;
}

fn transform(subject: u64, loops: usize) u64 {
    var curr: u64 = 1;
    var i: usize = 0;
    while (i < loops) : (i += 1) {
        curr = (curr * subject) % modulo;
    }
    return curr;
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const ally = &arena.allocator;

    var result: usize = 0;

    var door_loop = find_loops(from_door);
    var card_loop = find_loops(from_card);

    result = transform(from_door, card_loop);

    print("Result: {}\n", .{result});
}

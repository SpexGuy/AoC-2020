const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const print = std.debug.print;

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const ally = &arena.allocator;

const Deck = std.ArrayList(u8);

const p1_init = [_]u8 {
    26,
    16,
    33,
    8,
    5,
    46,
    12,
    47,
    39,
    27,
    50,
    10,
    34,
    20,
    23,
    11,
    43,
    14,
    18,
    1,
    48,
    28,
    31,
    38,
    41,
};

const p2_init = [_]u8 {
    45,
    7,
    9,
    4,
    15,
    19,
    49,
    3,
    36,
    25,
    24,
    2,
    21,
    37,
    35,
    44,
    29,
    13,
    32,
    22,
    17,
    30,
    42,
    40,
    6,
};

const HistoryState = struct {
    p1: []const u8,
    p2: []const u8,

    fn eql(self: HistoryState, p1: []const u8, p2: []const u8) bool {
        return std.mem.eql(u8, self.p1, p1) and std.mem.eql(u8, self.p2, p2);
    }
};

pub fn recursiveCombat(p1v: []const u8, p2v: []const u8) bool {
    var history = std.ArrayList(HistoryState).init(ally);
    defer history.deinit();

    var p1 = Deck.init(ally);
    defer p1.deinit();

    var p2 = Deck.init(ally);
    defer p2.deinit();

    p1.appendSlice(p1v) catch unreachable;
    p2.appendSlice(p2v) catch unreachable;

    while (p1.items.len > 0 and p2.items.len > 0) {
        for (history.items) |hist| {
            if (hist.eql(p1.items, p2.items)) {
                return false; // p1 wins
            }
        }

        history.append(.{
            .p1 = ally.dupe(u8, p1.items) catch unreachable,
            .p2 = ally.dupe(u8, p2.items) catch unreachable,
        }) catch unreachable;

        const a = p1.pop();
        const b = p2.pop();

        var winner = false;
        if (a <= p1.items.len and b <= p2.items.len) {
            winner = recursiveCombat(
                p1.items[p1.items.len - a..],
                p2.items[p2.items.len - b..],
            );
        } else {
            winner = b > a;
        }

        if (winner) {
            p2.insertSlice(0, &[_]u8{a, b}) catch unreachable;
        } else {
            p1.insertSlice(0, &[_]u8{b, a}) catch unreachable;
        }
    }

    return p2.items.len > 0;
}

pub fn main() !void {
    var p1 = Deck.init(ally);
    var p2 = Deck.init(ally);

    for (p1_init) |c| {
        try p1.insert(0, c);
    }

    for (p2_init) |c| {
        try p2.insert(0, c);
    }

    var history = std.ArrayList(HistoryState).init(ally);

    var round: usize = 0;

    var overall = foo: while (p1.items.len > 0 and p2.items.len > 0) : (round += 1) {
        for (history.items) |hist| {
            if (hist.eql(p1.items, p2.items)) {
                break :foo false; // p1 wins
            }
        }
        const a = p1.pop();
        const b = p2.pop();

        var winner = false;
        if (a <= p1.items.len and b <= p2.items.len) {
            winner = recursiveCombat(
                p1.items[p1.items.len - a..],
                p2.items[p2.items.len - b..],
            );
        } else {
            winner = b > a;
        }

        if (winner) {
            try p2.insertSlice(0, &[_]u8{a, b});
        } else {
            try p1.insertSlice(0, &[_]u8{b, a});
        }
    } else p2.items.len > 0;

    var result: usize = 0;
    if (overall) {
        for (p2.items) |c, i| {
            result += c * (i+1);
        }
    } else {
        for (p1.items) |c, i| {
            result += c * (i+1);
        }
    }

    print("Finished after {} rounds, Result: {}\n", .{round, result});
}

const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const print = std.debug.print;

/// This input file has been preprocesed with find-and-replace operations
/// Example of the input after preprocessing:
/// 
/// vibrant orange:3 striped olive,1 muted olive
/// light lime:1 dotted red,5 bright red
/// shiny olive:5 vibrant black,2 dotted violet
/// wavy blue:2 dull blue,4 dark violet
/// dark black:4 drab cyan
/// faded orange:
/// mirrored magenta:2 bright crimson,5 mirrored fuchsia,4 plaid green,4 plaid gold
/// 
const data = @embedFile("data/day07.txt");

const EntriesList = std.ArrayList(Record);

const Child = struct {
    count: usize,
    color: []const u8,
};

const Record = struct {
    color: []const u8,
    rules: []Child,
    gold: bool = false,
    done: bool = false,
    subcount: usize = 0,
};

const Entries = std.ArrayList(Record);

pub fn main() !void {
    const timer = try std.time.Timer.start();
    var arena = std.heap.GeneralPurposeAllocator(.{}){};
    const ally = &arena.allocator;

    var lines = std.mem.tokenize(data, "\r\n");

    var map = Entries.init(ally);

    var result: usize = 0;

    while (lines.next()) |line| {
        if (line.len == 0) continue;

        var parts = std.mem.tokenize(line, ":,");
        var color = parts.next().?;

        var list = std.ArrayList(Child).init(ally);
        while (parts.next()) |part| {
            const split = std.mem.indexOfAny(u8, part, " ").?;
            const count = try std.fmt.parseInt(usize, part[0..split], 10);
            const incolor = part[split+1..];
            
            try list.append(.{ .count = count, .color = incolor });
        }

        try map.append(.{
            .color = color,
            .rules = list.toOwnedSlice(),
            .gold = std.mem.eql(u8, "shiny gold", color),
        });
    }

    var totalGold: usize = 0;

    var modifiedAny = true;
    while (modifiedAny) {
        modifiedAny = false;
        nextItem: for (map.items) |*item| {
            if (item.done) continue;
            var childTotal: usize = 0;

            for (item.rules) |rule| {
                var match: ?*Record = null;
                for (map.items) |*item2| {
                    if (std.mem.eql(u8, rule.color, item2.color)) {
                        match = item2;
                        break;
                    }
                }
                if (!item.gold and match.?.gold) {
                    item.gold = true;
                    totalGold += 1;
                    modifiedAny = true;
                }
                if (!match.?.done) continue :nextItem;
                childTotal += (match.?.subcount + 1) * rule.count;
            }

            item.done = true;
            item.subcount = childTotal;
            modifiedAny = true;
        }
    }

    var match: ?*Record = null;
    for (map.items) |*item2| {
        if (std.mem.eql(u8, "shiny gold", item2.color)) {
            match = item2;
            break;
        }
    }

    var elapsed = timer.read();

    print("part1: {}, part2: {}, time: {}\n", .{totalGold, match.?.subcount, elapsed});
}

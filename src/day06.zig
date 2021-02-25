const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const print = std.debug.print;

const data = @embedFile("data/day06.txt");

pub fn main() !void {
    var lines = std.mem.split(data, "\n\n");

    var present1: [256]bool = undefined;
    var present2: [256]bool = undefined;
    var total1: usize = 0;
    var total2: usize = 0;

    while (lines.next()) |line| {
        if (line.len == 0) continue;
        std.mem.set(bool, &present1, false);
        std.mem.set(bool, &present2, true);

        var people = std.mem.tokenize(line, "\n");
        while (people.next()) |peep| {
            var person: [256]bool = undefined;
            std.mem.set(bool, &person, false);
            for (peep) |c| {
                person[c] = true;
            }

            for (person) |c, i| {
                present1[i] = present1[i] or c;
                present2[i] = present2[i] and c;
            }
        }

        for (present1) |val, i| {
            total1 += @boolToInt(val);
            total2 += @boolToInt(present2[i]);
        }
    }

    print("part1: {}, part2: {}\n", .{total1, total2});
}

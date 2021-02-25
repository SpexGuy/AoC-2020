const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const print = std.debug.print;

const data = @embedFile("data/day19.txt");

const EntriesList = std.ArrayList(Record);

const Found = error { MatchFound };

const Rest = struct {
    remain: std.ArrayList(u8),
    search: []const u8 = undefined,

    fn init(allocator: *Allocator) !Rest {
        var remain = std.ArrayList(u8).init(allocator);
        try remain.ensureCapacity(400);
        return Rest{ .remain = remain };
    }

    pub fn match(self: *Rest, search: []const u8) bool {
        self.remain.items.len = 0;
        self.search = search;
        self.matchRecord(records[0], 0) catch return true;
        return false;
    }

    fn push(self: *Rest, val: u8) void {
        self.remain.append(val) catch unreachable;
    }

    fn pop(self: *Rest, val: u8) void {
        assert(self.remain.pop() == val);
    }

    inline fn matchRest(self: *Rest, pos: u8) Found!void {
        if (self.remain.items.len == 0) {
            if (pos == self.search.len) {
                return error.MatchFound;
            }
            return; // no match found, try again
        }
        if (pos >= self.search.len) {
            return; // no match found, try again
        }

        // try to match the rest of the string
        const next = self.remain.pop();
        try self.matchRecord(records[next], pos);
        // match failed, put it back.
        self.remain.append(next) catch unreachable;
    }

    fn matchRecord(self: *Rest, record: Record, pos: u8) Found!void {
        return switch (record) {
            .none => unreachable,
            .pair => |pair| try self.matchPair(pair, pos),
            .choice => |choice| {
                switch (choice.first) {
                    .pair => |pair| try self.matchPair(pair, pos),
                    .indirect => |idx| try self.matchRecord(records[idx], pos),
                }
                switch (choice.second) {
                    .pair => |pair| try self.matchPair(pair, pos),
                    .indirect => |idx| try self.matchRecord(records[idx], pos),
                }
            },
            .literal => |lit| {
                if (pos < self.search.len and self.search[pos] == lit.char) {
                    try self.matchRest(pos + 1);
                }
            },
            .indirect => |ind| try self.matchRecord(records[ind], pos),
        };
    }

    inline fn matchPair(self: *Rest, pair: Pair, pos: u8) Found!void {
        self.push(pair.second);
        try self.matchRecord(records[pair.first], pos);
        self.pop(pair.second);
    }
};

const Literal = struct {
    char: u8,
};

const Pair = struct {
    first: u8,
    second: u8,
};

const ChoiceElem = union(enum) {
    pair: Pair,
    indirect: u8,
};

const Choice = struct {
    first: ChoiceElem,
    second: ChoiceElem,
};

const Record = union(enum) {
    none: void,
    pair: Pair,
    choice: Choice,
    literal: Literal,
    indirect: u8,
};

var records = [_]Record{ .{ .none={} } } ** 256;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const ally = &arena.allocator;

    var lines = std.mem.split(data, "\n");

    var entries = EntriesList.init(ally);
    try entries.ensureCapacity(400);

    var result: usize = 0;

    while (lines.next()) |line| {
        if (line.len == 0) break;
        var parts = std.mem.tokenize(line, ": ");
        const index = std.fmt.parseUnsigned(u8, parts.next().?, 10) catch unreachable;

        var rec: Record = .none;

        const first = parts.next().?;
        if (first[0] == '"') {
            rec = .{ .literal = .{ .char = first[1] }};
        } else {
            const part0 = std.fmt.parseUnsigned(u8, first, 10) catch unreachable;
            if (parts.next()) |str1| {
                if (str1[0] == '|') {
                    const part1 = std.fmt.parseUnsigned(u8, parts.next().?, 10) catch unreachable;
                    if (parts.next()) |str2| {
                        const part2 = std.fmt.parseUnsigned(u8, str2, 10) catch unreachable;
                        rec = .{ .choice = .{
                            .first = .{ .indirect = part0 },
                            .second = .{ .pair = .{ .first = part1, .second = part2 }},
                        }};
                        assert(parts.next() == null);
                    } else {
                        rec = .{ .choice = .{
                            .first = .{ .indirect = part0 },
                            .second = .{ .indirect = part1 },
                        }};
                    }
                } else {
                    const part1 = std.fmt.parseUnsigned(u8, str1, 10) catch unreachable;
                    if (parts.next()) |str2| {
                        assert(std.mem.eql(u8, str2, "|"));
                        const part2 = std.fmt.parseUnsigned(u8, parts.next().?, 10) catch unreachable;
                        const part3 = std.fmt.parseUnsigned(u8, parts.next().?, 10) catch unreachable;
                        rec = .{ .choice = .{
                            .first = .{ .pair = .{ .first = part0, .second = part1 }},
                            .second = .{ .pair = .{ .first = part2, .second = part3 }},
                        }};
                    } else {
                        rec = .{ .pair = .{
                            .first = part0, .second = part1
                        }};
                    }
                }
            } else {
                rec = .{ .indirect = part0 };
            }
        }

        records[index] = rec;
    }

    var rest = try Rest.init(ally);
    while (lines.next()) |line| {
        if (line.len == 0) continue;
        if (rest.match(line)) {
            result += 1;
            print("matched: {}\n", .{line});
        }
    }

    print("Result: {}\n", .{result});
}

const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const print = std.debug.print;

const data = @embedFile("data/day21.txt");

const EntriesList = std.ArrayList(Record);

const FoodSet = BitSet(200);
const AllerSet = BitSet(8);

const Record = struct {
    foods: FoodSet = FoodSet.zeroes(),
    allergs: AllerSet = AllerSet.zeroes(),
};

pub fn BitSet(comptime max_items: comptime_int) type {
    const num_words = (max_items + 63) / 64;
    const max_bit_index = @as(u6, max_items % 64);
    const last_word_mask = @as(u64, (@as(u64, 1) << max_bit_index) - 1);
    return struct {
        const Self = @This();

        words: [num_words]u64,

        pub fn zeroes() Self {
            return .{ .words = [_]u64{0} ** num_words };
        }
        pub fn ones() Self {
            var result = Self{ .words = [_]u64{~@as(u64, 0)} ** num_words };
            result.words[num_words-1] &= last_word_mask;
            return result;
        }

        pub fn contains(self: Self, item: usize) bool {
            assert(item < max_items);
            const mask = @as(u64, 1) << @truncate(u6, item);
            const word_index = item >> 6;
            return (self.words[word_index] & mask) != 0;
        }
        pub fn set(self: *Self, item: usize, value: bool) void {
            assert(item < max_items);
            const mask = @as(u64, @boolToInt(value)) << @truncate(u6, item);
            const word_index = item >> 6;
            self.words[word_index] = (self.words[word_index] & ~mask) | mask;
        }

        pub fn count(a: Self) usize {
            var total: usize = 0;
            for (a.words) |word| {
                total += @intCast(usize, @popCount(u64, word));
            }
            return total;
        }

        pub fn bitOr(a: Self, b: Self) Self {
            var result: Self = undefined;
            for (a.words) |av, i| {
                result.words[i] = av | b.words[i];
            }
            return result;
        }
        pub fn bitAnd(a: Self, b: Self) Self {
            var result: Self = undefined;
            for (a.words) |av, i| {
                result.words[i] = av & b.words[i];
            }
            return result;
        }
        pub fn bitAndNot(a: Self, b: Self) Self {
            var result: Self = undefined;
            for (a.words) |av, i| {
                result.words[i] = av & ~b.words[i];
            }
            return result;
        }
        pub fn bitNot(a: Self) Self {
            var result: Self = undefined;
            for (a.words) |av, i| {
                result.words[i] = ~av;
            }
            result.words[num_words-1] &= last_word_mask;
            return result;
        }
        pub fn bitXor(a: Self, b: Self) Self {
            var result: Self = undefined;
            for (a.words) |av, i| {
                result.words[i] = av ^ b.words[i];
            }
            return result;
        }

        pub fn iterator(self: *Self) Iterator {
            return .{ .current_word = self.words[0], .set = self };
        }

        const Iterator = struct {
            offset: usize = 0,
            current_word: u64,
            set: *Self,

            pub fn next(self: *Iterator) ?usize {
                while (true) {
                    const curr = self.current_word;
                    if (curr != 0) {
                        const remain = @ctz(u64, curr);
                        self.current_word = curr & (curr-1);
                        var result = remain + self.offset * 64;
                        if (result < max_items) return result;
                        self.current_word = 0;
                        return null;
                    }
                    if (self.offset >= num_words-1) return null;
                    self.offset += 1;
                    self.current_word = self.set.words[self.offset];
                }
            }
        };
    };
}

const StringMap = struct {
    items: std.ArrayList([]const u8),

    pub fn init(allocator: *Allocator) StringMap {
        return .{
            .items = std.ArrayList([]const u8).init(allocator),
        };
    }

    pub fn deinit(self: *StringMap) void {
        self.items.deinit();
        self.* = undefined;
    }

    pub fn id(self: *StringMap, string: []const u8) !u32 {
        for (self.items.items) |str, i| {
            if (std.mem.eql(u8, str, string)) return @intCast(u32, i);
        }
        const next = self.items.items.len;
        try self.items.append(string);
        return @intCast(u32, next);
    }
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const ally = &arena.allocator;

    var lines = std.mem.tokenize(data, "\r\n");

    var entries = EntriesList.init(ally);
    try entries.ensureCapacity(400);

    var foods = StringMap.init(ally);
    var allergs = StringMap.init(ally);

    var result: usize = 0;

    while (lines.next()) |line| {
        if (line.len == 0) continue;

        var rec = Record{};

        var parts = std.mem.tokenize(line, " ),");
        while (parts.next()) |item| {
            if (std.mem.eql(u8, item, "(contains"))
                break;
            const id = try foods.id(item);
            rec.foods.set(id, true);
        }
        while (parts.next()) |item| {
            const id = try allergs.id(item);
            rec.allergs.set(id, true);
        }

        try entries.append(rec);
    }

    print("Found {} foods and {} allergens in {} records\n", .{foods.items.items.len, allergs.items.items.len, entries.items.len});

    var maybeAllergs = FoodSet.zeroes();

    for (allergs.items.items) |aller, i| {
        var maybeAller = FoodSet.ones();
        for (entries.items) |rec| {
            if (rec.allergs.contains(i)) {
                maybeAller = maybeAller.bitAnd(rec.foods);
            }
        }
        print("{} may be {} items:\n    ", .{aller, maybeAller.count()});
        var it = maybeAller.iterator();
        while (it.next()) |fd| {
            print("{} ", .{foods.items.items[fd]});
        }
        print("\n", .{});
        maybeAllergs = maybeAllergs.bitOr(maybeAller);
    }
    print("{} items may be allergies:\n    ", .{maybeAllergs.count()});
    var it = maybeAllergs.iterator();
    while (it.next()) |fd| {
        print("{} ", .{foods.items.items[fd]});
    }
    print("\n", .{});

    var total_non_allerg: usize = 0;
    for (entries.items) |rec| {
        var non_allerg = rec.foods.bitAndNot(maybeAllergs);
        total_non_allerg += non_allerg.count();
    }
    print("Total non allerg: {}\n", .{total_non_allerg});
}

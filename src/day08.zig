const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const print = std.debug.print;

const data = @embedFile("data/day08");

const EntriesList = std.ArrayList(Inst);

const Op = enum {
    nop,
    acc,
    jmp,
};

const Inst = struct {
    op: Op,
    val: isize,
    executed: bool = false,
};

pub fn main() !void {
    var timer = try std.time.Timer.start();
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const ally = &arena.allocator;

    var lines = std.mem.tokenize(data, "\r\n");

    var entries = EntriesList.init(ally);
    try entries.ensureCapacity(400);

    while (lines.next()) |line| {
        if (line.len == 0) continue;

        var tok = std.mem.split(line, " ");
        var opname = tok.next().?;
        var int = try std.fmt.parseInt(isize, tok.next().?, 10);

        var op = if (std.mem.eql(u8, "nop", opname)) Op.nop else if (std.mem.eql(u8, "jmp", opname)) Op.jmp else Op.acc;

        try entries.append(.{
            .op = op,
            .val = int,
        });
    }

    var raw_items = entries.items;
    var items = try ally.alloc(Inst, raw_items.len);

    var result2: ?isize = null;
    for (raw_items) |item, i| {
        if (item.op == .nop or item.op == .jmp) {
            std.mem.copy(Inst, items, raw_items);
            if (item.op == .jmp) {
                items[i].op = .nop;
            } else {
                items[i].op = .jmp;
            }

            var pc: isize = 0;
            var acc: isize = 0;
            while (pc != @intCast(isize, items.len)) {
                var inst = &items[@intCast(usize, pc)];
                if (inst.executed) break;
                inst.executed = true;
                switch(inst.op) {
                    .jmp => {
                        pc += inst.val;
                    },
                    .acc => {
                        acc += inst.val;
                        pc += 1;
                    },
                    .nop => {
                        pc += 1;
                    },
                }
            } else {
                result2 = acc;
                break;
            }
        }
    }
    
    print("result: {}, time: {}\n", .{result2, timer.read()});
}

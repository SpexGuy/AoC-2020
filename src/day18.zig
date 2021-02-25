const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const print = std.debug.print;

const data = @embedFile("data/day18.txt");

pub fn main() !void {
    var lines = std.mem.tokenize(data, "\r\n");

    var result1: usize = 0;
    var result2: usize = 0;

    while (lines.next()) |line| {
        if (line.len == 0) continue;

        var pos: usize = 0;
        result1 += eval1(line, &pos);
        pos = 0;
        result2 += eval2(line, &pos);
    }

    print("Day 1: {}, Day 2: {}\n", .{ result1, result2 });
}

fn eval1(expr: []const u8, pos: *usize) u64 {
    var op: u8 = '?';
    var value: u64 = 0;

    while (pos.* < expr.len) {
        var idx = pos.*;
        pos.* += 1;
        const c = expr[idx];
        switch (c) {
            '*', '+' => op = c,
            ' ' => {},
            '(' => {
                const curr = eval1(expr, pos);
                switch (op) {
                    '?' => value = curr,
                    '*' => value *= curr,
                    '+' => value += curr,
                    else => unreachable,
                }
                op = '!';
            },
            ')' => break,
            '0'...'9' => {
                const curr = c - '0';
                switch (op) {
                    '?' => value = curr,
                    '*' => value *= curr,
                    '+' => value += curr,
                    else => unreachable,
                }
                op = '!';
            },
            else => unreachable,
        }
    }

    return value;
}

fn eval2(expr: []const u8, pos: *usize) u64 {
    var result: u64 = 1;
    var curr: u64 = 0;

    while (pos.* < expr.len) {
        switch (expr[pos.*]) {
            '*' => {
                pos.* += 1;
                result *= curr;
                curr = 0;
            },
            ' ', '+' => {
                pos.* += 1;
            },
            '(' => {
                pos.* += 1;
                curr += eval2(expr, pos);
                pos.* += 1;
            },
            ')' => break,
            '0'...'9' => |c| {
                pos.* += 1;
                curr += (c - '0');
            },
            else => unreachable,
        }
    }

    if (curr != 0) result *= curr;
    return result;
}

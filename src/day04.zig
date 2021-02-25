const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const print = std.debug.print;

const data = @embedFile("data/day04.txt");

const Record = struct {
    byr: bool = false,
    iyr: bool = false,
    eyr: bool = false,
    hgt: bool = false,
    hcl: bool = false,
    ecl: bool = false,
    pid: bool = false,
    cid: bool = false,

    pub fn isValid(self: *const @This()) bool {
        return self.byr and self.iyr and self.eyr and self.hgt and self.hcl and self.ecl and self.pid;
    }
};

pub fn main() !void {
    var lines = std.mem.split(data, "\n\n");

    var numValid: usize = 0;
    while (lines.next()) |line| {
        var rec = Record{};

        var toks = std.mem.tokenize(line, " \n");
        while (toks.next()) |tok| {
            var colon = std.mem.indexOf(u8, tok, ":");
            var tag = tok[0..colon.?];
            var value = tok[colon.?+1..];
            if (std.mem.eql(u8, "byr", tag)) {
                if (std.fmt.parseInt(u16, value, 10)) |ival| {
                    if (ival >= 1920 and ival <= 2002) {
                        rec.byr = true;
                    }
                } else |err| {}
            } else if (std.mem.eql(u8, "iyr", tag)) {
                if (std.fmt.parseInt(u16, value, 10)) |ival| {
                    if (ival >= 2010 and ival <= 2020) {
                        rec.iyr = true;
                    }
                } else |err| {}
            } else if (std.mem.eql(u8, "eyr", tag)) {
                if (std.fmt.parseInt(u16, value, 10)) |ival| {
                    if (ival >= 2020 and ival <= 2030) {
                        rec.eyr = true;
                    }
                } else |err| {}
            } else if (std.mem.eql(u8, "hgt", tag)) {
                if (std.mem.endsWith(u8, value, "cm")) {
                    if (std.fmt.parseInt(u16, value[0..value.len-2], 10)) |ival| {
                        if (ival >= 150 and ival <= 193) {
                            rec.hgt = true;
                        }
                    } else |err| {}
                } else if (std.mem.endsWith(u8, value, "in")) {
                    if (std.fmt.parseInt(u16, value[0..value.len-2], 10)) |ival| {
                        if (ival >= 59 and ival <= 76) {
                            rec.hgt = true;
                        }
                    } else |err| {}
                }
            } else if (std.mem.eql(u8, "hcl", tag)) {
                if (value.len == 7 and value[0] == '#') {
                    var valid = true;
                    for (value[1..]) |char| {
                        if (!((char >= '0' and char <= '9') or (char >= 'a' and char <= 'f'))) {
                            valid = false;
                        }
                    }
                    rec.hcl = valid;
                }
            } else if (std.mem.eql(u8, "ecl", tag)) {
                if (
                    std.mem.eql(u8, value, "amb") or
                    std.mem.eql(u8, value, "blu") or
                    std.mem.eql(u8, value, "brn") or
                    std.mem.eql(u8, value, "gry") or
                    std.mem.eql(u8, value, "grn") or
                    std.mem.eql(u8, value, "hzl") or
                    std.mem.eql(u8, value, "oth")
                ) {
                    rec.ecl = true;
                }
            } else if (std.mem.eql(u8, "pid", tag)) {
                if (value.len == 9) {
                    var valid = true;
                    for (value[1..]) |char| {
                        if (!(char >= '0' and char <= '9')) {
                            valid = false;
                        }
                    }
                    rec.pid = valid;
                }
            } else if (std.mem.eql(u8, "cid", tag)) {
                rec.cid = true;
            } else {
                print("Unknown tag: {}\n", .{tok});
            }
        }

        numValid += @boolToInt(rec.isValid());
    }

    print("Valid: {}\n", .{numValid});
}

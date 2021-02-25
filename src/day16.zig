const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const print = std.debug.print;

const data = @embedFile("data/day16.txt");

const EntriesList = std.ArrayList(Field);
const Ticket = [20]u32;
const TicketList = std.ArrayList(Ticket);

const Field = struct {
    name: []const u8,
    amin: u32,
    amax: u32,
    bmin: u32,
    bmax: u32,
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const ally = &arena.allocator;

    var lines = std.mem.tokenize(data, "\r\n");

    var fields = EntriesList.init(ally);
    try fields.ensureCapacity(400);
    var tickets = TicketList.init(ally);
    try tickets.ensureCapacity(400);

    var result: usize = 0;

    while (lines.next()) |line| {
        if (line.len == 0) continue;
        if (line[line.len-1] == ':') break;

        var parts = std.mem.tokenize(line, ":");
        var name = parts.next().?;
        parts.delimiter_bytes = ": or-";

        try fields.append(.{
            .name = name,
            .amin = try std.fmt.parseUnsigned(u32, parts.next().?, 10),
            .amax = try std.fmt.parseUnsigned(u32, parts.next().?, 10),
            .bmin = try std.fmt.parseUnsigned(u32, parts.next().?, 10),
            .bmax = try std.fmt.parseUnsigned(u32, parts.next().?, 10),
        });
        assert(parts.next() == null);
    }
    while (lines.next()) |line| {
        if (line.len == 0) continue;
        if (line[line.len-1] == ':') continue;

        var ticket: Ticket = undefined;
        var count: usize = 0;
        var parts = std.mem.tokenize(line, ",");
        while (parts.next()) |part| : (count += 1) {
            ticket[count] = std.fmt.parseUnsigned(u32, part, 10) catch { @breakpoint(); unreachable; };
        }
        assert(count == ticket.len);

        try tickets.append(ticket);
    }

    var valid_tickets = TicketList.init(ally);
    try valid_tickets.ensureCapacity(tickets.items.len);

    for (tickets.items[1..]) |ticket| {
        var valid = true;
        for (ticket) |field| {
            for (fields.items) |ct| {
                if ((field >= ct.amin and field <= ct.amax) or
                    (field >= ct.bmin and field <= ct.bmax)) {
                    break;
                }
            } else {
                valid = false;
                result += field;
            }
        }
        if (valid) {
            try valid_tickets.append(ticket);
        }
    }

    print("Result 1: {}, valid: {}/{}\n", .{result, valid_tickets.items.len, tickets.items.len});

    var valid = [_]bool{true} ** 20;
    var out_order: [20]u32 = undefined;

    check_ticket(valid_tickets.items, fields.items, &valid, 0, &out_order) catch {
        for (out_order) |item| {
            print("{}, ", .{item});
        }
        print("\n", .{});
        var product: u64 = 1;
        for (out_order) |item, idx| {
            if (std.mem.startsWith(u8, fields.items[item].name, "departure")) {
                var value = tickets.items[0][idx];
                print("{}: {}\n", .{fields.items[item].name, value});
                product *= value;
            }
        }
        print("product: {}\n", .{product});
    };
}

fn check_ticket(
    tickets: []const Ticket,
    fields: []const Field,
    valid: *[20]bool,
    index: u32,
    out_order: *[20]u32,
) error{Complete}!void {
    if (index >= 20) return error.Complete;
    for (valid) |*v, vi| {
        if (v.*) {
            valid[vi] = false;
            defer valid[vi] = true;
            out_order[index] = @intCast(u32, vi);
            const ct = fields[vi];

            for (tickets) |*tik| {
                var item = tik.*[index];
                if (!((item >= ct.amin and item <= ct.amax) or
                    (item >= ct.bmin and item <= ct.bmax))) {
                    break;
                }
            } else {
                try check_ticket(tickets, fields, valid, index + 1, out_order);
            }
        }
    }
}

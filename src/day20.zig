const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const print = std.debug.print;

const data = @embedFile("data/day20.txt");

const EntriesList = std.ArrayList(Record);

const dim = 10;
const pitch = 11;

const Record = struct {
    id: u32,
    data: *const [dim][pitch]u8,

    fn top(grid: Record, o: Orientation) EdgeIterator {
        return switch (o) {
            .Top => .{ .pos = 0, .stride = 1, .grid = grid },
            .Right => .{ .pos = dim-1, .stride = pitch, .grid = grid },
            .Bottom => .{ .pos = dim * pitch - 2, .stride = -1, .grid = grid },
            .Left => .{ .pos = pitch * (dim-1), .stride = -pitch, .grid = grid },

            .FTop => .{ .pos = dim-1, .stride = -1, .grid = grid },
            .FLeft => .{ .pos = 0, .stride = pitch, .grid = grid },
            .FBottom => .{ .pos = pitch * (dim-1), .stride = 1, .grid = grid },
            .FRight => .{ .pos = dim * pitch - 2, .stride = -pitch, .grid = grid },
        };
    }

    fn right(grid: Record, o: Orientation) EdgeIterator {
        return grid.top(o.clockwise(1));
    }

    fn bottom(grid: Record, o: Orientation) EdgeIterator {
        return grid.top(o.clockwise(2));
    }

    fn left(grid: Record, o: Orientation) EdgeIterator {
        return grid.top(o.clockwise(3));
    }

    fn row(grid: Record, o: Orientation, idx: i32) EdgeIterator {
        var iter = grid.top(o);
        switch (o) {
            .Top, .FTop => iter.pos += idx * pitch,
            .Right, .FRight => iter.pos -= idx,
            .Bottom, .FBottom => iter.pos -= idx * pitch,
            .Left, .FLeft => iter.pos += idx,
        }
        return iter;
    }
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const ally = &arena.allocator;

    var grids = std.mem.split(data, "\n\n");

    var entries = EntriesList.init(ally);
    try entries.ensureCapacity(400);

    var result: usize = 0;

    while (grids.next()) |gridStr| {
        if (gridStr.len == 0) continue;
        var parts = std.mem.split(gridStr, "\n");
        var line = parts.next().?;
        var tok = line[5..];
        tok = tok[0..tok.len-1];
        const id = std.fmt.parseUnsigned(u32, tok, 10) catch unreachable;

        var grid = parts.rest();
        var ptr = @ptrCast(*const[dim][pitch]u8, grid.ptr);
        try entries.append(.{
            .id = id,
            .data = ptr,
        });
    }

    const num = entries.items.len;
    var config = Config.init(entries.items, ally);
    findConfig(&config);

    var tl = config.tiles[config.order[0].tile].id;
    var tr = config.tiles[config.order[config.width-1].tile].id;
    var bl = config.tiles[config.order[num - config.width].tile].id;
    var br = config.tiles[config.order[num - 1].tile].id;

    var height = @divExact(num, config.width);
    var y: usize = 0;
    while (y < height) : (y += 1) {
        var r: i32 = 0;
        while (r < dim) : (r += 1) {
            var x: usize = 0;
            while (x < config.width) : (x += 1) {
                var idx = y * config.width + x;
                var rowit = config.tiles[config.order[idx].tile].row(config.order[idx].orientation, r);

                var d: i32 = 0;
                while (d < dim) : (d += 1) {
                    print("{c}", .{rowit.at(d)});
                }
                print(" ", .{});
            }
            print("\n", .{});
        }
        print("\n", .{});
    }

    var buf_width = config.width * (dim - 2);
    var buf_height = height * (dim - 2);
    var buffer = try ally.alloc(u8, buf_height * (buf_width + 1));

    var buf_pos: usize = 0;
    y = 0;
    while (y < height) : (y += 1) {
        var r: i32 = 1;
        while (r < dim-1) : (r += 1) {
            var x: usize = 0;
            while (x < config.width) : (x += 1) {
                var idx = y * config.width + x;
                var rowit = config.tiles[config.order[idx].tile].row(config.order[idx].orientation, r);

                var d: i32 = 1;
                while (d < dim-1) : (d += 1) {
                    buffer[buf_pos] = rowit.at(d);
                    buf_pos += 1;
                }
            }
            buffer[buf_pos] = '\n';
            buf_pos += 1;
        }
    }
    assert(buf_pos == buffer.len);

    print("\n\ncombined:\n{}\n", .{buffer});

    const d0 = Buffer.fromString(
        \\..................#.
        \\#....##....##....###
        \\.#..#..#..#..#..#...
        \\
    );
    const d1 = Buffer.fromString(
        \\ #                  
        \\###    ##    ##    #
        \\   #  #  #  #  #  # 
        \\
    );
    const d2 = Buffer.fromString(
        \\ #  #  #  #  #  #   
        \\#    ##    ##    ###
        \\                  # 
        \\
    );
    const d3 = Buffer.fromString(
        \\   #  #  #  #  #  # 
        \\###    ##    ##    #
        \\ #                  
        \\
    );
    const d4 = Buffer.fromString(
        \\ # 
        \\## 
        \\ # 
        \\  #
        \\   
        \\   
        \\  #
        \\ # 
        \\ # 
        \\  #
        \\   
        \\   
        \\  #
        \\ # 
        \\ # 
        \\  #
        \\   
        \\   
        \\  #
        \\ # 
        \\
    );
    const d5 = Buffer.fromString(
        \\ # 
        \\  #
        \\   
        \\   
        \\  #
        \\ # 
        \\ # 
        \\  #
        \\   
        \\   
        \\  #
        \\ # 
        \\ # 
        \\  #
        \\   
        \\   
        \\  #
        \\ # 
        \\## 
        \\ # 
        \\
    );
    const d6 = Buffer.fromString(
        \\ # 
        \\ ##
        \\ # 
        \\#  
        \\   
        \\   
        \\#  
        \\ # 
        \\ # 
        \\#  
        \\   
        \\   
        \\#  
        \\ # 
        \\ # 
        \\#  
        \\   
        \\   
        \\#  
        \\ # 
        \\
    );
    const d7 = Buffer.fromString(
        \\ # 
        \\#  
        \\   
        \\   
        \\#  
        \\ # 
        \\ # 
        \\#  
        \\   
        \\   
        \\#  
        \\ # 
        \\ # 
        \\#  
        \\   
        \\   
        \\#  
        \\ # 
        \\ ##
        \\ # 
        \\
    );

    const b = Buffer.fromString(buffer);

    const c0 = countInstances(b, d0);
    const c1 = countInstances(b, d1);
    const c2 = countInstances(b, d2);
    const c3 = countInstances(b, d3);
    const c4 = countInstances(b, d4);
    const c5 = countInstances(b, d5);
    const c6 = countInstances(b, d6);
    const c7 = countInstances(b, d7);

    print("Result: {}\n", .{@as(u64, tl) * tr * bl * br});
    print("dragons:\n{}\n", .{buffer});
    print("roughness: {}\n", .{std.mem.count(u8, buffer, "#")});
}

const Buffer = struct {
    pitch: usize,
    width: usize,
    height: usize,
    buffer: [*]const u8,

    pub fn fromString(str: []const u8) Buffer {
        var width = std.mem.indexOfScalar(u8, str, '\n').?;
        return .{
            .pitch = width + 1,
            .width = width,
            .height = @divExact(str.len, width+1),
            .buffer = str.ptr,
        };
    }

    pub fn at(self: Buffer, x: usize, y: usize) u8 {
        assert(x < self.width);
        assert(y < self.height);
        return self.buffer[y * self.pitch + x];
    }

    pub fn set(self: Buffer, x: usize, y: usize, val: u8) void {
        var ptr: [*]u8 = @intToPtr([*]u8, @ptrToInt(self.buffer));
        ptr[y * self.pitch + x] = val;
    }
};

fn countInstances(haystack: Buffer, needle: Buffer) usize {
    print("searching {}x{}\n{}\n", .{needle.width, needle.height, needle.buffer[0..needle.pitch * needle.height]});

    var y: usize = 0;
    while (y < haystack.height - needle.height) : (y += 1) {
        var x: usize = 0;
    position:
        while (x < haystack.width - needle.width) : (x += 1) {
            var oy: usize = 0;
            while (oy < needle.height) : (oy += 1) {
                var ox: usize = 0;
                while (ox < needle.width) : (ox += 1) {
                    if (needle.at(ox, oy) == '#') {
                        if (haystack.at(x + ox, y + oy) != '#' and haystack.at(x + ox, y + oy) != 'O') {
                            continue :position;
                        }
                    }
                }
            }

            oy = 0;
            while (oy < needle.height) : (oy += 1) {
                var ox: usize = 0;
                while (ox < needle.width) : (ox += 1) {
                    if (needle.at(ox, oy) == '#') {
                        haystack.set(x + ox, y + oy, 'O');
                    }
                }
            }
        }
    }
    return 0;
}

const Orientation = enum {
    Top,
    Right,
    Bottom,
    Left,

    FTop,
    FLeft,
    FBottom,
    FRight,

    pub fn clockwise(self: Orientation, amt: u2) Orientation {
        const int = @enumToInt(self);
        const rotated = ((int +% amt) & 3) | (int & 4);
        return @intToEnum(Orientation, rotated);
    }

    const values = [_]Orientation{
        .Top,
        .Right,
        .Bottom,
        .Left,

        .FTop,
        .FLeft,
        .FBottom,
        .FRight,
    };
};

const EdgeIterator = struct {
    pos: i32,
    stride: i32,
    grid: Record,

    fn at(self: EdgeIterator, idx: i32) u8 {
        return @ptrCast([*]const u8, self.grid.data)[@intCast(usize, self.pos + self.stride * idx)];
    }

    fn equals(self: EdgeIterator, other: EdgeIterator) bool {
        var i: i32 = 0;
        while (i < dim) : (i += 1) {
            if (self.at(i) != other.at(dim - 1 - i)) return false;
        }
        return true;
    }
};

const TileConfig = struct {
    tile: u32,
    orientation: Orientation,
};

const Config = struct {
    width: u32,
    tiles: []const Record,
    order: []TileConfig,
    used: []bool,

    pub fn init(tiles: []const Record, alloc: *std.mem.Allocator) Config {
        const order = alloc.alloc(TileConfig, tiles.len) catch unreachable;
        const used = alloc.alloc(bool, tiles.len) catch unreachable;
        std.mem.set(bool, used, false);
        return Config{
            .width = undefined,
            .tiles = tiles,
            .order = order,
            .used = used,
        };
    }
};

fn findConfig(config: *Config) void {
    var w: u32 = 2;
    while (w < config.tiles.len) : (w += 1) {
        if (config.tiles.len % w == 0) {
            config.width = w;
            findConfigRecursive(config, 0) catch return;
        }
    }
    unreachable;
}

fn findConfigRecursive(config: *Config, index: usize) error{Found}!void {
    if (index >= config.tiles.len) return error.Found;
    for (config.used) |*v, i| {
        if (!v.*) {
            v.* = true;
            for (Orientation.values) |o| {
                if (index % config.width == 0 or
                    config.tiles[i].left(o).equals(config.tiles[config.order[index-1].tile].right(config.order[index-1].orientation))) {
                    if (index < config.width or
                        config.tiles[i].top(o).equals(config.tiles[config.order[index-config.width].tile].bottom(config.order[index-config.width].orientation))) {
                        config.order[index] = .{
                            .tile = @intCast(u32, i),
                            .orientation = o,
                        };
                        try findConfigRecursive(config, index + 1);
                    }
                }
            }
            v.* = false;
        }
    }
}
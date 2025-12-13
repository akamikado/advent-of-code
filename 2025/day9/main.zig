const std = @import("std");

pub fn main() !void {
    var fileBuf: [4096]u8 = undefined;
    var file = try std.fs.cwd().openFile("day9/input.txt", .{});
    var fileReader = file.reader(&fileBuf);
    var reader = &fileReader.interface;

    var heapBuf: [1024*1024]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&heapBuf);
    const allocator = fba.allocator();

    var coords = try std.ArrayListUnmanaged([2]u32).initCapacity(allocator, 32);
    defer coords.deinit(allocator);

    var uniqueX = try std.ArrayListUnmanaged(u32).initCapacity(allocator, 32);
    var uniqueY = try std.ArrayListUnmanaged(u32).initCapacity(allocator, 32);
    while (reader.takeDelimiterInclusive('\n')) |line| {
        const trimmed = std.mem.trim(u8, line, " \n");
        var iter = std.mem.splitScalar(u8, trimmed, ',');
        const x: u32 = try std.fmt.parseInt(u32, iter.next().?, 10);
        try uniqueX.append(allocator, x);
        const y: u32 = try std.fmt.parseInt(u32, iter.next().?, 10);
        try uniqueY.append(allocator, y);
        try coords.append(allocator, [_]u32{x, y});
    } else |err| {
        _ = err catch {};
    }

    std.mem.sort(u32, uniqueX.items, {}, std.sort.asc(u32));
    std.mem.sort(u32, uniqueY.items, {}, std.sort.asc(u32));

    var compressedX = std.AutoArrayHashMap(u32, usize).init(allocator);
    var compressedY = std.AutoArrayHashMap(u32, usize).init(allocator);

    for (0..uniqueX.items.len) |i| {
        try compressedX.put(uniqueX.items[i], i);
    }
    for (0..uniqueY.items.len) |i| {
        try compressedY.put(uniqueY.items[i], i);
    }

    var maxArea: u64 = 0;
    for (0..coords.items.len) |i| {
        for (i+1..coords.items.len) |j| {
            const area: u64 = (@abs(@as(i64, @intCast(coords.items[i][0])) - @as(i64, @intCast(coords.items[j][0]))) + 1) * (@abs(@as(i64, @intCast(coords.items[i][1])) - @as(i64, @intCast(coords.items[j][1]))) + 1);
            maxArea = @max(maxArea, area);
        }
    }

    std.debug.print("Part 1: {d}\n", .{maxArea});

    var isGreenTile = try allocator.alloc([]bool, uniqueY.items.len);
    for (0..uniqueY.items.len) |i| {
        isGreenTile[i] = try allocator.alloc(bool, uniqueX.items.len);
        @memset(isGreenTile[i], false);
    }

    for (0..coords.items.len) |cur| {
        const next: usize = if (cur + 1 >= coords.items.len) 0 else cur + 1;

        const x1 = compressedX.get(coords.items[cur][0]).?;
        const y1 = compressedY.get(coords.items[cur][1]).?;
        isGreenTile[y1][x1] = true;

        const x2 = compressedX.get(coords.items[next][0]).?;
        const y2 = compressedY.get(coords.items[next][1]).?;
        isGreenTile[y2][x2] = true;

        if (x1 == x2) {
            const start: usize = @min(y1, y2);
            const end: usize = @max(y1, y2);
            for (start+1..end) |y| {
                isGreenTile[y][x1] = true;
            }
        } else if (y1 == y2) {
            const start: usize = @min(x1, x2);
            const end: usize = @max(x1, x2);
            for (start+1..end) |x| {
                isGreenTile[y1][x] = true;
            }
        } else {
            unreachable;
        }
    }


    for (0..isGreenTile.len) |i| {
        var inside: bool = false;
        for (0..isGreenTile[i].len) |j| {
            if (isGreenTile[i][j]) inside = !inside;
            if (inside) isGreenTile[i][j] = true;
        }
    }

    maxArea = 0;
    for (0..coords.items.len) |i| {
        for (i+1..coords.items.len) |j| {
            const area: u64 = (@abs(@as(i64, @intCast(coords.items[i][0])) - @as(i64, @intCast(coords.items[j][0]))) + 1) * (@abs(@as(i64, @intCast(coords.items[i][1])) - @as(i64, @intCast(coords.items[j][1]))) + 1);
            if (area <= maxArea) continue;

            const t1: [2]usize = [_]usize{compressedX.get(coords.items[i][0]).?, compressedY.get(coords.items[i][1]).?};
            const t2: [2]usize = [_]usize{compressedX.get(coords.items[j][0]).?, compressedY.get(coords.items[j][1]).?};

            const startX: usize = @min(t1[0], t2[0]);
            const startY: usize = @min(t1[1], t2[1]);
            const endX: usize = @max(t1[0], t2[0]);
            const endY: usize = @max(t1[1], t2[1]);

            var invalid: bool = false;

            for (startX..endX+1) |x| {
                for (startY..endY+1) |y| {
                    if (!isGreenTile[y][x]) {
                        invalid = true;
                        break;
                    }
                }
                if (invalid) break;
            }
            
            if (invalid) continue;

            maxArea = @max(maxArea, area);
        }
    }

    std.debug.print("Part 2: {d}\n", .{maxArea});
}

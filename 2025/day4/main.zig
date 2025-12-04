const std = @import("std");

pub fn main() !void {
    var file = try std.fs.cwd().openFile("day4/input.txt", .{});
    defer file.close();

    var fileBuf: [1024]u8 = undefined;
    var fileReader = file.reader(&fileBuf);
    var reader = &fileReader.interface;

    var gpa = std.heap.GeneralPurposeAllocator(.{}).init;
    defer _ = gpa.deinit();

    var allocator = gpa.allocator();
    var area = try std.ArrayListUnmanaged([]u8).initCapacity(allocator, 0);
    defer area.deinit(allocator);

    while (reader.takeDelimiterInclusive('\n')) |line| {
        const width = line.len - 1;

        var col = try allocator.alloc(u8, width);
        @memcpy(col[0..width], line[0..width]);

        try area.append(allocator, col);
    } else |err| {
        _ = err catch {};
    }

    var loopCnt: u32 = 0;
    var ans: u32 = 0;

    while (true) {
        var removed: u32 = 0;
        for (0..area.items.len) |i| {
            for (0..area.items[i].len) |j| {
                if (area.items[i][j] == '.' or area.items[i][j] == 'x') continue;
                var cnt: u8 = 0;
                if (i > 0) {
                    if (j > 0) cnt += if (area.items[i-1][j-1] != '.') 1 else 0;
                    cnt += if (area.items[i-1][j] != '.') 1 else 0;
                    if (j < area.items[i-1].len-1) cnt += if (area.items[i-1][j+1] != '.') 1 else 0;
                } 
                if (j > 0) cnt += if (area.items[i][j-1] != '.') 1 else 0;
                if (j < area.items[i].len-1) cnt += if (area.items[i][j+1] != '.') 1 else 0;
                if (i < area.items.len-1) {
                    if (j > 0) cnt += if (area.items[i+1][j-1] != '.') 1 else 0;
                    cnt += if (area.items[i+1][j] != '.') 1 else 0;
                    if (j < area.items[i+1].len-1) cnt += if (area.items[i+1][j+1] != '.') 1 else 0;
                }
                if (cnt < 4) {
                    removed += 1;
                    area.items[i][j] = 'x';
                }
            }
        }
        for (0..area.items.len) |i| {
            for (0..area.items[i].len) |j| {
                if (area.items[i][j] == 'x') area.items[i][j] = '.';
            }
        }
        ans += removed;
        if (loopCnt == 0) std.debug.print("Part 1: {d}\n", .{ans});
        loopCnt += 1;
        if (removed == 0) break;
    }

    std.debug.print("Part 2: {d}\n", .{ans});

    for (0..area.items.len) |i| {
        allocator.free(area.items[i]);
    }
}

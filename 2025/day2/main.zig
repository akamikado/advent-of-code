const std = @import("std");

fn intLen(a: u64) u32 {
    var b = a;
    var len: u16 = 0;
    while (b > 0) {
        b /= 10;
        len += 1;
    }
    return len;
} 

pub fn main() !void {

    var file = try std.fs.cwd().openFile("day2/input.txt", .{});
    defer file.close();

    var file_buf: [1024]u8 = undefined;
    var file_reader = file.reader(&file_buf);
    var reader = &file_reader.interface;

    var ans: u64 = 0;
    while (reader.takeDelimiterInclusive(',')) |line| {
        var separatorIdx: usize = 0;
        while (separatorIdx < line.len - 1 and line[separatorIdx] != '-') {
            separatorIdx += 1;
        }
        const startId = try std.fmt.parseInt(u64, line[0..separatorIdx], 10);
        const endId = try std.fmt.parseInt(u64, line[separatorIdx+1..line.len-1], 10);

        for (startId..endId+1) |id| {
            const idLen: u32 = intLen(id);
            if (idLen % 2 != 0) {
                continue;
            }
            const leftHalf = @divFloor(id, std.math.pow(u32, 10, idLen / 2));
            const rightHalf = id % std.math.pow(u32, 10, idLen / 2);
            if (leftHalf == rightHalf) {
                ans += id;
            }
        }
    } else |err| {
        _ = err catch {};
    }

    if (reader.takeDelimiterExclusive(0)) |line| {
        var separatorIdx: usize = 0;
        while (separatorIdx < line.len - 1 and line[separatorIdx] != '-') {
            separatorIdx += 1;
        }
        const startId = try std.fmt.parseInt(u64, line[0..separatorIdx], 10);
        const endId = try std.fmt.parseInt(u64, line[separatorIdx+1..line.len-1], 10);

        for (startId..endId+1) |id| {
            const idLen: u32 = intLen(id);
            if (idLen % 2 != 0) {
                continue;
            }
            const leftHalf = @divFloor(id, std.math.pow(u32, 10, idLen / 2));
            const rightHalf = id % std.math.pow(u32, 10, idLen / 2);
            if (leftHalf == rightHalf) {
                ans += id;
            }
        }
    } else |err| {
        _ = err catch {};
    }

    std.debug.print("Part 1: {d}\n", .{ans});

    ans = 0;

    try file.seekTo(0);
    file_reader = file.reader(&file_buf);
    reader = &file_reader.interface;

    while (reader.takeDelimiterInclusive(',')) |line| {
        var separatorIdx: usize = 0;
        while (separatorIdx < line.len - 1 and line[separatorIdx] != '-') {
            separatorIdx += 1;
        }
        const startId = try std.fmt.parseInt(u64, line[0..separatorIdx], 10);
        const endId = try std.fmt.parseInt(u64, line[separatorIdx+1..line.len-1], 10);

        for (startId..endId+1) |id| {
            const idLen: u32 = intLen(id);
            if (idLen < 2) continue;
            for (2..idLen+1) |len| {
                if (idLen % len != 0) continue;
                const grpSize = idLen / len;
                const m = std.math.pow(u64, 10, grpSize);
                var prev = id % m;
                var temp = @divFloor(id, m);
                var invalid = true;
                while (temp > 0) {
                    if (prev != temp % m) {
                        invalid = false;
                        break;
                    }
                    prev = temp % m;
                    temp = @divFloor(temp, m);
                }
                if (invalid) {
                    ans += id;
                    break;
                }
            }
        }
    } else |err| {
        _ = err catch {};
    }

    if (reader.takeDelimiterExclusive(0)) |line| {
        var separatorIdx: usize = 0;
        while (separatorIdx < line.len - 1 and line[separatorIdx] != '-') {
            separatorIdx += 1;
        }
        const startId = try std.fmt.parseInt(u64, line[0..separatorIdx], 10);
        const endId = try std.fmt.parseInt(u64, line[separatorIdx+1..line.len-1], 10);

        for (startId..endId+1) |id| {
            const idLen: u32 = intLen(id);
            if (idLen < 2) continue;
            for (2..idLen+1) |len| {
                if (idLen % len != 0) continue;
                const grpSize = idLen / len;
                const m = std.math.pow(u64, 10, grpSize);
                var prev = id % m;
                var temp = @divFloor(id, m);
                var invalid = true;
                while (temp > 0) {
                    if (prev != temp % m) {
                        invalid = false;
                        break;
                    }
                    prev = temp % m;
                    temp = @divFloor(temp, m);
                }
                if (invalid) {
                    ans += id;
                    break;
                }
            }
        }
    } else |err| {
        _ = err catch {};
    }

    std.debug.print("Part 2: {d}\n", .{ans});
}

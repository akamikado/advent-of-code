const std = @import("std");

fn trackTachyon(manifold: *[256][256]u8, reached: *[256][256]u64, width: usize, height: usize, x: usize, y: usize, quantum: bool) u64 {
    if (reached[y][x] > 0) {
        if (quantum) {
            return reached[y][x];
        } else {
            return 0;
        }
    }

    var temp: u64 = 0;
    if (manifold[y][x] == '^') {
        if (quantum) {
            if (x - 1 < 0) {
                temp += 1;
            } else {
                temp += trackTachyon(manifold, reached, width, height, x - 1, y, quantum);
            }
            if (x + 1 >= width) {
                temp += 1;
            } else {
                temp += trackTachyon(manifold, reached, width, height, x + 1, y, quantum);
            }
        } else {
            temp += 1;
            if (x - 1 >= 0) {
                temp += trackTachyon(manifold, reached, width, height, x - 1, y, quantum);
            }
            if (x + 1 < width) {
                temp += trackTachyon(manifold, reached, width, height, x + 1, y, quantum);
            }
        }
    } else {
        if (quantum) {
            if (y + 1 >= height) {
                temp += 1;
            } else {
                temp += trackTachyon(manifold, reached, width, height, x, y + 1, quantum);
            }
        } else {
            if (y + 1 < height) {
                temp += trackTachyon(manifold, reached, width, height, x, y + 1, quantum);
            }
        }
    }
    reached[y][x] = temp;

    return reached[y][x];
}

pub fn main() !void {
    var fileBuf: [4096]u8 = undefined;
    var file = try std.fs.cwd().openFile("day7/input.txt", .{});
    var fileReader = file.reader(&fileBuf);
    var reader = &fileReader.interface;

    var manifold: [256][256]u8 = undefined;
    var width: usize = 0;
    var height: usize = 0;
    while (reader.takeDelimiterInclusive('\n')) |line| {
        const lineLen = if (line[line.len-1] == '\n') line.len-1 else line.len;
        @memcpy(manifold[height][0..lineLen], line[0..lineLen]);
        width = lineLen;
        height += 1;
    } else |err| {
        _ = err catch {};
    }

    var tachyonStartPos: usize = 0;
    for (0..width) |i| {
        if (manifold[0][i] == 'S') {
            tachyonStartPos = i;
            break;
        }
    }
    var reached: [256][256]u64 = [_][256]u64{[_]u64{0} ** 256} ** 256;
    std.debug.print("Part 1: {d}\n", .{trackTachyon(&manifold,  &reached, width, height, tachyonStartPos, 0, false)});

    reached = [_][256]u64{[_]u64{0} ** 256} ** 256;
    std.debug.print("Part 2: {d}\n", .{trackTachyon(&manifold,  &reached, width, height, tachyonStartPos, 0, true)});
}

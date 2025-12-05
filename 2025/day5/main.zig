const std = @import("std");

pub fn main() !void {
    var fileBuf: [1024]u8 = undefined;
    var file = try std.fs.cwd().openFile("day5/input.txt", .{});
    var fileReader = file.reader(&fileBuf);
    var reader = &fileReader.interface;

    var ranges: [1024][2]u64 = undefined;
    var givenRanges: u32 = 0;

    while (reader.takeDelimiterInclusive('\n')) |line| {
        if (line.len == 1) break;
        var separatorIdx: u8 = 0;
        while (separatorIdx < line.len and line[separatorIdx] != '-') separatorIdx += 1;

        const startIdx = try std.fmt.parseInt(u64, line[0..separatorIdx], 10);
        const endIdx = try std.fmt.parseInt(u64, line[separatorIdx+1..line.len-1], 10);
        ranges[givenRanges] = [_]u64{startIdx, endIdx};
        givenRanges += 1;
    } else |err| {
        _ = err catch {};
    }
    
    const cmp = struct {
        pub fn call(_: void, a:[2]u64, b: [2]u64) bool {
            return a[0] < b[0];
        }
    }.call;
    std.mem.sort([2]u64, ranges[0..givenRanges], {}, cmp);

    var ans: u64 = 0;
    while (reader.takeDelimiterInclusive('\n')) |line| {
        const id = try std.fmt.parseInt(u64, line[0..line.len-1], 10);
        for (0..givenRanges) |i| {
            if (id >= ranges[i][0] and id <= ranges[i][1]) {
                ans += 1;
                break;
            }
        }
    } else |err| {
        _ = err catch {};
    }

    std.debug.print("Part 1: {d}\n", .{ans});

    ans = 0;
    var endIdx: u64 = 0;
    for (0..givenRanges) |i| {
        if (endIdx >= ranges[i][0]) {
            if (endIdx >= ranges[i][1]) {
                continue;
            } else {
                ans += ranges[i][1] - endIdx;
                endIdx = ranges[i][1];
            }
        } else {
            ans += ranges[i][1] - ranges[i][0] + 1;
            endIdx = ranges[i][1];
        }
    }

    std.debug.print("Part 2: {d}\n", .{ans});
}

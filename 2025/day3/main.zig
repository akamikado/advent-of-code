const std = @import("std");

fn choose(dp: *[1024][16]i64, bank: []u8, i: usize, req: u8) i64 {
    if (req == 0) return 0;

    if (dp[i][req] != -1) return dp[i][req];

    var ans: i64 = 0;
    for (i..bank.len-req+1) |k| {
        ans = @max(ans,
            bank[k] * std.math.pow(i64, 10, req - 1) + choose(dp, bank, k + 1, req - 1));
    }

    dp[i][req] = ans;

    return ans;
}

pub fn main() !void {
    var file = try std.fs.cwd().openFile("day3/input.txt", .{});
    defer file.close();

    var fileBuf: [1024]u8 = undefined;
    var fileReader = file.reader(&fileBuf);
    var reader = &fileReader.interface;

    var ans: i64 = 0;
    while (reader.takeDelimiterInclusive('\n')) |line| {
        for (0..line.len-1) |i| {
            line[i] -= '0';
        }
        var dp: [1024][16]i64 = undefined;
        for (0..1024) |i| {
            @memset(&dp[i], -1);
        }
        ans += choose(&dp, line[0..line.len-1], 0, 2);
    } else |err| {
        _ = err catch {};
    }

    std.debug.print("Part 1: {d}\n", .{ans});

    try file.seekTo(0);
    fileReader = file.reader(&fileBuf);
    reader = &fileReader.interface;

    ans = 0;
    while (reader.takeDelimiterInclusive('\n')) |line| {
        for (0..line.len-1) |i| {
            line[i] -= '0';
        }
        var dp: [1024][16]i64 = undefined;
        for (0..1024) |i| {
            @memset(&dp[i], -1);
        }
        ans += choose(&dp, line[0..line.len-1], 0, 12);
    } else |err| {
        _ = err catch {};
    }

    std.debug.print("Part 2: {d}\n", .{ans});
}

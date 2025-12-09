const std = @import("std");

pub fn main() !void {
    var fileBuf: [4096]u8 = undefined;
    var file = try std.fs.cwd().openFile("day6/input.txt", .{});
    var fileReader = file.reader(&fileBuf);
    var reader = &fileReader.interface;

    var lines: [32][4096]u8 = undefined;
    var charCountPerLine: usize = 0;
    var lineCount: usize = 0;

    while (reader.takeDelimiterInclusive('\n')) |line| {
        @memcpy(lines[lineCount][0..line.len-1], line[0..line.len-1]);
        charCountPerLine = if (line[line.len-1] == '\n') line.len-1 else line.len;
        lineCount += 1;
    } else |err| {
        _ = err catch {};
    }

    var ops: [4096]u8 = undefined;
    @memset(&ops, 0);
    var numberStartPos: [4096]usize = undefined;
    @memset(&numberStartPos, 0);
    var numberCount: usize = 0;

    for (0..lines[lineCount-1].len) |i| {
        switch (lines[lineCount-1][i]) {
            '+', '*' => {
                ops[numberCount] = lines[lineCount-1][i];
                numberStartPos[numberCount] = i;
                numberCount += 1;
            },
            else => {
            }
        }
    }
    numberStartPos[numberCount] = charCountPerLine+2;

    var ans: u64 = 0;

    for (0..numberCount) |i| {
        var temp: u64 = 0;
        if (ops[i] == '*') temp = 1;
        for (0..lineCount-1) |lineNo| {
            const numStr = std.mem.trim(u8, lines[lineNo][numberStartPos[i]..numberStartPos[i+1]-1], " \n\t");
            const num = try std.fmt.parseInt(u64, numStr, 10);
            switch (ops[i]) {
                '+' => {
                    temp += num;
                },
                '*' => {
                    temp *= num;
                },
                else => {
                }
            }
        }
        ans += temp;
    }

    std.debug.print("Part 1: {d}\n", .{ans});

    ans = 0;

    for (0..numberCount) |i| {
        var colAns: u64 = 0;
        if (ops[i] == '*') colAns = 1;
        for (0..numberStartPos[i+1]-numberStartPos[i]-1) |j| {
            var temp: u64 = 0;
            for (0..lineCount-1) |lineNo| {
                const c = lines[lineNo][numberStartPos[i]+j];
                if (c < '0' or c > '9') continue;
                temp *= 10;
                temp += c - '0';
            }

            switch (ops[i]) {
                '+' => {
                    colAns += temp;
                },
                '*' => {
                    colAns *= temp;
                },
                else => {
                },
            }
        }
        ans += colAns;
    }

    std.debug.print("Part 2: {d}\n", .{ans});
}

const std = @import("std");

pub fn main() !void {
    var dial_val: i32 = 50;
    var ans: u32 = 0;

    var file = try std.fs.cwd().openFile("day1/input.txt", .{});
    defer file.close();

    var file_buf: [1024]u8 = undefined;
    var file_reader = file.reader(&file_buf);
    var reader = &file_reader.interface;

    while (reader.takeDelimiterInclusive('\n')) |line| {
        const direction = line[0];
        var val = try std.fmt.parseInt(u16, line[1..line.len-1], 10);
        val %= 100;
        
        switch (direction) {
            'L' => {
                if (dial_val - val < 0) {
                    dial_val += 100;
                }
                dial_val -= val;
            },
            'R' => {
                if (dial_val + val > 99) {
                    dial_val -= 100;
                }
                dial_val += val;
            },
            else => {
                unreachable;
            }
        }
        if (dial_val == 0) {
            ans += 1;
        }
    } else |err| {
        _ = err catch {};
    }

    std.debug.print("Answer pt 1: {d}\n", .{ans});

    dial_val = 50;
    ans = 0;

    try file.seekTo(0);
    file_reader = file.reader(&file_buf);
    reader = &file_reader.interface;

    while (reader.takeDelimiterInclusive('\n')) |line| {
        const direction = line[0];
        var val = try std.fmt.parseInt(u16, line[1..line.len-1], 10);

        const full_rot = @divFloor(val, 100);
        if (dial_val != 0) {
            ans += full_rot;
        } else if (val % 100 != 0) {
            ans += full_rot;
        } else if (full_rot > 1) {
            ans += full_rot - 1;
        }

        val %= 100;
        
        switch (direction) {
            'L' => {
                if (dial_val - val < 0) {
                    if (dial_val > 0) {
                        ans += 1;
                    }
                    dial_val += 100;
                }
                dial_val -= val;
            },
            'R' => {
                if (dial_val + val > 99) {
                    if (dial_val + val > 100) {
                        ans += 1;
                    }
                    dial_val -= 100;
                }
                dial_val += val;
            },
            else => {
                unreachable;
            }
        }
        if (dial_val == 0) {
            ans += 1;
        }
    } else |err| {
        _ = err catch {};
    }

    std.debug.print("Answer pt 2: {d}\n", .{ans});
}

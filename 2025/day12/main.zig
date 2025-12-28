const std = @import("std");

pub fn main() !void {
    var file_buf: [1024*1024]u8 = undefined;
    var file = try std.fs.cwd().openFile("day12/input.txt", .{});
    var file_reader = file.reader(&file_buf);
    var reader = &file_reader.interface;

    var shapes: [6*4*2][3][3]bool = undefined;
    var base_pixel_counts: [6]u32 = undefined;

    var part_one: u32 = 0;

    while (reader.takeDelimiterInclusive('\n')) |line| {
        if (line.len == 1) continue;
        if (std.mem.indexOf(u8, line, "x") == null) {
            const shapeIdx = try std.fmt.parseInt(usize, line[0..line.len-2], 10);
            var shape: [3][3]bool = undefined;
            for (0..3) |i| {
                const l = try reader.takeDelimiterInclusive('\n');
                for (0..3) |j| {
                    switch (l[j]) {
                        '#' => {
                            shape[i][j] = true;
                        },
                        '.' => {
                            shape[i][j] = false;
                        },
                        else => { unreachable; }
                    }
                }
            }

            var pixel_count: u32 = 0;
            for (0..3) |y| {
                for (0..3) |x| {
                    if (shape[y][x]) pixel_count += 1;
                }
            }
            base_pixel_counts[shapeIdx] = pixel_count;

            for (0..3) |y| {
                for (0..3) |x| {
                    shapes[shapeIdx*4*2+0][y][x] = shape[y][x];
                }
            }

            for (0..3) |y| {
                for (0..3) |x| {
                    shapes[shapeIdx*4*2+1][x][2-y] = shape[y][x];
                }
            }
            for (0..3) |y| {
                for (0..3) |x| {
                    shapes[shapeIdx*4*2+2][2-y][2-x] = shape[y][x];
                }
            }
            for (0..3) |y| {
                for (0..3) |x| {
                    shapes[shapeIdx*4*2+3][2-x][y] = shape[y][x];
                }
            }
            for (0..3) |y| {
                for (0..3) |x| {
                    shapes[shapeIdx*4*2+4][x][y] = shape[y][x];
                }
            }
            for (0..3) |y| {
                for (0..3) |x| {
                    shapes[shapeIdx*4*2+5][y][2-x] = shape[y][x];
                }
            }
            for (0..3) |y| {
                for (0..3) |x| {
                    shapes[shapeIdx*4*2+6][2-x][2-y] = shape[y][x];
                }
            }
            for (0..3) |y| {
                for (0..3) |x| {
                    shapes[shapeIdx*4*2+7][2-y][x] = shape[y][x];
                }
            }
        } else {
            var iter = std.mem.splitScalar(u8, line[0..line.len-1], ' ');
            const size_str = iter.next().?;
            var size_iter = std.mem.splitScalar(u8, size_str[0..size_str.len-1], 'x');
            const region_size:[2]u32 = [_]u32 {
                try std.fmt.parseInt(u32, size_iter.next().?, 10),
                try std.fmt.parseInt(u32, size_iter.next().?, 10),
            };

            const region_quantity = [_]u16 {
                try std.fmt.parseInt(u16, iter.next().?, 10),
                try std.fmt.parseInt(u16, iter.next().?, 10),
                try std.fmt.parseInt(u16, iter.next().?, 10),
                try std.fmt.parseInt(u16, iter.next().?, 10),
                try std.fmt.parseInt(u16, iter.next().?, 10),
                try std.fmt.parseInt(u16, iter.next().?, 10),
            };

            var shape_count: u32 = 0;
            for (0..region_quantity.len) |i| {
                shape_count += region_quantity[i];
            }

            var pixel_count: u32 = 0;
            for (0..6) |i| {
                pixel_count += base_pixel_counts[i] * region_quantity[i];
            }

            if (pixel_count > region_size[0] * region_size[1]) continue;
            part_one += 1;
        }
    } else |err| {
        _ = err catch {};
    }

    std.debug.print("Part 1: {d}\n", .{part_one});
    std.debug.print("Part 2: {d}\n", .{0});
}

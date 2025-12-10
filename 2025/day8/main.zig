const std = @import("std");

fn distance(a: [3]f32, b: [3]f32) f32 {
    return @sqrt((a[0] - b[0])*(a[0] - b[0]) + (a[1] - b[1])*(a[1] - b[1]) + (a[2] - b[2])*(a[2] - b[2]));
}

const Context = struct {
    dist: ?f32,
    junctions: ?*std.array_list.Aligned([3]f32, null),
    size: ?*[]usize
};

fn sortFn(ctx: Context, a: usize, b: usize) bool {
    return (ctx.size.?.*)[a] > (ctx.size.?.*)[b];
}

fn boundFn(ctx: Context, idx: [2]usize) std.math.Order {
    const curDist = distance(ctx.junctions.?.items[idx[0]], ctx.junctions.?.items[idx[1]]);
    return std.math.order(ctx.dist.?, curDist);
}

const disjointSet = struct {
    pub fn join(parents: []usize, size: []usize, u: usize, v: usize) void {
        const pu = findParent(parents, u);
        const pv = findParent(parents, v);

        if (pu == pv) return;
        if (size[pu] < size[pv]) {
            parents[pu] = pv;
            size[pv] += size[pu];
        } else {
            parents[pv] = pu;
            size[pu] += size[pv];
        }
    }
    pub fn findParent(parents: []usize, node: usize) usize {
        if (node == parents[node]) return node;
        parents[node] = findParent(parents, parents[node]);
        return parents[node];
    }
};

pub fn main() !void {
    var fileBuf: [4096]u8 = undefined;
    var file = try std.fs.cwd().openFile("day8/input.txt", .{});
    var fileReader = file.reader(&fileBuf);
    var reader = &fileReader.interface;

    var heapBuf: [1024*1024]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&heapBuf);
    const allocator = fba.allocator();

    var junctions = try std.ArrayListUnmanaged([3]f32).initCapacity(allocator, 16);
    defer junctions.deinit(allocator);

    while (reader.takeDelimiterInclusive('\n')) |line| {
        var iter = std.mem.splitScalar(u8, line, ',');
        var coord: [3]f32 = undefined;
        var cnt: usize = 0;
        while (iter.next()) |numStr| {
            const num = try std.fmt.parseInt(u32, std.mem.trim(u8, numStr, " \n"), 10);
            coord[cnt] = @floatFromInt(num);
            cnt += 1;
        }
        try junctions.append(allocator, coord);
    } else |err| {
        _ = err catch {};
    }

    const maxConns: usize = 1000;

    var maxDist: f32 = 0;
    var maxDistPair: [2]usize = undefined;
    for (0..junctions.items.len) |i| {
        for (i+1..junctions.items.len) |j| {
            const dist = distance(junctions.items[i], junctions.items[j]);
            if (dist > maxDist) {
                maxDist = dist;
                maxDistPair = [_]usize {i, j};
            }
        }
    }

    var parents = try allocator.alloc(usize, junctions.items.len);
    defer allocator.free(parents);
    for (0..junctions.items.len) |i| {
        parents[i] = i;
    }

    var size = try allocator.alloc(usize, junctions.items.len);
    defer allocator.free(size);
    @memset(size, 1);

    var minBound: f32 = 0;
    
    while (true) {
        var sortedPairs: [maxConns][2]usize = [1][2]usize{maxDistPair} ** maxConns;

        for (0..junctions.items.len) |i| {
            for (i+1..junctions.items.len) |j| {
                const dist = distance(junctions.items[i], junctions.items[j]);
                if (dist <= minBound) continue;
                const ctx: Context = .{
                    .dist = dist,
                    .junctions = &junctions,
                    .size = null
                };
                const idx = std.sort.upperBound([2]usize, &sortedPairs, ctx, boundFn);
                if (idx >= maxConns) continue;
                @memmove(sortedPairs[idx+1..maxConns], sortedPairs[idx..maxConns-1]);
                sortedPairs[idx] = [_]usize{i, j};
            }
        }


        var lastProd: u64 = 0;
        for (0..maxConns) |i| {
            disjointSet.join(parents[0..], size[0..], sortedPairs[i][0], sortedPairs[i][1]);

            var numCircuits: usize = 0;
            for (0..junctions.items.len) |j| {
                if (j == disjointSet.findParent(parents, j)) {
                    numCircuits += 1;
                }
            }
            if (numCircuits == 1) {
                lastProd = @as(u64, @intFromFloat(junctions.items[sortedPairs[i][0]][0])) * @as(u64, @intFromFloat(junctions.items[sortedPairs[i][1]][0]));
                std.debug.print("Part 2: {d}\n", .{lastProd});
                return;
            }
        }

        var circuits = try std.ArrayListUnmanaged(usize).initCapacity(allocator, junctions.items.len);
        defer circuits.deinit(allocator);

        for (0..junctions.items.len) |i| {
            if (i == disjointSet.findParent(parents, i)) try circuits.append(allocator, i);
        }

        if (minBound == 0) {
            const ctx: Context = .{ 
                .dist = null,
                .junctions = null,
                .size = &size
            };
            std.mem.sort(usize, circuits.items, ctx, sortFn);
            var ans: u64 = 1;
            for (0..@min(circuits.items.len, 3)) |i| {
                ans *= size[circuits.items[i]];
            }
            std.debug.print("Part 1: {d}\n", .{ans});
        }

        minBound = distance(junctions.items[sortedPairs[maxConns-1][0]], junctions.items[sortedPairs[maxConns-1][1]]);
    }
}

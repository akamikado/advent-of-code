const std = @import("std");

fn countPaths(graph: std.ArrayListUnmanaged([][]u8), visited: *std.StringHashMap(void), pathCount: *std.StringHashMap(u64), curDev: []const u8, outDev: []const u8) !u64 {
    if (visited.contains(curDev)) return 0;
    if (std.mem.eql(u8, curDev, outDev)) return 1;
    if (pathCount.contains(curDev)) return pathCount.get(curDev).?;

    var devPaths: usize = 0;
    for (0..graph.items.len) |i| {
        if (std.mem.eql(u8, graph.items[i][0], curDev)) {
            devPaths = i;
            break;
        }
    }

    if (!std.mem.eql(u8, graph.items[devPaths][0], curDev)) {
        return 0;
    }

    try visited.put(curDev, {});
    var paths: u64 = 0;
    for (1..graph.items[devPaths].len) |i| {
        paths += try countPaths(graph, visited, pathCount, graph.items[devPaths][i], outDev);
    }
    _ = visited.remove(curDev);

    try pathCount.put(curDev, paths);
    return paths;
}

pub fn main() !void {
    var fileBuf: [4096]u8 = undefined;
    var file = try std.fs.cwd().openFile("day11/input.txt", .{});
    var fileReader = file.reader(&fileBuf);
    var reader = &fileReader.interface;

    var heapBuf: [1024*1024]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&heapBuf);
    var allocator = fba.allocator();

    var graph = try std.ArrayListUnmanaged([][]u8).initCapacity(allocator, 16);
    defer graph.deinit(allocator);
    while (reader.takeDelimiterInclusive('\n')) |line| {
        var iter = std.mem.splitScalar(u8, line[0..line.len-1], ' ');
        
        var temp = try std.ArrayListUnmanaged([]u8).initCapacity(allocator, 8);
        defer temp.deinit(allocator);

        var dev = iter.next().?;
        dev = dev[0..dev.len-1];

        try temp.append(allocator, try std.fmt.allocPrintSentinel(allocator, "{s}", .{dev}, 0));

        while (iter.next()) |outDev| {
            try temp.append(allocator, try std.fmt.allocPrintSentinel(allocator, "{s}", .{outDev}, 0));
        } else {}

        const paths = try temp.toOwnedSlice(allocator);

        try graph.append(allocator, paths);
    } else |err| {
        _ = err catch {};
    }

    var visited = std.StringHashMap(void).init(allocator);
    var pathCount = std.StringHashMap(u64).init(allocator);
    std.debug.print("Part 1: {d}\n", .{try countPaths(graph, &visited, &pathCount, "you", "out")});
    visited.deinit();
    pathCount.deinit();

    visited = std.StringHashMap(void).init(allocator);
    pathCount = std.StringHashMap(u64).init(allocator);
    const svr2fft = try countPaths(graph, &visited, &pathCount, "svr", "fft");
    visited.deinit();
    pathCount.deinit();

    visited = std.StringHashMap(void).init(allocator);
    pathCount = std.StringHashMap(u64).init(allocator);
    const svr2dac = try countPaths(graph, &visited, &pathCount, "svr", "dac");
    visited.deinit();
    pathCount.deinit();

    visited = std.StringHashMap(void).init(allocator);
    pathCount = std.StringHashMap(u64).init(allocator);
    const fft2dac = try countPaths(graph, &visited, &pathCount, "fft", "dac");
    visited.deinit();
    pathCount.deinit();

    visited = std.StringHashMap(void).init(allocator);
    pathCount = std.StringHashMap(u64).init(allocator);
    const dac2fft = try countPaths(graph, &visited, &pathCount, "dac", "fft");
    visited.deinit();
    pathCount.deinit();

    visited = std.StringHashMap(void).init(allocator);
    pathCount = std.StringHashMap(u64).init(allocator);
    const dac2out = try countPaths(graph, &visited, &pathCount, "dac", "out");
    visited.deinit();
    pathCount.deinit();

    visited = std.StringHashMap(void).init(allocator);
    pathCount = std.StringHashMap(u64).init(allocator);
    const fft2out = try countPaths(graph, &visited, &pathCount, "fft", "out");
    visited.deinit();
    pathCount.deinit();

    var partTwoAns: u128 = 0;
    if (svr2fft * fft2dac * dac2out > 0) partTwoAns += svr2fft * fft2dac * dac2out;
    if (svr2dac * dac2fft * fft2out > 0) partTwoAns += svr2dac * dac2fft * fft2out;

    std.debug.print("Part 2: {d}\n", .{partTwoAns});

    for (0..graph.items.len) |i| {
        for (0..graph.items[i].len) |j| {
            allocator.free(graph.items[i][j]);
        }
        allocator.free(graph.items[i]);
    }
}

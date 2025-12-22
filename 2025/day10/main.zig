const std = @import("std");
const z3_bindings = @import("z3_bindings");
const z3 = @import("z3");

fn leastStepsToConfigureLights(allocator: std.mem.Allocator, required: []bool, availableWirings: [][]bool, cur: usize, state: []bool) !usize {
    if (cur == availableWirings.len) {
        var isSame: bool = true;
        for (0..required.len) |i| {
            if (state[i] != required[i]) {
                isSame = false;
                break;
            }
        }
        if (isSame) {
            return 0;
        } else {
            return required.len;
        }
    }

    var temp = try allocator.alloc(bool, required.len);
    defer allocator.free(temp);
    for (0..availableWirings[cur].len) |i| {
        temp[i] = state[i];
        if (availableWirings[cur][i]) temp[i] = !temp[i];
    }

    const notSelected = try leastStepsToConfigureLights(allocator, required, availableWirings, cur + 1, state);
    const selected = 1 + try leastStepsToConfigureLights(allocator, required, availableWirings, cur + 1, temp);
    return @min(notSelected, selected);
}

fn leastStepsToConfigureJoltage(allocator: std.mem.Allocator, required: []u16, availableWirings: [][]bool) !u32 {
    var model = z3_bindings.Model.init(.optimize);
    defer model.deinit();

    var constants = try allocator.alloc(z3_bindings.Int, availableWirings.len);
    defer allocator.free(constants);
    for (0..availableWirings.len) |i| {
        const var_name = try std.fmt.allocPrintSentinel(allocator, "{d}", .{i}, 0);
        defer allocator.free(var_name);
        constants[i] = model.constant(.int, var_name);
        model.assert(model.le(model.int(0), constants[i]));
    }

    for (0..required.len) |i| {
        var temp = model.int(0);
        for (0..availableWirings.len) |j| {
            if (availableWirings[j][i]) {
                temp = model.add(&.{temp, constants[j]});
            }
        }

        const constraint = model.eq(temp, model.int(required[i]));
        model.assert(constraint);
    }


    var objective = model.int(0);
    for (0..constants.len) |i| {
        objective = model.add(&.{objective, constants[i]});
    }

    model.minimize(objective);

    _ = model.check();

    var sol = model.getLastModel();
    defer sol.deinit();

    var value_ast: z3.Z3_ast = undefined;
    if (!z3.Z3_model_eval(sol.m.ctx, sol.raw, objective.ast, true, &value_ast)) return 0;
    var result: i64 = undefined;
    if (!z3.Z3_get_numeral_int64(model.ctx, value_ast, &result)) return 0;

    return @intCast(result);
}

pub fn main() !void {
    var fileBuf: [4096]u8 = undefined;
    var file = try std.fs.cwd().openFile("day10/input.txt", .{});
    var fileReader = file.reader(&fileBuf);
    var reader = &fileReader.interface;

    var heapBuf: [32*1024*1024]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&heapBuf);
    var allocator = fba.allocator();


    var partOneAns: u32 = 0;
    var partTwoAns: u32 = 0;
    while (reader.takeDelimiterInclusive('\n')) |line| {
        const trimmedLine = std.mem.trim(u8, line, "\n");

        var iter = std.mem.splitScalar(u8, trimmedLine, ' ');

        var diag = iter.next().?;
        diag = diag[1..diag.len-1];

        var required = try allocator.alloc(bool, diag.len);
        defer allocator.free(required);
        for (0..diag.len) |i| {
            required[i] = diag[i] == '#';
        }

        var wirings = try std.ArrayListUnmanaged([]bool).initCapacity(allocator, 8);
        defer wirings.deinit(allocator);
        var requiredJoltages = try allocator.alloc(u16, required.len);
        defer allocator.free(requiredJoltages);
        while (iter.peek()) |buf| {
            if (buf[0] == '(') {
                _ = iter.next().?;
                var buttonIter = std.mem.splitScalar(u8, buf[1..buf.len-1], ',');
                var wiring = try allocator.alloc(bool, diag.len);
                @memset(wiring, false);
                while (buttonIter.next()) |numStr| {
                    const button = try std.fmt.parseInt(usize, numStr, 10);
                    wiring[button] = true;
                }
                try wirings.append(allocator, wiring);
            } else if (buf[0] == '{') {
                _ = iter.next().?;
                var joltageIter = std.mem.splitScalar(u8, buf[1..buf.len-1], ',');
                var i: usize = 0;
                while (joltageIter.next()) |numStr| {
                    const joltage = try std.fmt.parseInt(u16, numStr, 10);
                    requiredJoltages[i] = joltage;
                    i += 1;
                }
                break;
            } else {
                unreachable;
            }
        }

        const initLightsState = try allocator.alloc(bool, required.len);
        defer allocator.free(initLightsState);
        @memset(initLightsState, false);

        partOneAns += @intCast(try leastStepsToConfigureLights(allocator, required, wirings.items, 0, initLightsState));
        partTwoAns += try leastStepsToConfigureJoltage(allocator, requiredJoltages, wirings.items);
        for (0..wirings.items.len) |i| {
            allocator.free(wirings.items[i]);
        }
    } else |err| {
         _ = err catch {};
    }

    std.debug.print("Part 1: {d}\n", .{partOneAns});
    std.debug.print("Part 2: {d}\n", .{partTwoAns});
}

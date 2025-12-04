const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const completed = 4;

    var executables: [completed]*std.Build.Step.Compile = undefined;
    for (executables, 0..) |_, i| {
        var buf1: [16]u8 = undefined;
        const subdir = std.fmt.bufPrint(&buf1, "day{d}", .{i + 1}) catch "day1";

        var buf2: [32]u8 = undefined;
        const src = std.fmt.bufPrint(&buf2, "{s}/main.zig", .{subdir}) catch "day1/main.zig";
        const exe = b.addExecutable(.{
            .name = subdir,
            .root_module = b.createModule(.{
                .root_source_file = b.path(src),
                .target = target,
                .optimize = optimize,
            }),
        });

        b.installArtifact(exe);

        executables[i] = exe;
    }

    const runStep = b.step("run", "Run a particular day's code");

    var gpa = std.heap.GeneralPurposeAllocator(.{}).init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    if (b.args) |args| {
        var day: u8 = completed;
        if (args.len == 1) {
            day = std.fmt.parseInt(u8, args[0], 10) catch completed;
        }

        const infoStr = std.fmt.allocPrint(allocator, "Running day {d}\n", .{day}) catch {
            return;
        };
        defer allocator.free(infoStr);
        
        _ = std.fs.File.stdout().write(infoStr) catch {
            std.debug.print("Could not compute running day\n", .{});
            return;
        };

        const runExe = b.addRunArtifact(executables[day - 1]);
        runStep.dependOn(&runExe.step);
    } else {
        _ = std.fs.File.stdout().write("No day specified to run\n") catch {
            std.debug.print("No day specified to run\n", .{});
            return;
        };
    }
}

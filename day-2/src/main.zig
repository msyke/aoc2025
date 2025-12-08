const std = @import("std");
const day_2 = @import("day_2");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var inputFile = try std.fs.cwd().openFile("input.txt", .{ .mode = .read_only });
    defer inputFile.close();

    var readBuffer: [1024]u8 = undefined;
    var fileReader = inputFile.reader(&readBuffer);
    var reader = &fileReader.interface;

    var entry = std.Io.Writer.Allocating.init(allocator);
    defer entry.deinit();

    var sum: u128 = 0;

    while (true) {
        _ = reader.streamDelimiter(&entry.writer, ',') catch |err| {
            if (err == error.EndOfStream) break else return err;
        };

        _ = reader.toss(1);
        const entryData = entry.written();

        const prev = sum;
        sum += processProductIdRange(allocator, entryData);
        if (sum < prev) {
            std.debug.print("Intermediate Invalid ID Total: {d}, Prev: {d}\n", .{sum, prev});
        }
        std.debug.assert(sum >= prev);

        entry.clearRetainingCapacity();
    }

    if (entry.written().len > 0) {
        const entryData = entry.written();
        const prev = sum;
        sum += processProductIdRange(allocator, entryData);
        std.debug.assert(sum >= prev);
    }

    std.debug.print("Final Invalid ID Total: {d}\n", .{sum});
}

fn processProductIdRange(alloc: std.mem.Allocator, rangeStr: []u8) u64 {
    std.debug.print("Processing range: {s}\n", .{rangeStr});
    var sum: u64 = 0;

    var splitRange = std.mem.splitAny(u8, rangeStr, "-");
    const lower = splitRange.next() orelse std.debug.panic("rangeStr doesnt contain a lower: {s}", .{rangeStr});
    const upper = splitRange.next() orelse std.debug.panic("rangeStr doesnt contain an upper: {s}", .{rangeStr});

    const whitespaceChars = " \t\r\n";
    const lowerClean = std.mem.trim(u8, lower, whitespaceChars);
    const upperClean = std.mem.trim(u8, upper, whitespaceChars);

    const lowerInt = std.fmt.parseInt(u64, lowerClean, 10) catch |err| {
        std.debug.panic("lowerInt failed to parse: {s} err: {any}", .{lower, err});
    };

    const upperInt = std.fmt.parseInt(u64, upperClean, 10) catch |err| {
        std.debug.panic("upperInt failed to parse: {s} err: {any}", .{upper, err});
    };

    for (lowerInt..(upperInt + 1)) |i| {
        if (!isNumberValid(alloc, i)) {
            const preAddition = sum;
            sum += i;
            std.debug.assert(sum >= preAddition);
        }
    }
    return sum;
}

fn isNumberValid(alloc: std.mem.Allocator, num: u64) bool {
    const numStr = std.fmt.allocPrint(alloc, "{d}", .{num}) catch {
        return false;
    };
    defer alloc.free(numStr);

    const strLen = numStr.len;
    if (@rem(strLen, 2) != 0) {
        return true;
    }
    const half = strLen / 2;

    const first = numStr[0..half];
    const second = numStr[half..];

    std.debug.assert(first.len == second.len);

    const isInvalid = std.mem.eql(u8, first, second);
    if(isInvalid) {
        std.debug.print("  Invalid Nubmer Found: {d}\n", .{num});
    }

    return !isInvalid;
}

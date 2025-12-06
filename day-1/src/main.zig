const std = @import("std");
const day_1 = @import("day_1");

const SafeLock = struct {
    maxNum: i32 = 100,
    currentNum: i32,
    zeroCount: i32 = 0,
    zeroPassCount: i64 = 0,

    const Self = @This();

    fn consumeLine(self: *Self, line: []const u8) !void {
        const direction = line[0];
        const numStr = line[1..];

        const intVal: i32 = try std.fmt.parseInt(i32, numStr, 10);

        if (direction == 'L') {
            const newNumRaw: i32 = self.currentNum - intVal;
            const newNum: i32 = @rem(newNumRaw, self.maxNum);

            if (newNum == 0) {
                self.zeroCount += 1;
                if (newNumRaw < 0) {
                    const timesPastZero: i64 = @abs(@divTrunc(newNumRaw, self.maxNum));
                    self.zeroPassCount += timesPastZero;
                }
                self.currentNum = 0;
            } else if (newNum < 0) {
                const timesPastZero: i64 = @abs(@divTrunc(newNumRaw, self.maxNum));
                if (self.currentNum != 0) {
                    self.zeroPassCount += timesPastZero + 1;
                } else {
                    self.zeroPassCount += timesPastZero;
                }
                self.currentNum = self.maxNum + newNum;
            } else {
                self.currentNum = newNum;
            }
        } else if (direction == 'R') {
            const newNumRaw: i32 = self.currentNum + intVal;
            const newNum: i32 = @rem(newNumRaw, self.maxNum);
            const timesPastZero: i32 = @divTrunc(newNumRaw, self.maxNum);

            if (newNum == 0) {
                self.zeroCount += 1;
                self.zeroPassCount += timesPastZero - 1;
            } else {
                self.zeroPassCount += timesPastZero;
            }

            self.currentNum = newNum;
        }
        std.debug.print("{s} => zeroCount: {d} pasCount: {d} cur: {d}\n", .{ line, self.zeroCount, self.zeroPassCount, self.currentNum });
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var inputFile = try std.fs.cwd().openFile("input.txt", .{ .mode = .read_only });
    defer inputFile.close();

    var read_buffer: [1024]u8 = undefined;
    var file_reader = inputFile.reader(&read_buffer);
    var reader = &file_reader.interface;

    // An accumulating writer to store data read from the file.
    var line = std.Io.Writer.Allocating.init(allocator);
    defer line.deinit();

    var lock = SafeLock{ .currentNum = 50, .maxNum = 100 };

    // Main loop to read data segment by segment.
    while (true) {
        _ = reader.streamDelimiter(&line.writer, '\n') catch |err| {
            if (err == error.EndOfStream) break else return err;
        };
        _ = reader.toss(1); // skip the delimiter byte.
        const lineData = line.written();

        try lock.consumeLine(lineData);

        line.clearRetainingCapacity(); // reset the accumulating buffer.
    }

    // Handle any remaining data after the last delimiter.
    if (line.written().len > 0) {
        const lineData = line.written();

        try lock.consumeLine(lineData);
    }

    const finalTotal = lock.zeroCount + lock.zeroPassCount;
    std.debug.print("Final lock number: {d} Zero Count: {d} Zero Pass Count {d} Total Zero + Zero Pass {d}\n", .{ lock.currentNum, lock.zeroCount, lock.zeroPassCount, finalTotal });
}

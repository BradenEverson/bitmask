const std = @import("std");

fn minBitsForInt(comptime bits: u16) comptime_int {
    var min_bits = 1;

    while (std.math.maxInt(std.meta.Int(.unsigned, min_bits)) < bits) {
        min_bits += 1;
    }

    return min_bits;
}

/// Creates a bitmask of some size from 1 to the maximum u16 size
/// Represented by a comptime sized integer
pub fn Bitmask(comptime size: u16) type {
    if (size == 0) {
        @compileError("Why would you want to create a zero-flag bitflag?\n");
    }

    return packed struct {
        bits: IntType,

        const Self = @This();
        const IntType = std.meta.Int(.unsigned, size);
        const IntForShifts = std.meta.Int(.unsigned, minBitsForInt(size - 1));

        /// Initializes all fields in the bitmask to 0
        pub fn init() Self {
            return Self{ .bits = 0 };
        }

        /// Sets a certain bit in the bitmask
        pub fn set(self: *Self, idx: IntForShifts) void {
            self.bits |= @as(IntType, 1) << idx;
        }

        /// Returns true or false depending on whether the selected bit is turned on
        pub fn get(self: *const Self, idx: IntForShifts) bool {
            return self.bits >> idx & 0x01 == 1;
        }
    };
}

test "packed bitmask size" {
    const mask_type = Bitmask(1024);
    try std.testing.expectEqual(1024, @bitSizeOf(mask_type));
}

test "initializes to 0" {
    const mask = Bitmask(16).init();
    try std.testing.expectEqual(0, mask.bits);
}

test "setting a bit" {
    var mask = Bitmask(16).init();
    mask.set(0);
    try std.testing.expectEqual(1, mask.bits);
}

test "ALL bitmask sizes" {
    // Works for all values of a u16 (source: trust me bro unless you wanna
    // increase the branch count with `@setEvalBranchQuota()`
    comptime for (1..100) |i| {
        var mask = Bitmask(i).init();
        mask.set(0);
        try std.testing.expectEqual(1, mask.bits);
    };
}

test "Min bitmask size for large values" {
    var mask = Bitmask(5200).init();
    mask.set(0);
    try std.testing.expectEqual(1, mask.bits);
}

test "Getting a false flag" {
    const mask = Bitmask(16).init();
    try std.testing.expectEqual(false, mask.get(0));
}

test "Getting a true flag" {
    var mask = Bitmask(16).init();
    mask.set(10);
    try std.testing.expectEqual(true, mask.get(10));
}

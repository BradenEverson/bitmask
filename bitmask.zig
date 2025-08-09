const std = @import("std");

fn minBitsForInt(comptime bits: u16) comptime_int {
    var min_bits = 1;

    while (std.math.maxInt(std.meta.Int(.unsigned, min_bits)) < bits) {
        min_bits += 1;
    }

    return min_bits;
}

pub fn Bitmask(comptime size: u16) type {
    if (size == 0) {
        @compileError("Why would you want to create a zero-flag bitflag?\n");
    }

    return packed struct {
        bits: IntType,

        const Self = @This();
        const IntType = std.meta.Int(.unsigned, size);

        pub fn init() Self {
            return Self{ .bits = 0 };
        }

        pub fn set(self: *Self, idx: std.meta.Int(.unsigned, minBitsForInt(size - 1))) void {
            self.bits |= @as(IntType, 1) << idx;
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
